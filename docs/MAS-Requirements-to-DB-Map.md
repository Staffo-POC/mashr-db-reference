# 🗺️ Requirement → DB Object Map (จากประชุม 6 & 16 ก.ค. 2026)

> แปลง requirement/pain point แต่ละเรื่องที่คุยกัน → **object ใน DB ที่ต้องไปศึกษา** เพื่อไล่ learning curve ให้ตรงจุด
> ⭐ = ความยาก/ความสำคัญในการเรียนรู้ (ยิ่งมากยิ่งเป็นแกนที่ต้องเข้าใจก่อน) · คู่กับ [Process Flow](MAS-Payroll-Process-Flow.md)

---

## 🎯 สรุปก่อน: 6 กลุ่มงาน + ลำดับที่ควรเรียน

| ลำดับเรียน | กลุ่ม | ทำไมต้องก่อน/หลัง |
|:--:|------|------------------|
| **1** | ⏱️ เวลา + ไซต์ + กะ (Time/Site/Shift) | เป็นต้นน้ำ กระทบทุกอย่างข้างล่าง — ยากสุด |
| **2** | ✅ Workflow / อนุมัติ (OT, โอนย้าย, ลา) | ทุก transaction วิ่งผ่านตัวนี้ |
| **3** | 💰 องค์ประกอบเงิน (incentive/เบี้ยขยัน, ลา) | ต่อจากเวลา → เข้า payroll |
| **4** | 👤 ทะเบียนพนักงาน + เอกสาร HR (ใบเตือน) | master data ค่อนข้างนิ่ง เรียนแทรกได้ |
| **5** | 📤 Output & ราชการ (slip, แบงก์, ปกส., ภาษี 50ทวิ) | ปลายน้ำ อ่านอย่างเดียวเป็นส่วนใหญ่ |
| **6** | 🚀 Performance & Integration (ช้า, n8n/kafka) | เชิงสถาปัตยกรรม แยกจาก schema |

---

## กลุ่ม 1 — ⏱️ เวลา / โอนย้ายไซต์ / กะ ⭐⭐⭐⭐⭐

### 1.1 โอนย้ายหน่วยงาน/ไซต์ (1–8 ไป site A, 9–30 site B, ย้ายไป-กลับในรอบ)
> **ปัญหาหลัก:** "ย้ายไป-ย้ายกลับในรอบเดียวไม่ได้" + "ระบบมองว่าไปทำอีก site แต่ตัวยังอยู่ที่เดิม?"

| ประเภท | Object | บทบาท |
|--------|--------|-------|
| Table | `tTempTransfer` · `tTempTransfer_Log` | บันทึกการโอนย้าย + ประวัติ (จุดที่ต้องดูว่ารองรับหลายช่วง/รอบไหม) |
| Table | `tTimeInOut.Site_ID` + `Replace*` (`ReplaceTo`, `ReplaceType`, `ReplaceBU1-4`) | ไซต์รายวัน + กลไก "ย้ายเวลา" (ReplaceType=1 ย้าย, 0 ไม่ย้าย) |
| Table | `tSiteTR` · `tSiteRate` · `tAssignControlGoTo` | ไซต์ / เรตตามไซต์ / ควบคุมการไปไซต์ |
| View | `vTempTransfer_Site_Department` · `vTemp_Transfer_List` · `vTempTransfer_Log` | สรุปการโอนย้าย |
| Proc | `sTransferEmployee` · `sTransferEmployee_Master` · `sTransferTimeInout` · `sUpdateTimeInoutSiteRate` | ตัวย้ายจริง (ย้าย master vs ย้ายเฉพาะช่วงเวลา) |
| Proc | `sMatchingDutyOfSite` · `sMOD_SCC_LastSiteScan` | จับว่าสแกนอยู่ไซต์ไหน |
| Table | `tPeriod_Retro` · Proc `sAdjustWagerate_Retro` | **โอนย้ายย้อนหลัง / มีผลทันที** vs จ่ายงวดหน้า |

**คำถามวิจัยที่ต้องตอบ:** `tTempTransfer` เก็บช่วงวัน (from-to) ต่อ 1 record ไหม → ถ้าเก็บได้หลายช่วงต่อรอบ = ย้ายไป-กลับได้ · ถ้าเก็บ site เดียวต่อพนักงาน/รอบ = คือข้อจำกัดที่เจอ

### 1.2 กะ/เวลางานแต่ละ site ไม่เท่ากัน
`tShift` (ต่อไซต์) · `tAssignShift` · `tAssignShiftByWeekDay` · `tAssignShiftFromCalendar` · `vAssignShift` · `vMatchAssignShift` · `vSiteRate`
→ Proc: `sAssignShiftFromCalendar` · `sUpdateAssignShift` · `sMatchingShift`

