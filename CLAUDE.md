# Project Guidelines for Claude Code

## Repository Owner
This repository belongs to **Pranith Reddy M** (`pranithreddym`).
All commits must be attributed to `Pranith Reddy M <pranithreddym@gmail.com>` only.

## Commit Authorship — CRITICAL
- **Never** commit or push with `Claude`, `noreply@anthropic.com`, or any Anthropic identity.
- When using local git: always run `git config user.name "Pranith Reddy M"` and `git config user.email "pranithreddym@gmail.com"` first.
- When using the `push_files` MCP tool: always set `author_name: "Pranith Reddy M"` and `author_email: "pranithreddym@gmail.com"`.

## Branch Rules
- **Never push directly to `main`.**
- All changes go to a feature branch first, then via pull request.
- The only exception is the automated `weekly-sync/YYYY-MM-DD` branches created by GitHub Actions.

## Weekly Sync Script
- `scripts/ai/weekly_liquibase_sync.py` runs **only inside GitHub Actions** (it exits immediately outside CI).
- Do not run it manually, do not commit its output to `main` directly.
- The weekly sync creates a PR from `weekly-sync/YYYY-MM-DD` to `main` — that PR must be reviewed and merged by `pranithreddym`.

## Development Branch
Active development: `claude/liquibase-mysql-setup-dYAsP`
