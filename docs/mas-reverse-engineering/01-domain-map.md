# MAS Domain Map

## Database Shape

| Schema | Tables | Meaning |
|---|---:|---|
| `dbo` | 485 | Core MAS HR/payroll/attendance/workflow tables |
| `service` | 27 | Mobile/service integration, temporary sync tables, payslip/leave/OT service views |
| `billing` | 20 | Billing, client, contractor, invoice, project cost |
| `customize` | 19 | SCC/Tropical custom logic: site transfer, incentive, pay allowance, export group |
| `rosetta` | 8 | Device/time-clock integration staging |
| `payroll` | 5 | KT20A and period configuration |
| `license` | 5 | License/feature/service registration |
| `maspayroll` | 1 | Payroll report/reconcile support |

## Core Domains

| Domain | Master / setup tables | Transaction / fact tables | Logs / staging |
|---|---|---|---|
| Employee & profile | `tEmployee`, `tEmployeeTitle`, `tEmployeeStatus`, `tEmployeeStatusGroup`, `tEmployeeType1/2/3`, `tGender`, `tNationality`, `tPrefix`, `tMartialStatus` | `tEmployee_Children`, `tEmployeeBank`, `tEmployeePhoto`, `tEmployee_LeaveQuota`, `tEmployee_RateP0x` | `tLOG_EmployeeGUID`, `tLOG_EmployeeText`, `tLOG_Update_Employee`, `tLOG_DeleteEmployee` |
| Organization | `tCompany`, `tSSO_Account`, `tProject`, `tSiteTR`, `tBU1..4`, `tCostCenter`, `tLevel`, `tGroup` | `tCostCenter_BU_Mapping`, `tUserProjectPermission`, `tUserBUPermission` | `tLOG_BU`, `tLOG_UpdateWork_BU`, `tLog_Tranfersite` |
| Attendance | `tShift`, `tShiftBreak`, `tShiftLateIn`, `tShiftLateOut`, `tShiftOT`, `tWorkCalendar`, `tWorkCalendarDetail` | `tTimeStamp`, `tTimeInOut`, `tTimeInOut_Data`, `tTimeInOut_AddLeave`, `tTimeSheet`, `tTimeSheet_MultiPeriod` | `tLOG_TimeInOut`, `tLOG_TimeInOutDelete`, `tLogImport_Attendance`, `tTempBatchTime` |
| Payroll | `tPMPeriod`, `tPayroll_ColDef`, `tPayroll_T0xFormat`, `tPayroll_GLAccNo*`, `tColDef_PayrollExport` | `tPayroll`, `tPayroll_Detail`, `tPayroll_Tax`, `tPayroll_Allowance`, `tPayroll_Welfare`, `tTax91` | `tLOG_Payroll`, `tLog_EditPayroll`, `tTemp_PayrollLeave` |
| Leave | `tLeaveGroup`, `tLeaveGroupDetail`, `tLeaveReasonOption`, `tEmployeeLevel_LeaveType`, `tPreset_Leave` | `tLeaveRequest`, `tEmployee_LeaveQuota`, `tAddLeaveManagement` | `tLogAddLeaveManagement`, `service.tTemp_Leave*` |
| Workflow / approval | `tRequestSystem`, `tRequestType`, `tRule`, `tFlow`, `tFlowPath`, `tApproverGroup`, `tApproverList` | `tRequest`, `tStage`, `tSelectApprover`, `tUse_Flow`, `tUseList` | `tLog_Request`, `tLOG_OTApprove`, `tLOG_OTClaimApprove` |
| Security | `tUser`, `tUserGroup`, `tAssignUserRole`, `tAssignMenuPermission`, `tMenuOutpayPermission` | `tUser_LoginStat`, `tUser_PWDHistory`, `tUserWorkgroup` | `tLOG_UserLogon_Outpay` |
| Billing | `billing.tClient`, `billing.tContractor`, `billing.tAllowance`, `billing.tProjectCost`, `billing.tBillBook` | `billing.tInvoice`, `billing.tInvoiceDetail`, `billing.tInvoiceAllowance`, `billing.tTimeSheetStamp` | `billing.tActivityLogs`, `billing.tTemp_TimeSheetStamp` |
| Custom SCC | `customize.tSCC_SettingIncentive`, `customize.tSCC_SettingPayAllowance`, `customize.tSCC_AprvSite` | `customize.tSCC_PayAllowance`, `customize.tSCC_TranferEmp`, `customize.tSCC_TranferSite`, `customize.tSCC_TranferApprove` | `customize.tLog_Tranfersite`, custom temp tables |

## Largest Production Tables

These counts are from `database/metadata/export-20260713/05_row_counts.csv`.

| Table | Rows | Interpretation |
|---|---:|---|
| `dbo.tTimeStamp` | 7,377,898 | Raw clock scan / time stamp fact |
| `dbo.tTimeInOut` | 3,551,128 | Daily attendance calculation/result fact |
| `dbo.tLOG_EmployeeGUID` | 1,984,978 | Employee audit/change log |
| `dbo.tTimeInOut_Data` | 1,420,276 | Attendance detail/result data |
| `dbo.tLOG_OTApprove` | 1,235,090 | OT approval log |
| `dbo.tLOG_EmployeeText` | 1,077,517 | Employee text/audit log |
| `dbo.tTimeInOut_AddLeave` | 726,536 | Leave adjustment inside attendance |
| `dbo.tLOG_TimeInOut` | 402,565 | Attendance edit log |
| `dbo.tPayroll_Detail` | 147,670 | Payroll line detail |
| `dbo.tPayroll_Tax` | 147,619 | Payroll tax calculation |
| `dbo.tPayroll` | 147,616 | Payroll header/employee-period fact |
| `dbo.tPayroll_Allowance` | 147,616 | Allowance fact by payroll |
| `dbo.tEmployee` | 21,939 | Employee master |
| `dbo.tRequest` | 7,099 | Workflow request header |

## Master Table Candidates

High-confidence masters:

- `tEmployee`
- `tCompany`
- `tSSO_Account`
- `tProject`
- `tSiteTR`
- `tBU1`, `tBU2`, `tBU3`, `tBU4`
- `tCostCenter`
- `tEmployeeTitle`
- `tEmployeeStatus`, `tEmployeeStatusGroup`
- `tEmployeeType1`, `tEmployeeType2`, `tEmployeeType3`
- `tShift`
- `tWorkCalendar`
- `tUser`, `tUserGroup`
- `tRequestSystem`, `tRequestType`, `tRule`, `tFlow`, `tFlowPath`
- `tLeaveGroup`, `tLeaveGroupDetail`
- `tPMPeriod`

Transaction/fact table candidates:

- `tTimeStamp`
- `tTimeInOut`
- `tTimeInOut_Data`
- `tPayroll`
- `tPayroll_Detail`
- `tPayroll_Tax`
- `tPayroll_Allowance`
- `tRequest`
- `tStage`
- `tLeaveRequest`
- `tOTRequest_*`
- `tLog_OTClaim`
- `customize.tSCC_Tranfer*`

Tables prefixed with `tLOG_`, `tLog_`, `Log_`, `tTemp_`, `tTemp`, and `service.tTemp_` should be treated as audit/staging unless sample data proves otherwise.
