# mashr-db-reference

Portable MAS HR database reference package for local Docker SQL Server, schema analysis, and future site snapshots.

## Quick Start

```bash
git clone <repo-url>
cd mashr-db-reference

cp .env.example .env
./scripts/setup.sh
```

When setup finishes, connect with:

```text
Server   : localhost,14333
Database : MAS
Username : sa
Password : see .env
Container: mashr-db
```

The password in `.env.example` is for local development only. Do not reuse it outside local/dev machines.

## Common Commands

```bash
./scripts/setup.sh   # start SQL Server, import schema/master, import selected seed, verify
./scripts/start.sh   # start the existing container
./scripts/status.sh  # show compose status and smoke-test counts
./scripts/logs.sh    # follow SQL Server container logs
./scripts/stop.sh    # stop the container without deleting data
./scripts/reset.sh   # delete the Docker volume and run setup again
```

## Structure

```text
mashr-db-reference/
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
├── scripts/
│   ├── setup.sh
│   ├── start.sh
│   ├── stop.sh
│   ├── status.sh
│   ├── logs.sh
│   └── reset.sh
└── database/
    ├── backup/
    │   └── README.md
    ├── schema/
    │   └── master/
    ├── seed/
    │   └── README.md
    ├── metadata/
    │   └── export-20260713/
    └── scripts/
        └── mssql/
```

## Repository Rules

`database/schema/master/` is the current source used by `./scripts/setup.sh` to build the MAS database. Keep only the verified runnable schema package here.

`database/metadata/`, `database/seed/`, and `database/backup/` store dated snapshots from each site/export round. Do not mix multiple snapshot dates directly into `schema/master`.

Do not replace `database/schema/master/` until a fresh setup has been tested:

```bash
./scripts/reset.sh
./scripts/setup.sh
./scripts/status.sh
```

Backup files such as `.bak`, `.bacpac`, `.mdf`, and `.ldf` are ignored by Git. Keep sensitive raw exports out of commits.

## Seed Snapshots

Setup never imports every seed snapshot automatically. Select exactly one approved seed snapshot with `.env`:

```env
MASHR_SEED_SNAPSHOT=20260713
```

The script imports SQL files from:

```text
database/seed/${MASHR_SEED_SNAPSHOT}/
```

Leave `MASHR_SEED_SNAPSHOT` blank when no approved seed data should be imported.

## Workflow After Getting New Site Data

Example for a new site visit on 2026-07-20:

```text
database/metadata/export-20260720/
database/seed/20260720/
database/backup/20260720/
```

Recommended flow:

1. Add the new snapshot without changing older snapshots.
2. Check whether the files contain personal, customer, payroll, or other sensitive data.
3. Add `manifest.md` to the new metadata snapshot.
4. Compare the new snapshot with `database/schema/master/`.
5. Update `database/schema/master/` only after deciding the new schema should become current.
6. Choose a seed snapshot in `.env.example` only if it is approved for dev use.
7. Test fresh setup with `./scripts/reset.sh`, `./scripts/setup.sh`, and `./scripts/status.sh`.
8. Commit only after the fresh setup passes.

## Internal Scripts

Root scripts are the public interface for developers. MSSQL internals live under:

```text
database/scripts/mssql/
```

The old nested script paths are kept as compatibility wrappers or tooling helpers.
