#!/usr/bin/env python3
"""
migration_advisor.py — Analyzes the existing Liquibase changelog and SQL schema
to suggest the next meaningful migration, then scaffolds the files automatically.

Usage:
    python scripts/ai/migration_advisor.py [--dry-run] [--version <v1.4.0>]
"""

import argparse
import re
import sys
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CHANGELOG_ROOT = REPO_ROOT / "liquibase" / "changelog" / "releases"
MASTER_CHANGELOG = REPO_ROOT / "liquibase" / "changelog" / "db.changelog-master.xml"
AUTHOR = "pranithreddym"

EVOLUTION_RULES = [
    {
        "detect": lambda cols: "status" in cols and "status_changed_at" not in cols,
        "suggestion": "Add status_changed_at DATETIME column and an idx on it for time-series queries on status transitions.",
        "type": "column_addition",
    },
    {
        "detect": lambda cols: any(c.endswith("_id") for c in cols) and "deleted_at" not in cols,
        "suggestion": "Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.",
        "type": "soft_delete",
    },
    {
        "detect": lambda cols: "json" in " ".join(cols).lower() and "schema_version" not in cols,
        "suggestion": "JSON columns detected — add schema_version TINYINT NOT NULL DEFAULT 1 to track payload format changes.",
        "type": "schema_versioning",
    },
    {
        "detect": lambda cols: "created_at" in cols and "updated_at" not in cols,
        "suggestion": "Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP.",
        "type": "timestamp_addition",
    },
]


def parse_sql_columns(sql: str) -> list[str]:
    cols = []
    for line in sql.splitlines():
        line = line.strip().lstrip("`")
        m = re.match(r'^`?(\w+)`?\s+\w+', line)
        if m and not line.upper().startswith(("PRIMARY", "UNIQUE", "INDEX", "KEY", "CONSTRAINT", "PARTITION")):
            cols.append(m.group(1).lower())
    return cols


def discover_versions() -> list[tuple[str, Path]]:
    versions = []
    for d in CHANGELOG_ROOT.iterdir():
        if d.is_dir() and re.match(r"v\d+\.\d+\.\d+", d.name):
            versions.append((d.name, d))
    versions.sort(key=lambda x: [int(n) for n in x[0].lstrip("v").split(".")])
    return versions


def next_version(current: str) -> str:
    major, minor, patch = [int(x) for x in current.lstrip("v").split(".")]
    return f"v{major}.{minor + 1}.{patch}"


def analyse_schema() -> list[dict]:
    findings = []
    for sql_file in sorted(CHANGELOG_ROOT.rglob("*.sql")):
        if "rollback" in sql_file.name:
            continue
        text = sql_file.read_text()
        m = re.search(r"CREATE TABLE IF NOT EXISTS `(\w+)`", text)
        if not m:
            continue
        table = m.group(1)
        cols = parse_sql_columns(text)
        for rule in EVOLUTION_RULES:
            if rule["detect"](cols):
                findings.append({
                    "table": table,
                    "suggestion": rule["suggestion"],
                    "type": rule["type"],
                    "source_file": str(sql_file.relative_to(REPO_ROOT)),
                })
    return findings


def scaffold_migration(version: str, findings: list[dict], dry_run: bool) -> None:
    version_dir = CHANGELOG_ROOT / version
    sql_dir = version_dir / "sql"

    if not dry_run:
        sql_dir.mkdir(parents=True, exist_ok=True)

    ver_num = version.lstrip("v")
    today = date.today().isoformat()
    changesets = []
    seq = 1

    for finding in findings[:5]:
        padded = str(seq).zfill(3)
        table = finding["table"]
        suggestion_slug = finding["type"].replace("_", "-")
        sql_filename = f"{padded}_{suggestion_slug}_{table}.sql"
        rollback_filename = f"{padded}_{suggestion_slug}_{table}_rollback.sql"
        changeset_id = f"{ver_num}-{padded}"

        sql_content = _generate_sql(finding, ver_num, padded)
        rollback_content = _generate_rollback(finding, ver_num, padded)

        if not dry_run:
            (sql_dir / sql_filename).write_text(sql_content)
            (sql_dir / rollback_filename).write_text(rollback_content)

        changesets.append({
            "id": changeset_id,
            "comment": f"{finding['type'].replace('_', ' ').title()} on {table}: {finding['suggestion'][:80]}",
            "sql_file": f"changelog/releases/{version}/sql/{sql_filename}",
            "rollback_file": f"changelog/releases/{version}/sql/{rollback_filename}",
        })
        seq += 1

    xml_content = _generate_changelog_xml(version, ver_num, today, changesets)
    xml_path = version_dir / f"db.changelog-{ver_num}.xml"

    if dry_run:
        print(f"\n{'='*60}")
        print(f"DRY RUN — would create: {xml_path.relative_to(REPO_ROOT)}")
        print(xml_content)
        for cs in changesets:
            print(f"\n  changeset: {cs['id']} — {cs['comment']}")
    else:
        xml_path.write_text(xml_content)
        _append_to_master(version, ver_num)
        print(f"[OK] Created {len(changesets)} changeset(s) in {version_dir.relative_to(REPO_ROOT)}")
        print(f"[OK] Updated master changelog")


