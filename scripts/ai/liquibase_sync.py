#!/usr/bin/env python3
"""
liquibase_sync.py — Checks the latest Liquibase release on GitHub,
updates LIQUIBASE_IMAGE in .gitlab-ci.yml if a newer version exists,
runs the migration advisor, and writes a sync log entry.

Runs only inside GitHub Actions (exits immediately otherwise).
Usage (CI only):
    python scripts/ai/liquibase_sync.py
"""

import json
import os
import re
import subprocess
import sys
import urllib.request
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
GITLAB_CI = REPO_ROOT / ".gitlab-ci.yml"
SYNC_LOG = REPO_ROOT / "docs" / "sync-log.md"

LIQUIBASE_API = "https://api.github.com/repos/liquibase/liquibase/releases/latest"


def fetch_latest_liquibase_version() -> str:
    req = urllib.request.Request(
        LIQUIBASE_API,
        headers={"Accept": "application/vnd.github+json", "User-Agent": "db-liquibase-cicd-automation"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())
            tag = data.get("tag_name", "")
            return tag.lstrip("v")
    except Exception as exc:
        print(f"[WARN] Could not fetch Liquibase version from GitHub: {exc}")
        return ""


def current_image_version() -> str:
    text = GITLAB_CI.read_text()
    m = re.search(r'LIQUIBASE_IMAGE:\s*"liquibase/liquibase:([^"]+)"', text)
    return m.group(1) if m else ""


def update_image_version(new_ver: str) -> bool:
    text = GITLAB_CI.read_text()
    updated = re.sub(
        r'(LIQUIBASE_IMAGE:\s*"liquibase/liquibase:)[^"]+(")',
        rf'\g<1>{new_ver}\g<2>',
        text,
    )
    if updated == text:
        return False
    GITLAB_CI.write_text(updated)
    return True


def run_migration_advisor() -> str:
    advisor = REPO_ROOT / "scripts" / "ai" / "migration_advisor.py"
    result = subprocess.run(
        [sys.executable, str(advisor), "--dry-run"],
        capture_output=True,
        text=True,
    )
    return result.stdout + result.stderr


def append_sync_log(entry: str) -> None:
    SYNC_LOG.parent.mkdir(parents=True, exist_ok=True)
    header = "# Liquibase DB Sync Log\n\n" if not SYNC_LOG.exists() else ""
    existing = SYNC_LOG.read_text() if SYNC_LOG.exists() else ""
    SYNC_LOG.write_text(header + entry + "\n---\n\n" + existing)


def main() -> None:
    if not os.environ.get("GITHUB_ACTIONS"):
        print("[INFO] liquibase_sync.py only runs inside GitHub Actions. Skipping.")
        sys.exit(0)

    today = date.today().isoformat()
    print(f"[{today}] Starting Liquibase DB sync")

    latest_ver = fetch_latest_liquibase_version()
    current_ver = current_image_version()
    version_changed = False

    if latest_ver and latest_ver != current_ver:
        print(f"  Liquibase {current_ver} → {latest_ver}: updating .gitlab-ci.yml")
        version_changed = update_image_version(latest_ver)
    else:
        print(f"  Liquibase image already up-to-date ({current_ver})")

    advisor_output = run_migration_advisor()
    print("\n--- Migration Advisor Output ---")
    print(advisor_output)

    log_entry = f"## {today}\n\n"
    if version_changed:
        log_entry += f"- **Liquibase updated**: `{current_ver}` → `{latest_ver}` in `.gitlab-ci.yml`\n"
    else:
        log_entry += f"- Liquibase image: `{current_ver}` (no change)\n"
    log_entry += "\n### Migration Advisor\n\n```\n" + advisor_output.strip() + "\n```\n"

    append_sync_log(log_entry)
    print(f"\n[OK] Sync log updated: {SYNC_LOG.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
