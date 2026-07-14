# Attendance

Attendance, timekeeping, shift, work calendar, and time sheet metadata.

```mermaid
erDiagram
    dbo_tEmployee ||--o{ dbo_tTimeStamp : "CardID -> EmployeeCode"
    dbo_tEmployee ||--o{ dbo_tTimeInOut : "EmployeeCode"
    dbo_tShift ||--o{ dbo_tTimeInOut : "SHF_ID"
    dbo_tEmployee ||--o{ dbo_tAssignShift : "EmployeeCode"
    dbo_tEmployee ||--o{ dbo_tAssignShiftByWeekDay : "EmployeeCode"
    dbo_tShift ||--o{ dbo_tShiftBreak : "SHF_ID"
    dbo_tShift ||--o{ dbo_tShiftLateIn : "SHF_ID"
    dbo_tShift ||--o{ dbo_tShiftLateOut : "SHF_ID"
    dbo_tShift ||--o{ dbo_tShiftOT : "SHF_ID"
    dbo_tWorkCalendar ||--o{ dbo_tWorkCalendarDetail : "WCD_ID"
    dbo_tCostCenter ||--o{ dbo_tTimeSheet_MultiPeriod : "CostCenter_ID"
    dbo_tShift ||--o{ dbo_tTimeSheet_MultiPeriod : "SHF_ID"
    dbo_tSiteTR ||--o{ dbo_tTimeSheet_MultiPeriod : "Site_ID"

    dbo_tTimeStamp {
      varchar CardID PK
      varchar Machine_ID PK
      varchar DateInput PK
      smallint nHour PK
      smallint nMinute PK
      varchar Duty PK
    }
    dbo_tTimeInOut {
      varchar EmployeeCode PK
      varchar DateStamp PK
      uniqueidentifier SHF_ID FK
    }
    dbo_tShift {
      uniqueidentifier SHF_ID PK
    }
```

## Purpose

Show declared constraints for attendance and shift-related tables.

## Main Tables

- `dbo.tTimeStamp`
- `dbo.tTimeInOut`
- `dbo.tShift`
- `dbo.tAssignShift`
- `dbo.tWorkCalendar`
- `dbo.tWorkCalendarDetail`
- `dbo.tTimeSheet_MultiPeriod`

## Key Relationships

- `tTimeStamp.CardID -> tEmployee.EmployeeCode`
- `tTimeInOut.EmployeeCode -> tEmployee.EmployeeCode`
- `tTimeInOut.SHF_ID -> tShift.SHF_ID`
- `tWorkCalendarDetail.WCD_ID -> tWorkCalendar.WCD_ID`
- `tTimeSheet_MultiPeriod` links to `tCostCenter`, `tShift`, and `tSiteTR`

## Business Flow

```text
Employee
  -> raw timestamp
  -> time in/out result
  -> shift/calendar rules
  -> time sheet / payroll preparation
```

## Known Issues

- Attendance is the largest data area in row counts.
- Some high-volume tables share natural keys but do not have exported FK rows.
- `tTimeStamp` uses `CardID` as FK to `tEmployee.EmployeeCode`, so naming is not consistent.
