# Security

User, group, role, permission, and login metadata.

```mermaid
erDiagram
    dbo_tUserGroup ||--o{ dbo_tUser : "USG_ID"
    dbo_tUserGroup ||--o{ dbo_tAssignUserRole : "USG_ID"
    dbo_tUserGroup ||--o{ dbo_tAssignMenuPermission : "USG_ID"
    dbo_tUser ||--o{ dbo_tUser_LoginStat : "UID"

    dbo_tUserGroup {
      uniqueidentifier USG_ID PK
    }
    dbo_tUser {
      uniqueidentifier UID PK
      uniqueidentifier USG_ID FK
    }
    dbo_tAssignUserRole {
      uniqueidentifier USG_ID FK
    }
    dbo_tAssignMenuPermission {
      uniqueidentifier USG_ID FK
    }
```

## Purpose

Show declared security relationships for account and permission setup.

## Main Tables

- `dbo.tUser`
- `dbo.tUserGroup`
- `dbo.tAssignUserRole`
- `dbo.tAssignMenuPermission`
- `dbo.tUser_LoginStat`
- `dbo.tSYSUserRole`
- `dbo.tSYS_WebMenu`

## Key Relationships

- `tUser.USG_ID -> tUserGroup.USG_ID`
- `tAssignUserRole.USG_ID -> tUserGroup.USG_ID`
- `tAssignMenuPermission.USG_ID -> tUserGroup.USG_ID`
- `tUser_LoginStat.UID -> tUser.UID`

## Business Flow

```text
User group
  -> user
  -> login status
  -> assigned role / menu permission
```

## Known Issues

- Exported FK metadata does not show role/menu master links for `tAssignUserRole` or `tAssignMenuPermission`.
- Employee-to-user mapping is not represented as a declared FK in the exported metadata.