### 1.3 บันทึก/ขอ OT (เช้า, เที่ยง, บาง site ไม่ต้องขอ)
| Object | บทบาท |
|--------|-------|
| `tOTRequest_Form` · `tOTRequest_Time` · `tOTRequest_Form_SHFPeriod` | ใบขอ OT + ช่วงเวลา OT |
| `tAssignOT` · `tShiftOT` · `tOTHoliday` · `tOTx` | นิยาม OT / OT วันหยุด |
| `tRequest_OT_Process` · `tLogRequest_OT_Process` | สถานะ process การขอ |
| `service.sCreate_OTRequest` · `sCreate_OTNonRequest` · `sCreate_OTFlow` · `sCreate_OTApproved` | ขอ OT ผ่านมือถือ / **OTNonRequest = บาง site ไม่ต้องขอ** |
| `sBatch_ScheduleRequestOT` · `sMidnight_AppOT` | job ประมวลผล OT |
| `vLog_OTCliam` · `vLog_OTCliam_Retro` · `vOT_Replace` | log OT / OT ย้อนหลัง |

**ปม "ขอ 4 ทำจริง 1 ได้ 1 / ขอ 1 ทำจริง 4 ได้ 1" (เอาที่น้อย):**
→ ต้องอ่านลอจิกใน `sCAL_ALL` (คิด OT จริงจากเวลา) เทียบกับ `tOTRequest_Time` (ที่ขอ) — logic min() อยู่ตรงจุดเชื่อม 2 ตัวนี้ · รายงาน "ขอแล้วไม่ทำตาม" ทำจาก `vLog_OTCliam`

---

## กลุ่ม 2 — ✅ Workflow / อนุมัติ ⭐⭐⭐⭐

> "อนุมัติต้องวิ่งตาม org chart", "รักษาการ", "manpower control ขอตรงไหนอยู่สายนั้น", "อนุมัติเกินที่ขอไม่ได้"

| ประเภท | Object | บทบาท |
|--------|--------|-------|
| Engine | `tFlow` · `tFlowPath` · `tSystemFlow` · `tUse_Flow` | **หัวใจ workflow** — เส้นทางอนุมัติ |
| ผู้อนุมัติ | `tApproverGroup` · `tApproverList` · `tSelectApprover` | กลุ่ม/รายชื่อผู้อนุมัติ |
| Org chart | `tManager` · `tManager_Delegated` (รักษาการ) · `tBU1-4` | สายบังคับบัญชา = org chart |
| View | `vMAN_ManagerToEmp` · `vMAN_EmpToManager` · `vMAN_DelegatedToEmp` · `vManagerList` | map หัวหน้า↔ลูกน้อง (ใช้เดิน flow) |
| View | `vRequestFlowDetailActive` · `vRequestFlowDetailHistory` | สถานะคำขอที่กำลังวิ่ง/ประวัติ |
| View | `vWorkFlow_OTSystem` · `_LeaveSystem` · `_TimeSystem` · `_ExpenseSystem` · `_BenefitSystem` · `_CarSystem` | flow แยกตามระบบ |
| Proc | `sReport_Workflow` · `service.sCreate_WorkFlow` · `sCreate_FlowTeam` | สร้าง/รายงาน flow |

**learning:** เริ่มที่ `tFlow`+`tFlowPath` (นิยาม) → `vWorkFlow_OTSystem` (ตัวอย่างจริง) → `vMAN_*` (ผูก orgchart) · "manpower control / อนุมัติเกินไม่ได้" = business rule ที่ต้องดูว่าบังคับใน proc หรือ app layer

---

## กลุ่ม 3 — 💰 เบี้ยขยัน (Incentive) & การลา ⭐⭐⭐

### 3.1 เบี้ยขยัน / Incentive ("helper ต้องแก้ทุก site, อยากแก้ที่เดียว", "2 แกน")
| Object | บทบาท |
|--------|-------|
| `tRule_Incentive` | **เงื่อนไขเบี้ยขยัน** — จุดที่ต้องดูว่าตั้ง "ทุกคนตำแหน่งนี้ / ตำแหน่งนี้+site" ได้ไหม |
| `tIncentive_Initial` · `tIncentive_Log` · `tLog_EditIncentive` | ค่าตั้งต้น / log |
| `vEmployeeIncentiveCondition` · `vIncentive_EmployeePeriod` · `vIncentive_EmployeeMonthEndPeriod` · `vCal_Payroll_Incentive` | เงื่อนไขต่อคน / คำนวณเข้า payroll |
| `sIncentive` · `sIncentive_MOD` | engine คิดเบี้ยขยัน |
| `customize.tSCC_SettingIncentive` · `tMOD_SettingIncentive` + `vSCC_SettingIncentive_ByEmp` | เวอร์ชันตั้งค่าเฉพาะลูกค้า |

