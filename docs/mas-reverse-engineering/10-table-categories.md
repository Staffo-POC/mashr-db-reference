# MAS Table Categories (Full Catalog)

Every table in the `MAS` database (572 rows read from `database/metadata/export-20260713/05_row_counts.csv`, covering all 8 schemas) classified into one of 7 categories. This extends the 3-way split in [01-domain-map.md](./01-domain-map.md) and supersedes it for `tEmployee`/`tUser`, which that file mis-labeled as master data — see the corrected definition in [09-data-count-summary.md](./09-data-count-summary.md).

Related diagrams: [08-relationship-mermaid.md](./08-relationship-mermaid.md) colors entities by these same categories.

## Method

Classification is a repeatable heuristic, not a manual review of all 572 tables:

1. **Name pattern first** — `Log`/`LOG` in the name → Log/Audit. `Temp` in the name → Temp/Staging. Exact match on `tEmployee`/`tEmployee_New`/`tUser` → Entity/Account. Known EF/ticket tables → System/Internal.
2. **Shape + volume scoring for everything else** — using `database/metadata/export-20260713/02_columns.csv` (column count, presence of `datetime`/`decimal` columns, an `EmployeeCode`/`UID` column, a `Period` column) and `database/metadata/export-20260713/05_row_counts.csv` (production row count), plus keyword hints in the name (e.g. `Type`, `Style`, `Reason`, `Config` lean master; `Detail`, `Request`, `Assign`, `Payroll`, `Claim` lean transaction). Whichever side scores higher wins; a tie or no signal falls into **Other/Unclear**.
3. **Manual overrides (10 tables)** — corrected by hand where the automatic scoring conflicted with earlier `describe_table` schema inspection or clear domain knowledge:
   - `tShift`, `tProject`, `tRequestType`, `tApproverList` — already hand-verified as Master/Config in [09-data-count-summary.md](./09-data-count-summary.md); the scorer got these wrong from keyword collisions (e.g. `tRequestType` matches both the master keyword `requesttype` and the transaction keyword `request`).
   - `tReimType`, `tInfoExportGroup`, `tInfoExportGroupDetail`, `tSelectApprover`, `tAssignMenuPermission`, `tAssignUserRole` — permission/approval-routing setup tables, moved from Other/Unclear to Master/Config on manual review; they define configuration, not a business event.

This will still misclassify some tables — treat it as a starting point for review, not ground truth. `Other/Unclear` exists specifically to surface the ones the heuristic couldn't call, and the same keyword-collision problem that affected the overridden tables likely affects others that weren't manually cross-checked.

## Summary

| Category | Table count | Meaning |
|---|---:|---|
| Master/Config | 193 | Static reference/lookup/enum data and org-structure tables (department, division, site, bank, tax rate, request type, approver/permission setup, etc). Shape is usually `ID + description`; other tables FK into these. Treat as safe to fully seed. |
| Entity/Account | 3 | Core identity records for real people/accounts — `tEmployee`, `tEmployee_New`, `tUser`. Not configuration; production volume is large (~22k employees). Needs a period-scoped or filtered seed slice, not a full dump. |
| Transaction/Fact | 160 | Business events and per-employee/per-period records: payroll runs, attendance punches, requests, approvals, incentives, transfers. Volume grows over time; only take an intentional seed slice. |
| Log/Audit | 48 | Audit trail / change history tables (`tLOG_*`, `tLog_*`, `Log_*`). Not needed for functional seeding; useful only if debugging historical changes. |
| Temp/Staging | 123 | Scratch/staging tables used by import batch jobs and mobile sync (`tTemp_*`, `service.tTemp_*`). Safe to leave empty in a dev seed; repopulated by the jobs that use them. |
| System/Internal | 4 | ORM/migration bookkeeping tables (EF migration history, ticket log). Not business data. |
| Other/Unclear | 41 | Heuristic gave a tie or no signal (small junction tables, field-caption tables, or empty tables with ambiguous shape). Needs a human look before trusting the category. |
| **Total** | **572** | |

## Master/Config (193)

Static reference/lookup/enum data and org-structure tables (department, division, site, bank, tax rate, request type, approver/permission setup, etc). Shape is usually `ID + description`; other tables FK into these. Treat as safe to fully seed.

