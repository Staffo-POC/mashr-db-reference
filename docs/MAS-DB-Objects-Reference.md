# 📚 MAS HR Database — Objects Reference

> ระบบ **HR + Payroll (เงินเดือน) + Time Attendance (ลงเวลา)** — เอกสารสรุป Tables / Views / Stored Procedures ทั้งหมด
>
> Server: `localhost` · Database: `MAS` · สำรวจเมื่อ 2026-07-21

---

## 🗺️ ภาพรวม (Overview)

ฐานข้อมูลนี้มีทั้งหมด **~1,400 objects** แบ่งเป็น:

| ประเภท | จำนวน |
|--------|:-----:|
| 📋 Tables | **570** |
| 👁️ Views | **437** |
| ⚙️ Stored Procedures | **399** |

### แบ่งตาม Schema

| Schema | หน้าที่ | Tables | Views | Procs |
|--------|---------|:---:|:---:|:---:|
| **`dbo`** | แกนหลัก HR / Payroll / Time | ~430 | ~320 | ~330 |
| **`billing`** | วางบิล / ออกใบแจ้งหนี้ (Outsource) | 20 | 4 | 7 |
| **`customize`** | ปรับแต่งเฉพาะลูกค้า (SCC · MOD · Tropical) | 19 | 36 | 28 |
| **`outpay_form`** | ตัวเลือกฟอร์มเอกสารส่งราชการ | — | 12 | — |
| **`outpay_report`** | เอกสารราชการ (ภงด. · ปกส. · สลิป · PVF) | — | 43 | — |
| **`payroll`** | ฟอร์มภาษี KT20A · งวดจ่าย | 6 | 8 | 14 |
| **`maspayroll`** | กระทบยอด (Reconcile) | 1 | 1 | 2 |
| **`service`** | เชื่อมต่อ Mobile App (ลา / OT / สลิป) | 27 | 6 | 27 |
| **`rosetta`** | เครื่องสแกนเวลา / ควบคุมประตู (Rosetta2) | 8 | — | — |
| **`license`** | ระบบ License | 5 | — | — |

> **ศัพท์ที่พบบ่อย:** `t` = table · `v` = view · `s`/`sp` = stored procedure · `SCC` `MOD` `Trop` = โค้ดลูกค้าเฉพาะราย · `COMxxxx` / ชื่อเครื่อง = objects ที่ระบบ generate อัตโนมัติแยกตาม tenant

---

## 📋 TABLES (570)

### 👤 ข้อมูลพนักงาน (Employee Master)
| Table | หน้าที่ |
|-------|---------|
| `tEmployee` | ตารางหลักพนักงาน (โปรไฟล์, สังกัด, อัตราจ้าง) |
| `tEmployee_Children` | บุตรของพนักงาน (ใช้ลดหย่อนภาษี) |
| `tEmployeeBank` | บัญชีธนาคารสำหรับโอนเงินเดือน |
| `tEmployeePhoto` | รูปพนักงาน |
| `tEmployeeStatus` / `tEmployeeStatusGroup` | สถานะพนักงาน (ทำงาน/ลาออก/ทดลองงาน) |
| `tEmployeeLevel` · `tEmployeeTitle` · `tEmployeeType1-3` | ระดับ / ตำแหน่ง / ประเภทพนักงาน |
| `tEmployee_LeaveQuota` · `tEmployeeWork_Quota` | โควตาการลา / โควตางาน |
| `tEmployeeAbility` · `tEmployeeExtraDetail` | ความสามารถ / ข้อมูลเสริม |

### 🏢 โครงสร้างองค์กร (Organization)
| Table | หน้าที่ |
|-------|---------|
| `tCompany` | บริษัท |
| `tProject` | โครงการ / หน่วยงานคิดต้นทุน |
| `tBU1` · `tBU2` · `tBU3` · `tBU4` | Business Unit 4 ระดับ (ฝ่าย → แผนก → ...) |
| `tCostCenter` · `tCostCenter_BU_Mapping` | ศูนย์ต้นทุน |
| `tSiteTR` · `tSiteRate` | ไซต์งาน / อัตราตามไซต์ |
| `tManager` · `tManager_Delegated` | หัวหน้า / ผู้รับมอบอำนาจอนุมัติ |
| `tGLAccount` · `tGLAccount_MapField` | ผังบัญชี (เชื่อม Payroll → บัญชี) |

