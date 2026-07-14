# MSSQL Internals

This folder contains internal scripts and generated SQL for the local MAS HR Docker database.

Use root scripts for normal developer workflows:

```bash
./scripts/setup.sh
./scripts/status.sh
./scripts/logs.sh
./scripts/reset.sh
```

## Public Internal Entry Points

| Script | Purpose |
|---|---|
| `wait-for-mssql.sh` | Wait until container `mashr-db` accepts SQL connections. |
| `import.sh` | Prepare generated SQL, reset database `MAS`, import schema, and import the selected seed snapshot. |
| `verify.sh` | Run the smoke test against the imported database. |

## Tooling Helpers

Legacy/helper scripts remain under `scripts/` for generation and compatibility:

```text
database/scripts/mssql/scripts/
```

The compatibility wrappers call the root scripts where appropriate.

## Generated Files

Generated SQL and logs are local artifacts:

```text
database/scripts/mssql/generated/
database/scripts/mssql/logs/
```

They are ignored by Git and can be recreated by `./scripts/setup.sh`.