| Schema.Table | Production rows |
|---|---:|
| `dbo.tWorkCalendarDetail` | 945 |
| `dbo.tResignReason` | 678 |
| `dbo.tMenuOutpayPermission` | 592 |
| `dbo.tBU1_New` | 560 |
| `dbo.tBU1` | 532 |
| `dbo.tProject_GLAccNoRow` | 275 |
| `dbo.tEmployeeTitle` | 209 |
| `dbo.tSiteTR` | 187 |
| `customize.tSCC_AprvSite` | 141 |
| `dbo.tReport_name` | 134 |
| `dbo.tvTimeAttendance_FieldCaption` | 100 |
| `dbo.tGLAccount_MapField` | 96 |
| `customize.tInfoExportGroupDetail` | 87 |
| `dbo.tProvince` | 77 |
| `dbo.tSelectApprover` | 60 |
| `dbo.tSysParm` | 58 |
| `dbo.tBankMaster` | 56 |
| `dbo.tReportNormal_Config` | 46 |
| `dbo.tRequestType` | 43 |
| `dbo.tGUILTY_Type` | 39 |
| `dbo.tW_Option` | 39 |
| `dbo.tBankName` | 36 |
| `dbo.tSYSDayInMonth` | 31 |
| `dbo.tSystem_CustomMenu` | 30 |
| `dbo.tFlow` | 29 |
| `dbo.tFlowPath` | 29 |
| `dbo.tRule` | 29 |
| `dbo.tSSO_Hospital` | 27 |
| `dbo.tApproverList` | 24 |
| `dbo.tEmployeeWork_Quota` | 22 |
| `dbo.dtproperties` | 21 |
| `dbo.tEmployeeLevel` | 14 |
| `dbo.tBU2_New` | 13 |
| `dbo.tEmployeeLevel_LeaveType` | 12 |
| `dbo.tSYS_RegistBank` | 12 |
| `dbo.tAssignUserRole` | 10 |
| `dbo.tSystem_MEventName` | 9 |
| `dbo.tFlagWork` | 8 |
| `dbo.tRequestSystem` | 8 |
| `dbo.tSYSTurnOverRate` | 8 |
| `dbo.tSYSUserRole` | 8 |
| `dbo.tShift` | 7 |
| `dbo.tSSO_ResignReason` | 7 |
| `dbo.tSysWeekName` | 7 |
| `dbo.tTrainingType` | 7 |
| `dbo.tUserGroup` | 7 |
| `dbo.tUserWorkgroup` | 7 |
| `rosetta.Rosetta2_Operator` | 7 |
| `customize.tInfoExportGroup` | 6 |
| `dbo.tSysConfig` | 6 |
| `rosetta.Rosetta2_Conditions` | 6 |
| `dbo.tChildren_Prefix` | 5 |
| `dbo.tDecorationGroup` | 5 |
| `dbo.tEmployeeType1` | 5 |
| `dbo.tMartialStatus` | 5 |
| `dbo.tPENALTY_Type` | 5 |
| `dbo.tProject` | 5 |
| `dbo.tProject_GLAccNo` | 5 |
| `dbo.tSlipStyle` | 5 |
| `dbo.tSYSDownloadFileList` | 5 |
| `dbo.tSYSOutPayMenuAdvance` | 5 |
| `dbo.tBatchAdjust` | 4 |
| `dbo.tBU2` | 4 |
| `dbo.tCardStatus_Type` | 4 |
| `dbo.tSYS_MENU_MOD` | 4 |
| `dbo.tAssignMenuPermission` | 3 |
| `dbo.tCompany` | 3 |
| `dbo.tCostCenter` | 3 |
| `dbo.tEmployeeStatus` | 3 |
| `dbo.tEmployeeStatusGroup` | 3 |
| `dbo.tGender` | 3 |
| `dbo.tNationality` | 3 |
| `dbo.tPrefix` | 3 |
| `dbo.tPunishmentStyle` | 3 |
| `dbo.tReimType` | 3 |
| `dbo.tSSO_Account` | 3 |
| `dbo.tWorkCalendar` | 3 |
| `dbo.tCertificationStyle` | 2 |
| `dbo.tControlMOD` | 2 |
| `dbo.tEmployeeType3` | 2 |
| `dbo.tSysSettings` | 2 |
| `dbo.tAppConnector` | 1 |
| `dbo.tAward_Type` | 1 |
| `dbo.tBadgeStyle` | 1 |
| `dbo.tBatchLeave` | 1 |
| `dbo.tBatchProbation` | 1 |
| `dbo.tBatchResign` | 1 |
| `dbo.tBU3` | 1 |
| `dbo.tBU3_New` | 1 |
| `dbo.tBU4` | 1 |
| `dbo.tBU4_New` | 1 |
| `dbo.tDecoration` | 1 |
| `dbo.tEmployeeType_FieldCaption` | 1 |
| `dbo.tEmployeeType2` | 1 |
| `dbo.tMail_Config` | 1 |
| `dbo.tPERFORMANCE_Type` | 1 |
| `dbo.tSetting_Email` | 1 |
| `dbo.tSSO_Data` | 1 |
| `dbo.tSYSMODReportList` | 1 |
| `dbo.tTrainingCompany` | 1 |
| `service.SysConfig` | 1 |
| `billing.tClientProjectCost` | 0 |
| `billing.tClientType` | 0 |
| `billing.tContractorProjectCost` | 0 |
| `billing.tSetting_PeriodDays` | 0 |
| `customize.tInfoExportGroupDetailSelected` | 0 |
| `dbo.tAppConnector_File` | 0 |
| `dbo.tApproverGroup` | 0 |
| `dbo.tAssignProjectPermission` | 0 |
| `dbo.tAutoPost_Initial` | 0 |
| `dbo.tBankBranch` | 0 |
| `dbo.tCCList` | 0 |
| `dbo.tColDef_rPM` | 0 |
| `dbo.tCondition` | 0 |
| `dbo.tCostAllocation_UserList` | 0 |
| `dbo.tCostCenter_BU_Mapping` | 0 |
| `dbo.tCourse` | 0 |
| `dbo.tEmployee_Decoration` | 0 |
| `dbo.tEmployeeBank` | 0 |
| `dbo.tEmployeeCodeFilter` | 0 |
| `dbo.tEmployeeCodeFilter_TRM` | 0 |
| `dbo.tEMPTP1_2_Mapping` | 0 |
| `dbo.tEMPTP2_3_Mapping` | 0 |
| `dbo.tGLAccount` | 0 |
| `dbo.tGroup` | 0 |
| `dbo.tLeaveReasonOption` | 0 |
| `dbo.tLevel` | 0 |
| `dbo.tManager` | 0 |
| `dbo.tMOD_BUChargeRate` | 0 |
| `dbo.tOther1` | 0 |
| `dbo.tOther2` | 0 |
| `dbo.tOther3` | 0 |
| `dbo.tOther4` | 0 |
| `dbo.tOther5` | 0 |
| `dbo.tProject_GLAccNoRow_GroupType` | 0 |
| `dbo.tPVF_Menu` | 0 |
| `dbo.tPVFSub` | 0 |
| `dbo.tRC_Computer` | 0 |
| `dbo.tRC_Degree` | 0 |
| `dbo.tRC_DegreeName` | 0 |
| `dbo.tRC_Language` | 0 |
| `dbo.tRC_Question` | 0 |
| `dbo.tRC_Sibling` | 0 |
| `dbo.tRC_Training` | 0 |
| `dbo.tReimType_RR0xFormat` | 0 |
| `dbo.tReportCenter_Config` | 0 |
| `dbo.tReportCustomize_Config` | 0 |
| `dbo.tRPT_ReportFilter` | 0 |
| `dbo.tSCC_SubContract` | 0 |
| `dbo.tSetting_Password` | 0 |
| `dbo.tShift_Filter` | 0 |
| `dbo.tShiftGroup` | 0 |
| `dbo.tShiftPattern` | 0 |
| `dbo.tShiftPatternGroup` | 0 |
| `dbo.tShiftProject` | 0 |
| `dbo.tSiteRate` | 0 |
| `dbo.tSiteTR_BU_Mapping` | 0 |
| `dbo.tSiteTR_MappingScan` | 0 |
| `dbo.tSiteUpdate` | 0 |
| `dbo.tSYS_SCCMenu` | 0 |
| `dbo.tSYSMODReportFilter` | 0 |
| `dbo.tSystemFlow` | 0 |
| `dbo.tTrainingMode` | 0 |
| `dbo.tTrainingPerson` | 0 |
| `dbo.tTrainingPlace` | 0 |
| `dbo.tTrainingTypeEvaluate` | 0 |
| `dbo.tUse_Flow` | 0 |
| `dbo.tUseList` | 0 |
| `dbo.tUserAD` | 0 |
| `dbo.tUserBU2Permission` | 0 |
| `dbo.tUserBU3Permission` | 0 |
| `dbo.tUserBU4Permission` | 0 |
| `dbo.tUserBUPermission` | 0 |
| `dbo.tUserEmpLevelPermission` | 0 |
| `dbo.tUserEMPTP1Permission` | 0 |
| `dbo.tUserEMPTP2Permission` | 0 |
| `dbo.tUserEMPTP3Permission` | 0 |
| `dbo.tUserProjectPermission` | 0 |
| `dbo.tUserWebMenuPermission` | 0 |
| `dbo.tVacationLockFlag` | 0 |
| `dbo.tWorkCalendarShiftPattern` | 0 |
| `dbo.tYTD_Report_Wait_Stored` | 0 |
| `license.AccessClient` | 0 |
| `license.FeatureRegister` | 0 |
| `license.LicenseRegister` | 0 |
| `license.ServiceRegister` | 0 |
| `payroll.KT20A_FieldConfiguration` | 0 |
| `payroll.Period_Configuration` | 0 |
| `rosetta.Rosetta2_Device` | 0 |
| `rosetta.Rosetta2_Door` | 0 |
| `rosetta.Rosetta2_Event` | 0 |
| `rosetta.Rosetta2_User` | 0 |
| `rosetta.Rosetta2_UserGroup` | 0 |