**"2 แกน" = น่าจะ ตำแหน่ง × ไซต์** → ยืนยันจากคอลัมน์ใน `tRule_Incentive` (มี key ทั้ง Title และ Site ไหม)

### 3.2 การลา (ใช้สิทธิ์อะไร ใช้เท่าไร เหลือเท่าไร + ทบปี)
| Object | บทบาท |
|--------|-------|
| `tEmployee_LeaveQuota` · `tEmployeeTitle_LeaveQuota` · `tEmployeeWork_Quota` | โควตาลาต่อคน/ตำแหน่ง |
| `tLeaveGroup` · `tLeaveGroupDetail` · `tLeaveRequest` | กลุ่มสิทธิ / ใบลา |
| `vBalanceLeave` · `vBalanceLeaveQuota` · `vBalanceLeaveCarry` · `vEmployeeQuotaLeaveInfo` · `vSumAllLeave_YTD` | **ใช้ไป/เหลือ/ยกมา** |
| `sCheckLeaveQuota` · `sLeaveQuotaBegin` · `sBatchLeaveEntitleQuota` · `sRecalculateCarry` · `sUpdateCompensateLeaveQuota` | เช็ก/ตั้งต้น/ยกยอดข้ามปี |
| `outpay_report.vLeaveQuota_Report_TH/_EN` | รายงานสรุปสิทธิลา |

---

## กลุ่ม 4 — 👤 ทะเบียนพนักงาน & เอกสาร HR ⭐⭐

### 4.1 ทะเบียนประวัติ (superscreen, export ตาม list, ฟิลด์ย่อย)
`tEmployee` + `tEmployee_Children` · `tEmployeeBank` · `tEmployee_OtherCard` · `tEmployeeExtraDetail` · `tEmployeeAbility`
→ View: `vEmployee` · `vEmployee_Profile` · `vEmployee_Basic` · `vEmployee_Export`
→ superscreen/export = อ่านจาก view เหล่านี้ แล้วเลือกคอลัมน์ (ทำที่ app layer)

### 4.2 ใบเตือน (pattern ชัด/ไม่ชัด, AI agent ออกเอกสาร)
`tPunishment` · `tPunishmentStyle` · `tPENALTY_Type` · `tGUILTY_Type` · View `vPunishment`
→ DB แค่เก็บ "โทษ/ความผิด/รูปแบบ" · การ generate เอกสารด้วย AI = layer นอก DB (ดึง context จากตารางนี้)

---

## กลุ่ม 5 — 📤 Output, แบงก์, ราชการ ⭐⭐⭐

### 5.1 สลิป (print เยอะ, ช้า)
`vPayroll_Slip` · `vSlip` · `tSlipStyle` · `service.vPaySlipsPrepare` · `vPaySlipsSending` · `vSlipMobile` · `sPaySlips` · `sCreateVSlip` · `Log_PaySlip` · `PeriodSlip`
→ **ช้า** เพราะ view เหล่านี้ join หนัก (ดูกลุ่ม 6)

### 5.2 จ่ายธนาคาร (hold user ที่ส่งไม่ได้, HR upload เอง)
| Object | บทบาท |
|--------|-------|
| `tEmployeeBank` · `tBankMaster` · `tBankBranch` · `tBankName` · `tSYS_RegistBank` | บัญชี/ธนาคาร |
| `vPayroll_Bank` · `vEmployee_ForBank` | ไฟล์โอนเงิน (**HR export เอง** จากตรงนี้) |
| `tPayroll_BankHolding` · `vPayroll_BankHolding` | **Hold user ที่ส่งเงินไม่ได้** — ต้องดูตัวนี้ตรงๆ |

### 5.3 ประกันสังคม (key เข้าระบบอื่น)
`tSSO_Account` · `tSSO_Data` · `tSSO_Hospital` · `tTemp_SSODetail` · `tTemp_SSOSum` · `vSSO1_10` · `vSSO1_10_Detail` · `vExport_SSO_File` · `vEmployee_SSO` · `sCAL_SSOCT`

### 5.4 ภาษีสิ้นปี / 50 ทวิ / ภงด.
| เอกสาร | Object |
|--------|--------|
| 50 ทวิ (KT20A) | `payroll.KT20A_FieldConfiguration*` · `sKT20A_Build_Report` · `vKT20A_ByCPN` · `vKT20A_BySSO` |
| ภงด.1/1ก | `vTaxPND1` · `vTaxPND1A` · `vTAX_50_PND1` · `tData_PND1_Detail` · `vPayroll_GenPND1` |
| ภงด.3 | `vPayroll_GenPND3` · `vPayroll_PND3` |
| ภงด.91 | `tTax91` · `vTax91_Report` · `vTax91_ReportDetail` · `sGen_tTax91ByEmp` · `sUpdateTax91` |