### 📅 ลงเวลา & กะการทำงาน (Time & Shift)
| Table | หน้าที่ |
|-------|---------|
| `tTimeInOut` · `tTimeInOut_Data` | เวลาเข้า-ออกที่ประมวลผลแล้ว |
| `tTimeStamp` · `tTimeSheet` | ข้อมูลตอกบัตรดิบ / ไทม์ชีต |
| `tShift` · `tShiftBreak` · `tShiftOT` · `tShiftPattern` | นิยามกะ / พักเบรก / OT / รูปแบบกะ |
| `tWorkCalendar` · `tWorkCalendarDetail` | ปฏิทินการทำงาน |
| `tAssignShift` · `tAssignShiftByWeekDay` · `tAssignShiftFromCalendar` | การจัดกะให้พนักงาน |
| `tFlagWork` · `tOTHoliday` · `tCalendarYear` | ธงสถานะทำงาน / OT วันหยุด / ปีปฏิทิน |

### 🌴 การลา (Leave)
| Table | หน้าที่ |
|-------|---------|
| `tLeaveRequest` | ใบลา |
| `tLeaveGroup` · `tLeaveGroupDetail` | กลุ่มประเภทการลา / สิทธิ |
| `tAddLeaveManagement` · `tPreset_Leave` | จัดการสิทธิลาพิเศษ / ค่าตั้งต้น |
| `tVacationLockFlag` · `tLeaveReasonOption` | ล็อกวันลาพักร้อน / ตัวเลือกเหตุผล |

### 💰 เงินเดือน & ภาษี (Payroll & Tax)
| Table | หน้าที่ |
|-------|---------|
| `tPayroll` · `tPayroll_Detail` | หัว/รายละเอียดการจ่ายเงินเดือน |
| `tPayroll_Allowance` · `tPayroll_Welfare` · `tPayroll_Tax` | เงินเพิ่ม / สวัสดิการ / ภาษี |
| `tPayroll_GLAccNo*` (หลายตาราง) | ผูกรายการเงินเดือนเข้าบัญชี GL |
| `tCal_PVF` · `tBatchPVF` | กองทุนสำรองเลี้ยงชีพ |
| `tLoan` · `tCashAdvance` · `tReim` · `tReimType` | เงินกู้ / เบิกล่วงหน้า / เบิกจ่าย |
| `tTax` · `tTax91` · `tTaxRate` · `tData_PND1_Detail` | ภาษีเงินได้ / ภงด.91 / อัตราภาษี |
| `tSSO_Account` · `tSSO_Data` · `tSSO_Hospital` | ประกันสังคม |

### ✅ คำขอ & Workflow (Approval)
| Table | หน้าที่ |
|-------|---------|
| `tRequest` · `tRequestType` · `tRequest_byAdmin` | คำขอ (ลา/OT/เบิก) |
| `tFlow` · `tFlowPath` · `tSystemFlow` · `tUse_Flow` | เส้นทางอนุมัติ (Workflow engine) |
| `tApproverGroup` · `tApproverList` · `tSelectApprover` | กลุ่ม/รายชื่อผู้อนุมัติ |
| `tWF_Record` · `tWF_Loan` · `tWF_LoanPayment` | บันทึก Workflow / เงินกู้-ผ่อน |

### 🔐 ผู้ใช้ & สิทธิ์ (Users & Permissions)
| Table | หน้าที่ |
|-------|---------|
| `tUser` · `tUserGroup` · `tUserAD` | ผู้ใช้ระบบ / กลุ่ม / เชื่อม Active Directory |
| `tAssignUserRole` · `tSYSUserRole` | บทบาท (Role) |
| `tUserBUPermission` · `tUserProjectPermission` · `tUserMenuPermission` … | สิทธิ์เข้าถึงตาม BU / โครงการ / เมนู |

### 🎓 ฝึกอบรม & อื่นๆ
| Table | หน้าที่ |
|-------|---------|
| `tCourse` · `tCourseDetail` · `tCourseTaking` · `tTraining*` | หลักสูตร / การเข้าอบรม |
| `tDecoration` · `tDecorationGroup` · `tAward_Type` | เครื่องราชอิสริยาภรณ์ / รางวัล |
| `tPunishment` · `tPENALTY_Type` · `tGUILTY_Type` | วินัย / โทษ |