## Entity/Account (3)

Core identity records for real people/accounts — `tEmployee`, `tEmployee_New`, `tUser`. Not configuration; production volume is large (~22k employees). Needs a period-scoped or filtered seed slice, not a full dump.

| Schema.Table | Production rows |
|---|---:|
| `dbo.tEmployee_New` | 21,945 |
| `dbo.tEmployee` | 21,939 |
| `dbo.tUser` | 87 |

## Transaction/Fact (160)

Business events and per-employee/per-period records: payroll runs, attendance punches, requests, approvals, incentives, transfers. Volume grows over time; only take an intentional seed slice.

| Schema.Table | Production rows |
|---|---:|
| `dbo.tTimeStamp` | 7,377,898 |
| `dbo.tTimeInOut` | 3,551,128 |
| `dbo.tTimeInOut_Data` | 1,420,276 |
| `dbo.tTimeInOut_AddLeave` | 726,536 |
| `dbo.tPayroll_Detail` | 147,670 |
| `dbo.tPayroll_Tax` | 147,619 |
| `dbo.tPayroll` | 147,616 |
| `dbo.tPayroll_Allowance` | 147,616 |
| `dbo.tPayroll_Welfare` | 88,692 |
| `dbo.tAutoPushTime_Tran_Manual` | 52,346 |
| `dbo.tTax91` | 22,105 |
| `service.AppSyncConfig` | 20,793 |
| `service.EmployeeMappingID` | 20,686 |
| `dbo.tSystem_Event` | 19,747 |
| `dbo.tEmployeePhoto` | 16,440 |
| `dbo.tPayroll_GLAccNoRow` | 15,290 |
| `dbo.tEmployee_LeaveQuota` | 12,087 |
| `customize.tSCC_TranferApprove` | 10,657 |
| `customize.tSCC_TranferEmp` | 10,657 |
| `customize.tSCC_TranferSite` | 10,657 |
| `dbo.tStage` | 9,560 |
| `dbo.tEmployee_RateP0x` | 8,773 |
| `dbo.tRequest` | 7,099 |
| `customize.tSCC_SelectFilter` | 6,647 |
| `customize.tSCC_PayAllowance` | 5,057 |
| `dbo.tRequest_byAdmin` | 4,074 |
| `customize.tSCC_SettingIncentive` | 3,400 |
| `dbo.tSendMail_Process` | 2,782 |
| `dbo.tEmployee_OtherCard` | 2,282 |
| `dbo.tPunishment` | 1,994 |
| `dbo.tPayroll_ColDef` | 1,790 |
| `dbo.tColDef_PayrollExport` | 1,584 |
| `dbo.tColDef_rEmployeeExportNew` | 871 |
| `dbo.tChangeset` | 734 |
| `dbo.tTimeInOut_ColDef` | 635 |
| `service.Request` | 629 |
| `dbo.tPayroll_GLAccNo` | 278 |
| `maspayroll.tPayroll_ColReport` | 260 |
| `service.PeriodSlip` | 186 |
| `dbo.tImportPlan` | 168 |
| `dbo.tColDef_rEmployeeExport` | 167 |
| `dbo.tPeriod_ChargeRate` | 150 |
| `dbo.tPMPeriod` | 150 |
| `dbo.tSYSOutPayMenu` | 113 |
| `dbo.tUser_PWDHistory` | 109 |
| `dbo.tReportNormal_Language` | 46 |
| `dbo.tTaxRate` | 32 |
| `dbo.tReportPayroll_FieldCaption` | 28 |
| `dbo.tEmployee_Children` | 10 |
| `dbo.tUserWebTimeCardPermission` | 10 |
| `dbo.tImport_Employee_MappingPreset` | 9 |
| `dbo.tEmployeeAbility` | 8 |
| `dbo.tRequest_OT_Process` | 8 |
| `dbo.tTax` | 8 |
| `dbo.tColDef_PayrollFormat` | 6 |
| `dbo.tImportTime_Mapping` | 5 |
| `dbo.tOTRequest_Time` | 5 |
| `dbo.tTimeInOut_T0xFormat` | 5 |
| `dbo.tData_PND1_Detail` | 3 |
| `dbo.tMODBill` | 3 |
| `customize.tSCC_PaySelectPeriod` | 2 |
| `customize.tSCC_SettingPayAllowance` | 2 |
| `dbo.tBillChargeRate` | 1 |
| `dbo.tTAX_Data` | 1 |
| `dbo.tTimeCard_HideCol` | 1 |
| `dbo.tTimeInOut_FieldCaption` | 1 |
| `license.MASLicense` | 1 |
| `billing.tAllowance` | 0 |
| `billing.tBillBook` | 0 |
| `billing.tClient` | 0 |
| `billing.tClientAllowance` | 0 |
| `billing.tContractor` | 0 |
| `billing.tContractorAllowance` | 0 |
| `billing.tInvoice` | 0 |
| `billing.tInvoiceAllowance` | 0 |
| `billing.tInvoiceDetail` | 0 |
| `billing.tInvoiceProjectCost` | 0 |
| `billing.tMultiCurrency` | 0 |
| `billing.tTimeSheetStamp` | 0 |
| `customize.TimeScan_BioStar` | 0 |
| `customize.tMOD_SettingIncentive` | 0 |
| `customize.tTropical_History_Incentive` | 0 |
| `dbo.tAddLeaveManagement` | 0 |
| `dbo.tApplication` | 0 |
| `dbo.tAssignBillRate` | 0 |
| `dbo.tAssignChargeRate` | 0 |
| `dbo.tAssignControlGoTo` | 0 |
| `dbo.tAssignOT` | 0 |
| `dbo.tAssignShifiWhirl` | 0 |
| `dbo.tAssignShift` | 0 |
| `dbo.tAssignShiftByWeekDay` | 0 |
| `dbo.tAssignShiftFromCalendar` | 0 |
| `dbo.tAutoPostSchedule` | 0 |
| `dbo.tAutoPostSchedule_TRM` | 0 |
| `dbo.tAutoPushTimeTransaction_Auto` | 0 |
| `dbo.tAutoPushTimeTransaction_MT` | 0 |
| `dbo.tBatchPVF` | 0 |
| `dbo.tBillPeriod` | 0 |
| `dbo.tBillSum_PeriodYM` | 0 |
| `dbo.tBillSummary` | 0 |
| `dbo.tCal_PVF` | 0 |
| `dbo.tCashAdvance` | 0 |
| `dbo.tColDef_rBILL` | 0 |
| `dbo.tCostAllocation` | 0 |
| `dbo.tCourseDetail` | 0 |
| `dbo.tCourseGeneration` | 0 |
| `dbo.tDL_tLeaveRequest` | 0 |
| `dbo.tDL_tTimeInOut` | 0 |
| `dbo.tEmployee_FirstFinance` | 0 |
| `dbo.tEmployeeExtraDetail` | 0 |
| `dbo.tEmployeeTitle_LeaveQuota` | 0 |
| `dbo.tImport_Allowances_MappingPreset` | 0 |
| `dbo.tImport_Leave_MappingPreset` | 0 |
| `dbo.tImport_Leave_MappingPreset_New` | 0 |
| `dbo.tImport_MappingPreset` | 0 |
| `dbo.tImport_WorkPlan_MappingPreset` | 0 |
| `dbo.tIncentive_Initial` | 0 |
| `dbo.tLeaveGroupDetail` | 0 |
| `dbo.tLeaveRequest` | 0 |
| `dbo.tLoan` | 0 |
| `dbo.tMOD_PostedBill` | 0 |
| `dbo.tMOD_PVF_REPORT` | 0 |
| `dbo.tOTHoliday` | 0 |
| `dbo.tOTRequest_Form` | 0 |
| `dbo.tOTRequest_Form_SHFPeriod` | 0 |
| `dbo.tOTx` | 0 |
| `dbo.tPayroll_BankHolding` | 0 |
| `dbo.tPayroll_GLAccNo_ByEmployee` | 0 |
| `dbo.tPayroll_GLAccNo_ByEmployee_SETDATA` | 0 |
| `dbo.tPayroll_GLAccNoRow_ByEmployee` | 0 |
| `dbo.tPayroll_GLAccNoRow_GroupType` | 0 |
| `dbo.tPayroll_GLAccNoRow_GroupType_ByEmployee` | 0 |
| `dbo.tPayroll_GLAccType_ByEmployee` | 0 |
| `dbo.tPayroll_T0xFormat` | 0 |
| `dbo.tPayrollFilter` | 0 |
| `dbo.tPVF_ColDef` | 0 |
| `dbo.tRC_Application` | 0 |
| `dbo.tReim` | 0 |
| `dbo.tReimRef` | 0 |
| `dbo.tReward` | 0 |
| `dbo.tRule_Incentive` | 0 |
| `dbo.tShiftBreak` | 0 |
| `dbo.tShiftLateIn` | 0 |
| `dbo.tShiftLateOut` | 0 |
| `dbo.tShiftOT` | 0 |
| `dbo.tSiteUpdatePlan` | 0 |
| `dbo.tSuspend_Request` | 0 |
| `dbo.tTimeCard_Permission` | 0 |
| `dbo.tTimeSheet` | 0 |
| `dbo.tTimeSheet_InputDataList` | 0 |
| `dbo.tTimeSheet_MultiPeriod` | 0 |
| `dbo.tWF_AssignQuota` | 0 |
| `dbo.tWF_Loan` | 0 |
| `dbo.tWF_LoanPayment` | 0 |
| `dbo.tWF_Record` | 0 |
| `dbo.tWorkPeriod` | 0 |
| `dbo.tYTD_Attendance` | 0 |
| `payroll.KT20A_FieldCaption` | 0 |
| `payroll.KT20A_FieldCaption_ByYear` | 0 |
| `service.Locations` | 0 |