### 5.5 แยก job direct/indirect (เบิกบัญชี)
`tProject` (job) · `tCostCenter` · `tGLAccount` · `tGLAccount_MapField` · `tPayroll_GLAccNo*` · `sLoad_GLAccountNO*`
→ direct/indirect = attribute บน `tProject`/`tCostCenter` (ต้องยืนยันคอลัมน์)

### 5.6 อายัดเงินเดือน (export)
⚠️ **ยังไม่พบ object เฉพาะ** (ค้น Garnish/Seize/Court แล้วไม่เจอ) — น่าจะทำผ่าน **เงินหัก `N01–N10`** ใน `tPayroll` · **ต้องยืนยันกับทีมว่าปัจจุบันบันทึกที่ deduction ตัวไหน**

---

## กลุ่ม 6 — 🚀 Performance & Integration ⭐⭐⭐⭐

> "ระบบช้า / print เยอะ / backend ห้ามค้าง / n8n, kafka / เงินได้แยกเงินหักคนละไฟล์ / sms ช้า (foxpro เก่า)"

**ไม่ใช่เรื่อง schema แต่เป็นสถาปัตยกรรม — สิ่งที่ต้องดูใน DB:**
- View หนักที่เป็นคอขวด: `vTimeInOut` (join ~20 ตาราง, INNER JOIN 6), `vPayroll` (31KB), `vPayroll_Slip`
- Engine dynamic SQL ยักษ์: `sCAL_ALL` (180KB), `sCAL_ALL_Payroll` (125KB) — รันทีละคน/ทีละงวด ไม่ set-based เต็มที่
- ตาราง temp per-tenant `tTemp_*`, `tTempBatch_*` — สร้าง/ทิ้งทุกรอบ
- **แนวทาง:** งาน batch/print/export ควรแยกออกเป็น backend job (queue) — ตรงกับที่คุยเรื่อง n8n/kafka · แต่ (ตามที่พี่กำชับ) **การ upload ไฟล์แบงก์ให้ HR ทำเองผ่านระบบ ไม่ผูก n8n**

---

## 📌 ของที่ยัง "ต้องยืนยันเพิ่ม" (ค้างจากประชุม)

| เรื่อง | ต้องเช็กอะไร |
|--------|-------------|
| โอนย้ายไป-กลับในรอบ | `tTempTransfer` รองรับหลายช่วงวัน/พนักงาน/รอบ ไหม |
| อนุมัติก่อนโอนย้าย | มี flow ผูก `tTempTransfer` ไหม (เจอ `customize.tSCC_TranferApprove`) |
| โอนย้ายย้อนหลังมีผลทันที vs งวดหน้า | `tPeriod_Retro` + `tPMPeriod.ExtraPeriod`/`IsPeriodPayExtra` |
| "2 แกน" ของ incentive | คอลัมน์ key ใน `tRule_Incentive` |
| direct/indirect | attribute อยู่ที่ `tProject` หรือ `tCostCenter` |
| อายัดเงินเดือน | บันทึกที่ `N0x` ตัวไหน มี object เฉพาะไหม |

---

## ✅ เส้นทาง learning แนะนำ (ทำตามได้)

1. **อ่าน [Process Flow](MAS-Payroll-Process-Flow.md) ให้จบ** — เข้าใจ pipeline สแกน→เงิน
2. **เจาะ `tTimeInOut` + `vTimeInOut`** (กลุ่ม 1) — เพราะเป็นต้นน้ำและคอขวด
3. **เจาะ `tFlow`/`tFlowPath` + `vWorkFlow_OTSystem`** (กลุ่ม 2) — เข้าใจการอนุมัติ
4. **ตาม transaction 1 เส้นจริง**: ขอ OT (`tOTRequest_Form`) → อนุมัติ (`tFlow`) → เข้าเวลา (`tTimeInOut`) → คิดเงิน (`tPayroll`) → สลิป/แบงก์
5. ที่เหลือ (master, เอกสารราชการ) เรียนแบบ lookup ตอนเจอ requirement จริง

*หมายเหตุ: object เฉพาะลูกค้าอยู่ schema `customize` (SCC/MOD/Tropical) — ตรรกะธุรกิจจริงหลายอย่างซ่อนอยู่ในนั้น เวลาเจอเคสแปลกให้เช็ก `tControlMOD` ว่าเปิดลอจิกพิเศษตัวไหนอยู่*
