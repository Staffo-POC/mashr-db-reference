# Staffo MAS Docs

Use this page as the documentation entry point.

## Read This First

- [MAS DB Analysis MVP](./MAS-DB-Analysis-MVP/README.md) - current documentation set for database domains, Mermaid diagrams, and SVG exports.

## Reference Only

- [MAS reverse engineering notes](./mas-reverse-engineering/README.md) - older detailed working notes, seed runbooks, table catalogs, and exploratory analysis.

## Source Of Truth

| Purpose | Path |
|---|---|
| Authoritative metadata export | `database/metadata/export-20260713/` |
| Current docs output | `docs/MAS-DB-Analysis-MVP/` |
| Generated SVG diagrams | `docs/MAS-DB-Analysis-MVP/images/` |
| Local MSSQL Docker notes | `docs/mas-reverse-engineering/04-mcp-local-mssql.md` |

Do not duplicate metadata CSV/SQL files into docs. Keep `database/metadata/export-20260713/` as the single source of metadata.
