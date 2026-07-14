# Local MSSQL MCP Notes

## Can We Connect MCP To This Local Database?

Yes. The local database is reachable at:

```text
Server: localhost,14333
Database: MAS
User: sa
Password: see root `.env`
Trust Server Certificate: true
```

Current Codex session can already query the database through the running Docker container. A true MCP setup would add a database MCP server so future agents can query MSSQL through MCP tools directly.

## Practical Options

### Option A: Keep It Simple For Now

Use the existing Docker MSSQL plus scripts from the repo root:

```bash
./scripts/status.sh
```

This is enough for schema/domain analysis and does not require extra MCP installation.

### Option B: Add A SQL Server MCP Server

This is useful if the AI client supports MCP server configuration and you want direct SQL tools available in every session.

Expected connection settings:

```text
host=localhost
port=14333
database=MAS
user=sa
password=<MSSQL_SA_PASSWORD from .env>
encrypt=true
trustServerCertificate=true
```

Recommended security posture:

- Use read-only queries for analysis.
- Do not expose this MCP server outside localhost.
- Prefer a read-only SQL login later instead of `sa`.
- Keep passwords out of committed files.

## Suggested Read-Only Login

After the analysis DB is stable, create a read-only login for MCP:

```sql
USE [master];
CREATE LOGIN [mas_reader] WITH PASSWORD = 'Change_This_ReadOnly_2026!';

USE [MAS];
CREATE USER [mas_reader] FOR LOGIN [mas_reader];
ALTER ROLE [db_datareader] ADD MEMBER [mas_reader];
```

Then use `mas_reader` for MCP instead of `sa`.

## What MCP Would Help With

- Ask natural-language questions over schema.
- Generate table catalog directly from live metadata.
- Inspect stored procedure definitions on demand.
- Trace dependencies table-by-table.
- Validate Mermaid diagrams against actual PK/FK metadata.
- Compare local Docker schema with future PostgreSQL migration schema.