## Log/Audit (48)

Audit trail / change history tables (`tLOG_*`, `tLog_*`, `Log_*`). Not needed for functional seeding; useful only if debugging historical changes.

| Schema.Table | Production rows |
|---|---:|
| `dbo.tLOG_EmployeeGUID` | 1,984,978 |
| `dbo.tLOG_OTApprove` | 1,235,090 |
| `dbo.tLOG_EmployeeText` | 1,077,517 |
| `dbo.tLOG_TimeInOut` | 402,565 |
| `dbo.tLOG_Payroll` | 100,072 |
| `dbo.tLogAddLeaveManagement` | 81,606 |
| `dbo.tLOG_UserLogon_Outpay` | 10,399 |
| `dbo.tLOG_OTClaimApprove` | 5,973 |
| `dbo.tLog_OTClaim` | 5,949 |
| `dbo.tLOG_UpdateWork_BU` | 5,225 |
| `customize.tLog_Tranfersite` | 4,070 |
| `dbo.tLOG_DeleteImportTime` | 3,201 |
| `dbo.tLOG_TimeInOutDelete` | 2,861 |
| `dbo.tLOG_UpdateWork_Rate` | 2,504 |
| `dbo.tLOG_BU` | 1,266 |
| `service.Log_PaySlip` | 907 |
| `dbo.tLogKeyName` | 461 |
| `dbo.tLOG_UpdateWork_Title` | 344 |
| `dbo.tLog_ImportPlan` | 338 |
| `service.Log_Registered` | 265 |
| `customize.tMOD_LogSetting` | 179 |
| `dbo.tLOG_DeleteEmployee` | 86 |
| `dbo.tLOG_Update_Employee` | 72 |
| `dbo.tLogRequest_OT_Process` | 35 |
| `dbo.tLOG_CloseCarryOption` | 16 |
| `dbo.tLOG_BU_KeyName` | 12 |
| `dbo.tLOG_PDF` | 10 |
| `dbo.tLog_Request` | 3 |
| `dbo.tLog_AssignWCD` | 1 |
| `billing.tActivityLogs` | 0 |
| `dbo.tAutoPost_Log` | 0 |
| `dbo.tDL_tLOG_TimeInOut` | 0 |
| `dbo.tDL_tUser_LoginStat` | 0 |
| `dbo.tIncentive_Log` | 0 |
| `dbo.tLog_AssignShift` | 0 |
| `dbo.tLog_Batch_AutoPost_TimeSheet` | 0 |
| `dbo.tLOG_Course` | 0 |
| `dbo.tLog_EditIncentive` | 0 |
| `dbo.tLOG_ProcedureExec` | 0 |
| `dbo.tLog_RetroClaim` | 0 |
| `dbo.tLOG_tProjectChargeRate` | 0 |
| `dbo.tLOG_UpdateWork_Level` | 0 |
| `dbo.tLogImport_Attendance` | 0 |
| `dbo.tLOGMidnight_OTClaimApprove` | 0 |
| `dbo.tTempTransfer_Log` | 0 |
| `dbo.tTimeSheet_Log` | 0 |
| `dbo.tUser_LoginStat` | 0 |
| `service.Log_50Wtc` | 0 |

