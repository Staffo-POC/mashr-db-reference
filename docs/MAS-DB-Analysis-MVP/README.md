# MAS Database Analysis MVP

Current, concise documentation for MAS database structure.

## What To Open

| Need | File |
|---|---|
| Big picture | [Domain Overview](./diagrams/00-domain-overview.md) |
| Core employee model | [Employee](./diagrams/01-employee.md) |
| Attendance/timekeeping | [Attendance](./diagrams/02-attendance.md) |
| Payroll | [Payroll](./diagrams/03-payroll.md) |
| Workflow/approval | [Workflow](./diagrams/04-workflow.md) |
| Security/user | [Security](./diagrams/05-security.md) |
| Full FK reference | [Full FK Graph](./diagrams/99-full-fk.md) |
| Key findings | [Findings](./notes/findings.md) |
| Next work | [TODO](./notes/todo.md) |

## SVG Diagrams

Generated SVG files are ready under [images](./images/):

- [00-domain-overview.svg](./images/00-domain-overview.svg)
- [01-employee.svg](./images/01-employee.svg)
- [02-attendance.svg](./images/02-attendance.svg)
- [03-payroll.svg](./images/03-payroll.svg)
- [04-workflow.svg](./images/04-workflow.svg)
- [05-security.svg](./images/05-security.svg)
- [99-full-fk.svg](./images/99-full-fk.svg)

Use `99-full-fk.svg` as a technical reference. It is expected to be dense.

## Source Of Truth

| Purpose | Path |
|---|---|
| Authoritative metadata source | `database/metadata/export-20260713/` |
| Documentation output | `docs/MAS-DB-Analysis-MVP/` |
| Mermaid source extracted for SVG export | `docs/MAS-DB-Analysis-MVP/mermaid/` |

Do not duplicate CSV or SQL metadata files into this docs folder. Keeping `database/metadata/export-20260713/` as the only metadata source avoids drift between two copies.

## Progress

| Area | Status | Notes |
|---|---|---|
| Domain Overview | Ready | Rendered to SVG. |
| Employee | Ready | Declared FK view documented. |
| Attendance | Ready | High-volume tables identified. |
| Payroll | Needs validation | Detail-table FKs are not exported. |
| Workflow | Ready | Good declared FK coverage. |
| Security | Ready | User/group/permission FKs are present. |
| Billing | Not started | Metadata exists, but row counts and PK/FK exports are empty. |
| Customize | Not started | Needs separate pass after core domains. |

## Metadata Coverage

| Metric | Count |
|---|---:|
| Tables | 572 |
| Columns | 16,216 |
| Declared FK rows | 56 |
| Schemas | 8 |

## Maintenance

Regenerate SVG diagrams after changing Mermaid source:

```bash
./docs/MAS-DB-Analysis-MVP/render-mermaid.sh
```

Required CLI:

```bash
npm install -g @mermaid-js/mermaid-cli
```
