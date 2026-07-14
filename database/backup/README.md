# Database Backup Snapshots

Use this folder for backup snapshots received from site visits.

Recommended layout:

```text
database/backup/YYYYMMDD/
```

Examples:

```text
database/backup/20260720/MAS_20260720.bak
database/backup/20260720/notes.md
```

Rules:

- Do not commit `.bak`, `.bacpac`, `.mdf`, or `.ldf` files to normal Git.
- Keep a small note file with source/date/context when possible.
- Review backups for sensitive data before sharing outside the project team.
