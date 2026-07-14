# MAS Relationship Diagrams

These diagrams combine official FK metadata from `database/metadata/export-20260713/03_foreign_keys.csv` with a few inferred links from column names. Inferred links are marked in notes, not as guaranteed constraints.

## Core HR / Organization

```mermaid
erDiagram
    tCompany ||--o{ tSSO_Account : "CPN_ID"
    tSSO_Account ||--o{ tProject : "SSOACC_ID"
    tSiteTR ||--o{ tEmployee : "Site_ID"
    tEmployeeTitle ||--o{ tEmployee : "EMPTT_ID"
    tEmployeeStatusGroup ||--o{ tEmployeeStatus : "EMPSTG_ID"

    tEmployee {
      varchar EmployeeCode PK
      varchar FirstName
      varchar LastName
      uniqueidentifier EMPTT_ID FK
      uniqueidentifier Site_ID FK
      uniqueidentifier PRJ_ID "inferred project link"
      uniqueidentifier BU1_ID "inferred org unit"
      uniqueidentifier BU2_ID "inferred org unit"
      uniqueidentifier BU3_ID "inferred org unit"
      uniqueidentifier BU4_ID "inferred org unit"
      decimal WageRate
    }

    tCompany {
      uniqueidentifier CPN_ID PK
      varchar CompanyName
      varchar CompanyTAXID
    }

    tProject {
      uniqueidentifier PRJ_ID PK
      uniqueidentifier SSOACC_ID FK
    }

    tSiteTR {
      uniqueidentifier Site_ID PK
    }
```

## Attendance / Timekeeping

```mermaid
erDiagram
    tEmployee ||--o{ tTimeStamp : "CardID -> EmployeeCode"
    tEmployee ||--o{ tTimeInOut : "EmployeeCode"
    tShift ||--o{ tTimeInOut : "SHF_ID"
    tShift ||--o{ tShiftBreak : "SHF_ID"
    tShift ||--o{ tShiftLateIn : "SHF_ID"
    tShift ||--o{ tShiftLateOut : "SHF_ID"
    tShift ||--o{ tShiftOT : "SHF_ID"
    tWorkCalendar ||--o{ tWorkCalendarDetail : "WCD_ID"
    tSiteTR ||--o{ tTimeSheet_MultiPeriod : "Site_ID"
    tShift ||--o{ tTimeSheet_MultiPeriod : "SHF_ID"

    tTimeStamp {
      varchar CardID PK
      varchar Machine_ID PK
      varchar DateInput PK
      smallint nHour PK
      smallint nMinute PK
      varchar Duty PK
      varchar DateStamp
      varchar EmployeeCode
    }

    tTimeInOut {
      varchar EmployeeCode PK
      varchar DateStamp PK
      uniqueidentifier SHF_ID FK
      decimal nWorkUnit
      decimal nOT1
      decimal nOT1_5
      decimal nOT2
      decimal nOT3
      decimal L01
      decimal L02
      uniqueidentifier Site_ID "inferred"
    }
```

## Payroll

```mermaid
erDiagram
    tEmployee ||--o{ tPayroll : "EmployeeCode"
    tPMPeriod ||--o{ tPayroll : "PMPERIOD_ID"
    tProject ||--o{ tPMPeriod : "PRJ_ID"
    tEmployee ||--o{ tLOG_Payroll : "EmployeeCode"
    tEmployee ||--o{ tTax91 : "EmployeeCode"

    tPayroll {
      uniqueidentifier PMPERIOD_ID PK
      varchar EmployeeCode PK
      decimal NetIncome
      decimal TotalIncome
      decimal TotalDeduct
    }

    tPayroll_Detail {
      uniqueidentifier PMPERIOD_ID PK
      varchar EmployeeCode PK
      int RowID PK
      decimal Amount
    }

    tPMPeriod {
      uniqueidentifier PMPeriod_ID PK
      uniqueidentifier PRJ_ID FK
    }
```

Note: `tPayroll_Detail` appears to share the same natural key prefix as `tPayroll` (`PMPERIOD_ID`, `EmployeeCode`) plus `RowID`, but the exported FK list does not include an explicit FK from detail to payroll.

## Workflow / Approval

```mermaid
erDiagram
    tRequestSystem ||--o{ tRequestType : "RequestSystemID"
    tRequestSystem ||--o{ tFlow : "RequestSystemID"
    tRule ||--o{ tRequest : "RuleID"
    tRule ||--o{ tFlowPath : "RuleID"
    tRequest ||--o{ tStage : "ReqID"
    tApproverList ||--o{ tSelectApprover : "APPLID"
    tFlowPath ||--o{ tSelectApprover : "FlowPathID"
    tApproverGroup ||--o{ tUseList : "APPGID"
    tGroup ||--o{ tUse_Flow : "GroupID"

    tRequest {
      uniqueidentifier RequestID PK
      uniqueidentifier RuleID FK
    }

    tStage {
      uniqueidentifier StageID PK
      uniqueidentifier ReqID FK
    }
```

## Security

```mermaid
erDiagram
    tUserGroup ||--o{ tUser : "USG_ID"
    tUserGroup ||--o{ tAssignUserRole : "USG_ID"
    tUserGroup ||--o{ tAssignMenuPermission : "USG_ID"
    tUser ||--o{ tUser_LoginStat : "UID"

    tUser {
      uniqueidentifier UID PK
      varchar Username
      uniqueidentifier USG_ID FK
      varchar User_EmpCode "inferred employee link"
    }
```

## Billing

```mermaid
erDiagram
    tEmployee ||--o{ tTimeSheet_MultiPeriod : "inferred"
    billing_tClient ||--o{ billing_tInvoice : "inferred"
    billing_tInvoice ||--o{ billing_tInvoiceDetail : "inferred"
    billing_tInvoice ||--o{ billing_tInvoiceAllowance : "inferred"
    billing_tInvoice ||--o{ billing_tInvoiceProjectCost : "inferred"

    billing_tClient {
      uniqueidentifier Client_ID PK
      varchar Client_Code
      varchar ClientName
    }

    billing_tInvoice {
      uniqueidentifier Invoice_ID PK
    }
```

Mermaid entity names cannot contain dots, so `billing.tClient` is shown as `billing_tClient`.