## Temp/Staging (123)

Scratch/staging tables used by import batch jobs and mobile sync (`tTemp_*`, `service.tTemp_*`). Safe to leave empty in a dev seed; repopulated by the jobs that use them.

| Schema.Table | Production rows |
|---|---:|
| `dbo.tTempBatchTime` | 231,794 |
| `dbo.tTempBatch_TimeInOut` | 75,864 |
| `dbo.tTemp_Access_AutoPushTime_MT` | 52,346 |
| `dbo.tTemp_Leave` | 36,101 |
| `dbo.tTemp_AutoPushTime_I_T02_Reformatted` | 24,351 |
| `service.tTemp_TimeAttendances` | 17,916 |
| `dbo.tTemp_SCCDB01_SYN_01` | 15,266 |
| `service.tTemp_Overtimes` | 15,154 |
| `dbo.tTemp_AutoPushTime_MT` | 5,717 |
| `dbo.tTemp_ImportTime_SCC` | 5,717 |
| `dbo.tTemp_COM133_EmpExport` | 5,045 |
| `dbo.tTempBatchEmp` | 5,039 |
| `dbo.tTemp_COM1000080311_EmpExport` | 5,038 |
| `dbo.tTemp_COM100011613_EmpExport` | 4,938 |
| `dbo.tTemp_COM100009404_EmpExport` | 4,927 |
| `dbo.tWorkCalendarDetailTemp` | 3,652 |
| `dbo.tTemp_COM100009403_EmpExport` | 2,200 |
| `dbo.tTemp_COM100011658_EmpExport` | 1,815 |
| `service.tTemp_LeaveBalance` | 1,708 |
| `service.tTemp_Leaves` | 1,193 |
| `service.tTemp_OTRequest` | 813 |
| `dbo.tTemp_COM100009403_I_T01` | 700 |
| `dbo.tTemp_COM100011613_I_T01` | 700 |
| `dbo.tTemp_COM100011613_I_T01_Reformatted` | 700 |
| `service.tTemp_OTApproved` | 539 |
| `dbo.tTemp_SCCWEB01_I_T01` | 516 |
| `dbo.tTemp_SCCWEB01_I_T01_Reformatted` | 516 |
| `dbo.tTemp_WORAVUT_I_T01` | 454 |
| `dbo.tTemp_WORAVUT_I_T01_Reformatted` | 454 |
| `dbo.tTemp_COM133_I_T01` | 374 |
| `dbo.tTemp_COM133_I_T01_Reformatted` | 374 |
| `dbo.tTemp_SCCDB01_I_T01` | 204 |
| `dbo.tTemp_SCCDB01_I_T01_Reformatted` | 204 |
| `service.tTemp_LeaveFlow` | 161 |
| `service.tTemp_OTFlow` | 161 |
| `service.tTemp_OTNonRequest` | 131 |
| `service.tTemp_LeaveRequest` | 128 |
| `service.tTemp_LeaveApproved` | 78 |
| `dbo.tTemp_COM100006556_SYN_01` | 44 |
| `dbo.tTemp_COM100009404_I_T01` | 30 |
| `dbo.tTemp_COM100009404_I_T01_Reformatted` | 30 |
| `customize.tSCC_TempApproveEmail` | 26 |
| `service.tTemp_WorkFlow` | 24 |
| `service.tTemp_LeaveNonRequest` | 23 |
| `dbo.tTemp_SCCWIN10_EmpExport` | 21 |
| `service.tTemp_LeaveTypes` | 21 |
| `dbo.tTemp_COM100009404_SYN_01` | 19 |
| `dbo.tTemp_SCCWIN10_SYN_01` | 15 |
| `dbo.tTemp_WORAVUT_SYN_01` | 15 |
| `dbo.tTemp_COM100012952_SYN_01` | 13 |
| `dbo.tTemp_COM133_SYN_01` | 13 |
| `dbo.tTemp_SCCWEB01_SYN_01` | 13 |
| `dbo.tTemp_COM1000129521_SYN_01` | 5 |
| `dbo.tTemp_COM100005450_SYN_01` | 1 |
| `dbo.tTemp_COM100006556_Incentive` | 1 |
| `dbo.tTemp_COM100009403_SYN_01` | 1 |
| `dbo.tTemp_COM1000114628_SYN_01` | 1 |
| `dbo.tTemp_COM100011613_Incentive` | 1 |
| `dbo.tTemp_COM100011658_SYN_01` | 1 |
| `dbo.tTemp_COM100014629_SYN_01` | 1 |
| `dbo.tTemp_COM133_Incentive` | 1 |
| `dbo.tTemp_DESKTOPCPFG9DI_SYN_01` | 1 |
| `dbo.tTemp_Khemchapasorn_SYN_01` | 1 |
| `dbo.tTemp_PICHA_EmpExport` | 1 |
| `dbo.tTemp_SCCDB01_Incentive` | 1 |
| `dbo.tTemp_Timeinout_01` | 1 |
| `dbo.tTemp_Wanthida_SYN_01` | 1 |
| `dbo.tTemp_webadmin_SYN_01` | 1 |
| `service.tTemp_TimeClocks` | 1 |
| `billing.tTemp_TimeSheetStamp` | 0 |
| `customize.tSCC_TempApprove` | 0 |
| `dbo.tAssignTemplateSHF` | 0 |
| `dbo.tAssignTemplateWCD` | 0 |
| `dbo.tEmployee_Temp` | 0 |
| `dbo.TempTableBreakSHF` | 0 |
| `dbo.tTemp_Access_AutoPushTime_Auto` | 0 |
| `dbo.tTemp_AutoPushTime_Auto` | 0 |
| `dbo.tTemp_AutoPushTime_I_T01_Reformatted` | 0 |
| `dbo.tTemp_COM100006556_APS` | 0 |
| `dbo.tTemp_COM100006556_Insentive` | 0 |
| `dbo.tTemp_COM100009403_I_T01_Reformatted` | 0 |
| `dbo.tTemp_COM100009404_APS` | 0 |
| `dbo.tTemp_COM100009404_Insentive` | 0 |
| `dbo.tTemp_COM1000114628_I_102` | 0 |
| `dbo.tTemp_COM1000114628_I_103` | 0 |
| `dbo.tTemp_COM1000114628_I_103_1` | 0 |
| `dbo.tTemp_COM1000114628_I_104` | 0 |
| `dbo.tTemp_COM1000114628_I_609` | 0 |
| `dbo.tTemp_COM100011613_APS` | 0 |
| `dbo.tTemp_COM100011613_Insentive` | 0 |
| `dbo.tTemp_COM100011613_SYN_01` | 0 |
| `dbo.tTemp_COM133_APS` | 0 |
| `dbo.tTemp_COM133_Insentive` | 0 |
| `dbo.tTemp_Mode20_Reformatted` | 0 |
| `dbo.tTemp_Mode20_Scan` | 0 |
| `dbo.tTemp_PayrollLeave` | 0 |
| `dbo.tTemp_PHICHAC_APS` | 0 |
| `dbo.tTemp_PHICHAC_I_102` | 0 |
| `dbo.tTemp_PHICHAC_I_103` | 0 |
| `dbo.tTemp_PHICHAC_I_103_1` | 0 |
| `dbo.tTemp_PHICHAC_I_104` | 0 |
| `dbo.tTemp_PHICHAC_I_609` | 0 |
| `dbo.tTemp_PHICHAC_Insentive` | 0 |
| `dbo.tTemp_PICHA_APS` | 0 |
| `dbo.tTemp_PICHA_Insentive` | 0 |
| `dbo.tTemp_SCCDB01_APS` | 0 |
| `dbo.tTemp_SCCDB01_Insentive` | 0 |
| `dbo.tTemp_SCCWIN10_APS` | 0 |
| `dbo.tTemp_SCCWIN10_Insentive` | 0 |
| `dbo.tTemp_SSODetail` | 0 |
| `dbo.tTemp_SSOSum` | 0 |
| `dbo.tTemp_TimeStampScan` | 0 |
| `dbo.tTemp_WORAVUT_APS` | 0 |
| `dbo.tTemp_WORAVUT_Insentive` | 0 |
| `dbo.tTempCalTime_SCCWEB01_01` | 0 |
| `dbo.tTempEmployee_Incentive` | 0 |
| `dbo.tTempGet_TimeMode20` | 0 |
| `dbo.tTempImportPlan` | 0 |
| `dbo.tTempTimeInOut` | 0 |
| `dbo.tTempTransfer` | 0 |
| `dbo.tTraining_Temp` | 0 |
| `rosetta.Temp_TimeStamp` | 0 |
| `service.tTemp_FlowTeam` | 0 |