### 🗂️ Logs, System & Temp
- **`tLOG_*`** (~50 ตาราง) — บันทึกการเปลี่ยนแปลงทุกส่วน (payroll, time, employee, OT, BU, การลบ)
- **`tSYS*` · `tSysConfig` · `tSysParm`** — ค่าตั้งค่าระบบ / เมนู / เวอร์ชัน
- **`tTemp_*`** (~90 ตาราง) — ตารางชั่วคราวตั้งชื่อตาม company/เครื่อง เช่น `tTemp_COM100009403_*`, `tTemp_SCCDB01_*` (ข้อมูลประมวลผลระหว่างทาง ไม่ใช่ข้อมูลถาวร)

---

## 👁️ VIEWS (437)

### 👤 พนักงาน
`vEmployee` · `vEmployee_Basic` · `vEmployee_Payroll` · `vEmployee_Profile` · `vEmployee_Export` · `vEmployee_Leave` · `vEmployee_ForBank` · `vEmployee_SSO`
→ รวมข้อมูลพนักงานพร้อม master ต่างๆ ให้พร้อมแสดง/ส่งออก

### 📅 ลงเวลา & กะ
`vTimeInOut` · `vTimeInOut_Attendance` · `vTimeInOut_LoadData` · `vTimeInOut_Group` · `vTimeAttendance` · `vTimeStamp` · `vAssignShift*` · `vMatchAssignShift`

### 🌴 การลา
`vLeaveRequest` · `vBalanceLeave` · `vBalanceLeaveCarry` · `vBalanceLeaveQuota` · `vEmployeeLeaveInfo` · `vSumAllLeave_YTD`

### 💰 เงินเดือน
`vPayroll` · `vPayroll_detail` · `vPayroll_Bank` · `vPayroll_ExportData` · `vMTDPayroll` (Month-to-date) · `vYTDPayroll` (Year-to-date) · `vPayroll_GenPND1` · `vPayroll_GenPND3` · `vGLAccount_*`

### 📄 เอกสารราชการ — `outpay_report`
| View | เอกสาร |
|------|--------|
| `vTaxPND1` · `vTaxPND1A` | ภ.ง.ด.1 / 1ก (ภาษีหัก ณ ที่จ่าย) |
| `vTax91_Report` · `vTax91_ReportDetail` | ภ.ง.ด.91 |
| `vSSO1_10` · `vSSO1_10_Detail` · `vExport_SSO_File` | ประกันสังคม (สปส.1-10) |
| `vPVF` | กองทุนสำรองเลี้ยงชีพ |
| `vPayroll_Slip` | สลิปเงินเดือน |
| `vKT20A_*` | หนังสือรับรองหัก ณ ที่จ่าย (50 ทวิ / KT20A) |

### 🔄 Workflow
`vWorkFlow_LeaveSystem` · `vWorkFlow_OTSystem` · `vWorkFlow_ExpenseSystem` · `vWorkFlow_CarSystem` · `vWorkFlow_BenefitSystem` · `vWorkFlow_TimeSystem`

### 📱 Mobile — `service`
`vOvertimes` · `vTimeAttendances` · `vPaySlipsPrepare` · `vPaySlipsSending` · `vSlipMobile`

### 📝 Logs
`vLOG_Employee_*` · `vLog_Payroll` · `vLOG_TimeInout` · `vLog_Update_Employee`

> ⚠️ **View ที่ generate อัตโนมัติแยก tenant/เครื่อง:** จำนวนมากลงท้ายด้วยชื่อบริษัท/เครื่อง เช่น `vEmployee_Profile_COM133`, `vTimeInOut_LoadFilter_SCCDB01`, `vNonWorking_Holiday_01_*` — สร้างโดย proc ตระกูล `sCreateView_*` / `sCreate_v*` (ดูหมวด Procedures)

---

## ⚙️ STORED PROCEDURES (399)

