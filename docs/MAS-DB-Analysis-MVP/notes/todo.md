# TODO

## Next Documentation Passes

- Review Mermaid previews in VS Code.
- Reduce layout issues manually after preview.
- Add Billing diagram after billing sample data or PK/FK metadata is available.
- Add Customize/SCC domain diagram as a separate pass.
- Keep `database/metadata/export-20260713/` as the only metadata source.

## Data Validation

- Validate employee-to-user mapping.
- Validate payroll detail/tax/allowance relationships against period-scoped sample data.
- Validate attendance result tables that share `EmployeeCode` and `DateStamp`.
- Validate request/approver employee columns that are not declared FKs.

## Seed Follow-Up

- Build a coherent period-scoped seed slice.
- Prefer one or two payroll periods with matching employees, attendance, leave/OT, and payroll rows.
- Avoid relying on unrelated `TOP 100` rows for business-flow validation.

## Review Checklist

- Mermaid renders in VS Code preview.
- SVG files exist under `docs/MAS-DB-Analysis-MVP/images/`.
- Each diagram has only exported FK relationships.
- README links all generated docs.
- Findings state metadata limitations clearly.