## System/Internal (4)

ORM/migration bookkeeping tables (EF migration history, ticket log). Not business data.

| Schema.Table | Production rows |
|---|---:|
| `dbo._DBMigrationHistory` | 2,825 |
| `dbo._DBTicketLg` | 84 |
| `dbo.sysdiagrams` | 3 |
| `dbo.__MigrationHistory` | 1 |

## Other/Unclear (41)

Heuristic gave a tie or no signal (small junction tables, field-caption tables, or empty tables with ambiguous shape). Needs a human look before trusting the category.

| Schema.Table | Production rows |
|---|---:|
| `dbo.tPUPInstallation` | 261 |
| `dbo.tManager_Delegated` | 143 |
| `dbo.tSYS_WebMenu` | 126 |
| `dbo.tSYSTRMMenu` | 69 |
| `dbo.tTimeInOut_RowName` | 6 |
| `dbo.tProject_Tax` | 5 |
| `dbo.tProjectChargeRate` | 5 |
| `dbo.tCalendarYear` | 3 |
| `service.tAssignMobileFunction` | 3 |
| `dbo.tProjectChargeRate_Welfare` | 2 |
| `dbo.tAssignWorkCalendar` | 1 |
| `dbo.tAutoGenID` | 1 |
| `dbo.tBU_FieldCaption` | 1 |
| `dbo.tEmployee_FieldCaption` | 1 |
| `dbo.tL0x_FieldCaption` | 1 |
| `dbo.tOther_FieldCaption` | 1 |
| `dbo.tPreset_Leave` | 1 |
| `dbo.tSYS_LoadEmployeeDefault` | 1 |
| `dbo.tWF_FieldCaption` | 1 |
| `billing.tCountry` | 0 |
| `billing.tProjectCost` | 0 |
| `dbo.tAnnouncement` | 0 |
| `dbo.tAssignUserRole_Advance` | 0 |
| `dbo.tAutoPushTime_Tran_Auto` | 0 |
| `dbo.tBatch_ScheduleReload` | 0 |
| `dbo.tCourseTaking` | 0 |
| `dbo.tDetailAssignShiftWhirl` | 0 |
| `dbo.tDL_tUser` | 0 |
| `dbo.tEmployeeFilter` | 0 |
| `dbo.tEmployeeFilter_TRM` | 0 |
| `dbo.tLeaveGroup` | 0 |
| `dbo.tOTCompensate_Permission` | 0 |
| `dbo.tPeriod_Retro` | 0 |
| `dbo.tRC_WorkPlace` | 0 |
| `dbo.tRequest_WorkAgeLock` | 0 |
| `dbo.tSYSJob` | 0 |
| `dbo.tSysOutPayMenuFav` | 0 |
| `dbo.tSysTRMMenuFav` | 0 |
| `dbo.tTimeCard_Remark` | 0 |
| `payroll.KT20A_FieldConfiguration_ByYear` | 0 |
| `service.Period50Wtc` | 0 |

## Known Limits

- Source row counts are production values from `database/metadata/export-20260713/05_row_counts.csv`, not a live query — treat as a snapshot, not current truth.
- The CSV has 572 rows against 570 live tables seen via `mssql-mas` `list_tables`; the 2-row difference wasn't reconciled (likely a dropped/renamed table or a near-duplicate entry) and doesn't affect the category breakdown materially.
- `Other/Unclear` (41 tables) is the category most worth a manual pass, particularly remaining `t*_FieldCaption` and small junction tables — most look like true config tables on inspection, the heuristic just couldn't separate them cleanly from transaction-shaped tables.
- Only 10 tables were manually cross-checked and corrected (see Method, step 3). Any other `Master/Config` vs `Transaction/Fact` call driven by a name-keyword collision should be treated as low-confidence until checked the same way.
- For the finer-grained master/config breakdown by business domain (org structure, employee enums, payroll reference, etc.) and the seed-truncation gap analysis, see [09-data-count-summary.md](./09-data-count-summary.md) — that file only covers the tables relevant to master-data seeding, not the full catalog.