### 💰 คำนวณเงินเดือน & ภาษี — `sCAL_*` (หัวใจระบบ)
| Procedure | หน้าที่ |
|-----------|---------|
| `sCAL_ALL` · `sCAL_ALL_Payroll` · `sCAL_ALL_TOTAL_PAYROLL` | คำนวณเงินเดือนทั้งหมด |
| `sCAL_TAX` · `sCAL_TAX_ByProject` · `sCAL_TAX_WithHolding` | คำนวณภาษี |
| `sCalTaxByMonth*` (หลายตัว) | คำนวณภาษีรายเดือน (รวมเคสลาออก/40(2)) |
| `sTaxReductB`–`sTaxReductH` (+`40_2`) | ขั้นตอนหักลดหย่อนภาษี |
| `sCAL_PVF` · `sCal_RatePVF_Period` | กองทุนสำรองเลี้ยงชีพ |
| `sCAL_SSOCT` | ประกันสังคม |
| `sCAL_Leave` · `sCAL_Leave_New` | คิดยอดการลา |
| `sCAL_BILL` · `sCAL_PaymentCharge` | คำนวณค่าวางบิล |

### 🔁 งานแบบกลุ่ม — `sBatch_*`
`sBatch_Cal_All` · `sBatch_AutoPost_TimeSheet` · `sBatch_Resign` · `sBatch_Probation` · `sBatch_ClosePeriod_Year` / `sBatch_UnClosePeriod_Year` · `sBatch_CarryExpire` · `sBatch_fEmployee*`
→ รันประมวลผลทั้งบริษัท / ทั้งงวด

### 🏗️ สร้าง View & Data อัตโนมัติ — `sCreate_v*` / `sCreateView_*`
`sCreate_vYTDPayroll` · `sCreate_vMTDsumPayroll` · `sCreate_vTimeAttendance` · `sCreate_vTax91_Report` · `sCreateView_vEmployee_Profile` · `sCreate_vLOG_Employee`
→ สร้าง view รายงานแบบ dynamic (จึงเกิด view ที่มี suffix ตาม tenant)

### 📅 ลงเวลา
`sPushTimeInOut` (+`_Mode20`) · `sMatchingShift` · `sMatchingTime` · `sMatchingDuty` · `sFullFillTime*` · `sImportTimeStamp` · `sReCalLateIn` / `sReCalLateOut` · `sReCalFlagWork`

### ➕ เพิ่ม Master อัตโนมัติ — `sAutoAddNew*`
`sAutoAddNewEmployee` · `sAutoAddNewBU` · `sAutoAddNewProject` · `sAutoAddNewSite` · `sAutoAddNewTitle` · `sAutoAddNewCostCenter` …
→ สร้าง master ใหม่ตอน import ข้อมูล

### 🌴 การลา & โควตา
`sAddLeave` · `sAddLeaveCarry` · `sCheckLeaveQuota` · `sCheckExceedAbsent` · `sRecalculateCarry` · `sLeaveQuotaBegin`

### 📱 Service (Mobile App) — `service.sCreate_*`
`sCreate_Leaves` · `sCreate_Overtimes` · `sCreate_WorkFlow` · `sCreate_vPaySlipsSending` · `sPaySlips` · `sCreateVSlip`
→ เตรียมข้อมูลป้อนแอปมือถือ

### 🧩 customize (ลูกค้าเฉพาะราย) — SCC · MOD · Tropical
`sMOD_SCC_CalIncentive` · `sMOD_SCC_CalHousing` · `sMOD_SCC_IncentivePayroll` · `sMOD_SCC_TRM` · `sMOD_Trop_Incentive` · `sBatch_UpdateSite_SCC`
→ ตรรกะเงินจูงใจ / ค่าที่พัก / โยกไซต์ เฉพาะลูกค้า

### 🛠️ System
`sSYS_UpdateDatabaseVersion` · `sSYS_UpdateOutPayVersion` · `sRefreshViewAll` · `sGenID` · `sLOG_InsProcedureExec`

---

## 🔎 ขั้นถัดไป (ถ้าต้องการเจาะลึก)

- **ดูคอลัมน์จริงของตาราง** → `describe_table tEmployee`
- **ดูพารามิเตอร์ของ proc** → `describe_procedure sCAL_ALL`
- **ไล่ flow การรันเงินเดือน 1 งวด** ว่าเรียก proc ตัวไหนตามลำดับ
- **ทำ ER diagram / data dictionary** เต็มรูปแบบต่อจากเอกสารนี้

---

*เอกสารนี้เป็นภาพรวมเชิงหมวดหมู่ (categorized overview) ไม่ได้ไล่ครบทุก object เนื่องจากมีจำนวนมาก — objects ที่เป็น `tTemp_*`, `_COMxxxx`, `_<machine>` ส่วนใหญ่เป็นของที่ generate/ชั่วคราวตาม tenant*
