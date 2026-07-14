# Employee

Employee master data and organization setup.

```mermaid
erDiagram
    dbo_tCompany ||--o{ dbo_tSSO_Account : "CPN_ID"
    dbo_tSSO_Account ||--o{ dbo_tProject : "SSOACC_ID"
    dbo_tProject ||--o{ dbo_tPMPeriod : "PRJ_ID"
    dbo_tSiteTR ||--o{ dbo_tEmployee : "Site_ID"
    dbo_tEmployeeTitle ||--o{ dbo_tEmployee : "EMPTT_ID"
    dbo_tEmployeeStatusGroup ||--o{ dbo_tEmployeeStatus : "EMPSTG_ID"
    dbo_tEmployee ||--o{ dbo_tEmployeePhoto : "EmployeeCode"
    dbo_tEmployee ||--o{ dbo_tAssignChargeRate : "EmployeeCode"
    dbo_tEmployee ||--o{ dbo_tPunishment : "EmployeeCode"
    dbo_tGUILTY_Type ||--o{ dbo_tPunishment : "GUILTY_TYPE_ID"
    dbo_tEmployee ||--o{ dbo_tReward : "EmployeeCode"
    dbo_tPERFORMANCE_Type ||--o{ dbo_tReward : "PERFORMANCE_TYPE_ID"

    dbo_tEmployee {
      varchar EmployeeCode PK
      uniqueidentifier Site_ID FK
      uniqueidentifier EMPTT_ID FK
    }
    dbo_tSiteTR {
      uniqueidentifier Site_ID PK
    }
    dbo_tEmployeeTitle {
      uniqueidentifier EMPTT_ID PK
    }
    dbo_tProject {
      uniqueidentifier PRJ_ID PK
      uniqueidentifier SSOACC_ID FK
    }
```

## Purpose

Describe the declared employee-master relationships exported from MAS metadata.

## Main Tables

- `dbo.tEmployee`
- `dbo.tSiteTR`
- `dbo.tEmployeeTitle`
- `dbo.tEmployeeStatus`
- `dbo.tEmployeeStatusGroup`
- `dbo.tCompany`
- `dbo.tSSO_Account`
- `dbo.tProject`

## Key Relationships

- `tEmployee.Site_ID -> tSiteTR.Site_ID`
- `tEmployee.EMPTT_ID -> tEmployeeTitle.EMPTT_ID`
- `tEmployeeStatus.EMPSTG_ID -> tEmployeeStatusGroup.EMPSTG_ID`
- `tProject.SSOACC_ID -> tSSO_Account.SSOACC_ID`
- `tSSO_Account.CPN_ID -> tCompany.CPN_ID`

## Business Flow

```text
Company
  -> SSO account
  -> Project / payroll period
  -> Employee
  -> Employee photo / charge rate / punishment / reward
```

## Known Issues

- BU-level relationships are not exported as FK rows.
- `dbo.tEmployee` has many columns, so a separate column-level profile is recommended before migration mapping.
- Employee domain row volume is affected by log and temp tables with employee-related names.
