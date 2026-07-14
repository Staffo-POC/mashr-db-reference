# Seed Snapshots

Use this folder for approved local/dev seed data snapshots.

Recommended layout:

```text
database/seed/YYYYMMDD/
├── 001-master-data.sql
└── 002-test-data.sql
```

`./scripts/setup.sh` does not import every snapshot. Select exactly one snapshot in root `.env`:

```env
MASHR_SEED_SNAPSHOT=20260713
```

Leave `MASHR_SEED_SNAPSHOT` blank when no seed data should be imported.

Rules:

- Commit only data approved for local development.
- Put sensitive raw data under `sensitive/`; that path is ignored.
- Keep SQL files ordered with numeric prefixes so imports are deterministic.
