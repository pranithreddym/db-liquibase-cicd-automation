# Project Development Guidelines

## Repository Owner
This repository belongs to **Pranith Reddy M** (`pranithreddym`).
All commits must be attributed to `Pranith Reddy M <pranithreddym@gmail.com>` only.

## Commit Authorship
- Always use `git config user.name "Pranith Reddy M"` and `git config user.email "pranithreddym@gmail.com"` before committing.
- No third-party bot or tool identities in commit author/committer fields.

## Branch Rules
- Never push directly to `main`. All changes go through a pull request.
- The automated `db-sync/YYYY-MM-DD` branches are created by GitHub Actions only.

## Sync Script
- `scripts/ai/liquibase_sync.py` runs only inside GitHub Actions — it exits immediately outside CI.
- Do not run it manually or commit its output directly.
- The scheduled sync creates a PR from `db-sync/YYYY-MM-DD` to `main` each Monday.