def _generate_sql(finding: dict, ver_num: str, seq: str) -> str:
    table = finding["table"]
    ftype = finding["type"]
    cs_id = f"{ver_num}-{seq}"
    header = f"-- changeset {AUTHOR}:{cs_id}\n-- comment: {finding['suggestion']}\n\n"

    if ftype == "column_addition":
        return header + (
            f"ALTER TABLE `{table}`\n"
            f"    ADD COLUMN `status_changed_at` DATETIME DEFAULT NULL\n"
            f"        COMMENT 'Timestamp of last status transition',\n"
            f"    ADD INDEX `idx_{table}_status_changed_at` (`status_changed_at`);\n"
        )
    if ftype == "soft_delete":
        return header + (
            f"ALTER TABLE `{table}`\n"
            f"    ADD COLUMN `deleted_at` DATETIME DEFAULT NULL\n"
            f"        COMMENT 'Soft-delete timestamp; NULL means not deleted',\n"
            f"    ADD INDEX `idx_{table}_deleted_at` (`deleted_at`);\n"
        )
    if ftype == "schema_versioning":
        return header + (
            f"ALTER TABLE `{table}`\n"
            f"    ADD COLUMN `schema_version` TINYINT NOT NULL DEFAULT 1\n"
            f"        COMMENT 'JSON payload format version for forward-compatibility';\n"
        )
    if ftype == "timestamp_addition":
        return header + (
            f"ALTER TABLE `{table}`\n"
            f"    ADD COLUMN `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n"
            f"        ON UPDATE CURRENT_TIMESTAMP\n"
            f"        COMMENT 'Auto-updated on every row change';\n"
        )
    return header + f"-- TODO: manual SQL for {ftype} on {table}\n"


def _generate_rollback(finding: dict, ver_num: str, seq: str) -> str:
    table = finding["table"]
    ftype = finding["type"]
    if ftype == "column_addition":
        return (
            f"ALTER TABLE `{table}` DROP INDEX `idx_{table}_status_changed_at`;\n"
            f"ALTER TABLE `{table}` DROP COLUMN `status_changed_at`;\n"
        )
    if ftype == "soft_delete":
        return (
            f"ALTER TABLE `{table}` DROP INDEX `idx_{table}_deleted_at`;\n"
            f"ALTER TABLE `{table}` DROP COLUMN `deleted_at`;\n"
        )
    if ftype == "schema_versioning":
        return f"ALTER TABLE `{table}` DROP COLUMN `schema_version`;\n"
    if ftype == "timestamp_addition":
        return f"ALTER TABLE `{table}` DROP COLUMN `updated_at`;\n"
    return f"-- TODO: rollback for {ftype} on {table}\n"


def _generate_changelog_xml(version: str, ver_num: str, today: str, changesets: list[dict]) -> str:
    entries = ""
    for cs in changesets:
        entries += f"""
    <changeSet id="{cs['id']}" author="{AUTHOR}">
        <comment>{cs['comment']}</comment>
        <sqlFile path="{cs['sql_file']}"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="{cs['rollback_file']}"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>
"""
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <!-- ==========================================
         Release: {version}
         Description: Advisor-generated migrations
         Author: Pranith Reddy M
         Date: {today}
         ========================================== -->
{entries}
</databaseChangeLog>
"""


def _append_to_master(version: str, ver_num: str) -> None:
    text = MASTER_CHANGELOG.read_text()
    new_include = f'\n    <!-- {version}: advisor-generated -->\n    <include file="changelog/releases/{version}/db.changelog-{ver_num}.xml"/>\n'
    text = text.replace("</databaseChangeLog>", new_include + "</databaseChangeLog>")
    MASTER_CHANGELOG.write_text(text)


def print_report(findings: list[dict]) -> None:
    print(f"\n{'='*60}")
    print("SCHEMA ANALYSIS REPORT")
    print(f"{'='*60}")
    if not findings:
        print("No evolution opportunities found — schema looks complete.")
        return
    for i, f in enumerate(findings, 1):
        print(f"\n[{i}] Table : {f['table']}")
        print(f"    Type  : {f['type']}")
        print(f"    Hint  : {f['suggestion']}")
        print(f"    File  : {f['source_file']}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Liquibase Migration Advisor")
    parser.add_argument("--dry-run", action="store_true", help="Print proposed changes without writing files")
    parser.add_argument("--version", default=None, help="Override target version (e.g. v1.4.0)")
    args = parser.parse_args()

    versions = discover_versions()
    if not versions:
        print("No existing versions found under liquibase/changelog/releases/", file=sys.stderr)
        sys.exit(1)

    latest_ver = versions[-1][0]
    target_ver = args.version or next_version(latest_ver)
    print(f"Latest version : {latest_ver}")
    print(f"Target version : {target_ver}")

    findings = analyse_schema()
    print_report(findings)

    if not findings:
        sys.exit(0)

    scaffold_migration(target_ver, findings, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
