# 🔄 MAS — Process Flow เงินเดือน & ลงเวลา (แยกเป็นหมวด)

> สรุปว่า **ระบบทำงานยังไง เรียก proc ตัวไหนตามลำดับ กระทบ table ไหน** — อ้างอิงจากโค้ด proc จริงใน DB `MAS`
> สำรวจเมื่อ 2026-07-21 · คู่กับ [MAS-DB-Objects-Reference.md](MAS-DB-Objects-Reference.md)

---

## 🧭 ภาพรวม 6 ชั้น (Data Pipeline)

ข้อมูลไหลจาก "เครื่องสแกน" → กลายเป็น "เงินในสลิป" ผ่าน 6 ชั้น แต่ละชั้นเขียนลงตารางของตัวเอง:

```
[1] เครื่องสแกน/มือถือ
      │  sImportTimeStamp
      ▼
[2] tTimeStamp            ← ข้อมูลตอกบัตร "ดิบ" (cardID, เครื่อง, วันเวลา)
      │  sPushTimeInOut  (จับคู่กับกะ)
      ▼
[3] tTimeInOut           ← เวลาเข้า-ออกเป็นรายวัน/รายคน  (ยังไม่คิดเงิน)
      │  sCAL_ALL (=sCal_All) + sMatching* + sReCal*
      ▼
[3b] tTimeInOut (อัปเดต)  ← เติมค่า มา/สาย/ขาด/OT/กะ เป็นจำนวน (n*)
      │  sCAL_ALL_Payroll  (คูณเรต + ภาษี/ปกส./กองทุน)
      ▼
[4] tPayroll             ← เงินรายคนต่องวด  (C* = จำนวนเงิน)
      │  ปิดยอด → FlagLocked = 1
      ▼
[5] สลิป / รายงานราชการ / โอนแบงก์   (อ่านอย่างเดียว, ล็อกแล้ว)
```

> **กฎทองที่บังคับทั้งระบบ:** proc คำนวณเกือบทุกตัวมีเงื่อนไข `WHERE FlagLocked = 0` — **แถวที่ล็อกแล้วจะถูกข้าม ไม่ถูกคำนวณทับ** นี่คือหัวใจของ "ปิดยอดแล้วแก้ไม่ได้"

---

## หมวด A — 📅 งวดจ่าย (Payroll Period / รอบ)

ทุกอย่างผูกกับ **งวด (Period)** ตาราง `tPMPeriod` (1 แถว = 1 งวดของ 1 โครงการ)

| Column | ความหมาย |
|--------|----------|
| `PMPeriod_ID` · `PRJ_ID` | รหัสงวด / ผูกโครงการ |
| `Period` · `PeriodSeq` | ชื่องวด (เช่น 2026-07) / ลำดับงวดในเดือน |
| `BeginDate` · `EndDate` · `PaymentDate` | วันเริ่ม-จบงวด / วันจ่าย |
| `IsMonthEndPeriod` · `NoOfDay` | เป็นงวดสิ้นเดือนไหม / จำนวนวัน |
| `PMPeriodStatus` | สถานะงวด (เปิด/ปิด) |
| `Cal_Tax` · `TypeToPayroll` | งวดนี้คิดภาษีไหม / วิธีเข้า payroll |
| **`BeginDate_OT` / `_Late` / `_Leave` / `_Absent` / `_Holiday` / `_Incentive`** (+ `EndDate_*`) | **ช่วงวันของแต่ละองค์ประกอบ แยกกัน** |

> 🔑 **นี่คือคำตอบเรื่อง "เวลาไม่เท่ากัน":** งวดเดียวสามารถตั้งให้ **OT / สาย / ลา / ขาด** นับคนละช่วงวันได้
> เช่น รายวันตัดยอด OT ถึงวันที่ 25 แต่นับขาด-ลายกทั้งเดือน → ตั้งที่คอลัมน์ `BeginDate_OT`/`EndDate_OT` ฯลฯ

**สร้างงวด:** `sGen_PaymentPeriod` · `sGen_TaxPeriod` · `sAddPMPeriod` / `sEdit_PMPeriod`
**รายวัน vs รายเดือน:** ต่างกันที่จำนวนงวด/เดือน (`PeriodSeq`) และ `TypeToPayroll` — พนักงานรายวันคิดจาก `nWorkUnit × WageRate`, รายเดือนใช้ `sUpdate_nWorkUnit_ForMonthly` เติมหน่วยงานเต็มเดือนแล้วหักส่วนขาด

---

## หมวด B — 👆 เก็บเวลาจากเครื่องสแกน (Attendance Ingest)

**Step 1 — เข้าระบบ:** เครื่องสแกนนิ้ว/บัตร ส่งข้อมูลดิบเข้ามาทีละบรรทัด — มี **2 เส้นทาง** ขึ้นกับว่าเครื่องต่อ LAN หรือไม่

**(1) เครื่องต่อ LAN** — ดึงอัตโนมัติผ่านโปรแกรม **ATT2000** (ซอฟต์แวร์ฝั่ง ZKTeco/OEM ดึงข้อมูลจากเครื่องผ่านเครือข่ายโดยตรง)

**(2) เครื่อง standalone (ไม่เสียบสาย LAN)** — ⚠️ **ขั้นตอน manual นอกระบบ MAS ทั้งหมด**:
1. Admin ที่ไซต์ต่อ USB เข้าเครื่อง → export เป็นไฟล์ (เจอในหน้างานจริงเป็นไฟล์ `.ABT`, ตั้งชื่อ `<เครื่อง>-<วันที่>.ABT`)
2. ส่งไฟล์นี้มาที่ส่วนกลาง (อีเมล/แชท ฯลฯ)
3. ส่วนกลาง **import ไฟล์เข้าโปรแกรม ATT2000** (เมนู Data → USB Disk Manage → Import) — ATT2000 เป็นตัวถอด `.ABT` เอง ไม่ใช่ MAS
4. ATT2000 เขียนลง `Att2000.mdb` แล้วค่อยส่งต่อเข้า MAS

> 🔴 **นี่คือจุดเสี่ยง "ดึงข้อมูลไม่ครบ" ที่อยู่นอก DB เลย** — ทั้ง 4 step ข้างบนเป็นคน/ไฟล์ล้วนๆ ไม่มี audit trail ใน MAS: ไซต์ลืมส่งไฟล์ / ส่งช้า / import ผิดเครื่อง / ไฟล์ export ไม่ครบช่วงวันที่ → ข้อมูลจะ **ไม่มีทางเข้าถึง `tTimeStamp` เลยตั้งแต่ต้น** (ก่อนจะไปโดนเหตุผลอื่นๆ ในหมวด "ทำไมดึงไม่ครบ" ด้านล่างซ้ำอีกชั้น)

- proc `sImportTimeStamp(@Array, @separator, @sTableName)` — แยก CSV 8 ช่อง (cardID, machineID, วันที่, ชั่วโมง, นาที, duty ...) แล้ว `INSERT` ลงตาราง raw (ปลายทางหลังจาก ATT2000/เครื่อง LAN ส่งเข้ามา)
- ปลายทาง: **`tTimeStamp`** (ดิบ) · หรือ `Temp_TimeStamp` / `tTemp_TimeStampScan` ระหว่างนำเข้า
- staging เฉพาะยี่ห้อ: `customize.TimeScan_BioStar` (+ ฟังก์ชัน `fConvertDateBioStar` ฯลฯ) สำหรับเครื่อง BioStar/Suprema
- ทางอื่นที่ป้อนเข้ามา: `sImportTimeInOutFromExcel` (นำเข้า Excel), มือถือผ่าน schema `service`, ประตู/เครื่องผ่าน schema `rosetta` (Rosetta2)

**Step 2 — จับคู่สแกนกับกะ → โครงเวลา:** `sPushTimeInOut` (ตัวใหญ่ ~83KB, อ้าง `tTimeStamp`+`tShift`+`tTimeInOut`)
- เอา scan ดิบมา "จับคู่" ว่าอันไหนคือเข้า/ออก/เข้า-ออก OT ตามกะ แล้วเขียนเป็นแถวรายวันใน **`tTimeInOut`**
- variant: `sPushTimeInOut_Mode20` (โหมดสแกนละเอียด), `_SCC` / `_Tropical` (ลูกค้าเฉพาะ)

> ⚠️ **site check-in / เวลาต่าง site:** ใช้ `sMatchingDuty` · `sMatchingDutyOfSite` · `sMOD_SCC_LastSiteScan` จับว่าสแกนนั้นอยู่ไซต์ไหน แล้วใช้เรตตามไซต์ (`tSiteRate`, `sUpdateTimeInoutSiteRate`)

---

## หมวด C — ⏱️ คำนวณเวลา: มา / สาย / ขาด / ลา / OT

**Engine:** `sCAL_ALL(@pEmployeeCode, @pBeginDate, @pEndDate, @TempName, @ViewName)`
(ชื่อ `sCal_All` กับ `sCAL_ALL` คือ proc **ตัวเดียวกัน** — SQL ไม่สนตัวพิมพ์ใหญ่เล็ก · อ้าง `tShift` 504 ครั้ง, เขียน `tTimeInOut`)

หน้าที่: อ่านโครงเวลาใน `tTimeInOut` เทียบกับ **กะ** (`tShift`, `tShiftBreak`, `tShiftOT`, `tShiftLateIn`, `tShiftLateOut`) แล้วเติมค่า **จำนวน** ลงคอลัมน์ `n*` ของ `tTimeInOut`:

| ได้อะไร | คอลัมน์ |
|---------|---------|
| หน่วยงาน (มาทำงาน) | `nWorkUnit` |
| สายเข้า / สายออก (+ จำนวนครั้ง) | `nLateIn` · `nLateOut` · `nLateInCount` · `nLateOutCount` |
| ขาดงาน | `nAbsent` |
| ลา (ป่วย/กิจ/พักร้อน) | `nSickLeave` · `nPersonalLeave` · `nVacation` |
| OT 4 ระดับ | `nOT1` · `nOT1_5` · `nOT2` · `nOT3` |
| ทำงานวันหยุด / ค่ากะ / incentive | `nHoliday` · `nShift` · `nIncentive` |
| ธงสถานะวันนั้น | `FlagWork` |

**ตัวช่วยคำนวณเฉพาะจุด (เรียกแยกได้เวลาแก้ทีละเรื่อง):**
- `sMatchingShift` / `sMatchingTime` — จับกะ/เวลาที่ถูกต้องให้แต่ละวัน
- `sReCalLateIn` / `sReCalLateOut` — คำนวณสายใหม่
- `sReCalFlagWork` — คำนวณธงมาทำงานใหม่
- `sFullFillTime` — เติมวันที่ยังว่าง (วันหยุด/ยังไม่มีสแกน) ให้ครบช่วง
- `sCAL_Leave_New` — ผูกใบลา (`tLeaveRequest`) เข้ากับวันในตาราง แล้วหักหน่วยงาน

---

## หมวด D — 💰 คำนวณเงิน (Payroll = เอาจำนวน × เรต)

**Engine:** `sCAL_ALL_Payroll` (~125KB, อ้าง `tPayroll` + ภาษี)
เอา `n*` จาก `tTimeInOut` (+ เงินเพิ่ม/หักตั้งไว้) มา **คูณเรต** เขียนลง **`tPayroll`**:

- `n* × *Rate = C*` → เช่น `nOT1 × OT1Rate = COT1`, `nWorkUnit × WageRate`
- เงินได้เพิ่ม `P01–P10` / เงินหัก `N01–N10` (โบนัส, เบี้ยเลี้ยง, เงินกู้ ฯลฯ)
- รวมยอด: `TotalIncome` · `TotalDeduction` · `NetIncome`

**แล้วต่อด้วยตัวหักตามกฎหมาย (เรียงกัน):**
| proc | เขียนคอลัมน์ |
|------|-------------|
| `sCAL_SSOCT` | `CSSOCT` (ประกันสังคม) |
| `sCAL_PVF` / `sCal_RatePVF_Period` | `CPVF` (กองทุนสำรองเลี้ยงชีพ) |
| `sCAL_TAX` + `sCalTaxByMonth*` | `CTAX` (ภาษีหัก ณ ที่จ่าย — มีเคสลาออก/40(2)/แยกโครงการ) |
| `sCAL_ALL_TOTAL_PAYROLL` | รวมยอดสุทธิทั้งงวด |
| `sCAL_ALL_YTD_PAYROLL` | สะสม Year-to-date (`YTD*`) |

> ทุกตัวข้างบนมีเงื่อนไข `FlagLocked = 0` — ล็อกแล้วไม่แตะ

---

## หมวด E — 🔁 Batch อัตโนมัติ (รันทิ้งไว้ แล้วมาดูทีหลัง)

**`sBatch_Cal_All`** = ตัวที่ตั้งเวลารันทิ้งไว้ (scheduler/nightly job)

ลอจิกจริงในโค้ด:
1. คำนวณช่วง **ย้อนหลัง 15 วัน**: `@BeginDate = วันนี้-15`, `@EndDate = เมื่อวาน` (`-1`)
2. ดึงเวลาที่ยัง **ไม่ล็อก** (`FlagLocked = 0` และ `TIOStatus < 9`) จาก `vTimeInOut` ลงตารางชั่วคราว `tTempBatch_TimeInOut`
3. เรียก `sCAL_ALL '' , @BeginDate, @EndDate, 'tTempBatch_TimeInOut', 'vNonWorkingBatch_Holiday'`
   → พารามิเตอร์แรก `''` = **ทุกคน**
4. รันลอจิกลูกค้าเฉพาะ (MOD) ถ้าเปิดใช้ (`tControlMOD`)

**Batch อื่นที่รันเป็นชุด:**
- `sBatch_AutoPost_TimeSheet` — โพสต์ไทม์ชีตอัตโนมัติ (ตั้ง `FlagLocked`)
- `sBatch_FullFillTime` — เติมเวลาให้ครบทุกวัน/ทุกคน
- `sBatch_Resign` · `sBatch_Probation` — ประมวลผลลาออก/พ้นทดลองงาน
- `sBatchCal_All_SCC` — batch เวอร์ชันลูกค้า SCC

> 💡 เพราะ batch มองย้อนแค่ 15 วันและข้ามของที่ล็อก → รันซ้ำได้ปลอดภัย ไม่ทับยอดที่ปิดแล้ว

---

## หมวด F — 👤 Re-calculate รายคน (กดปุ่มคิดใหม่ทีละคน)

**ใช้ engine ตัวเดียวกับ batch** แต่ส่ง `EmployeeCode` เข้าไปแทน `''`:

```sql
EXEC sCAL_ALL 'EMP00123', '20260701', '20260715', @TempName, @ViewName   -- คิดเวลาคนเดียว
EXEC sCAL_ALL_Payroll ...  -- แล้วคิดเงินต่อ
```

- `sCAL_ALL_ByEmpDate` — เวอร์ชันเจาะจงคน+ช่วงวัน
- ปุ่ม "re-cal" บนหน้าจอ = เรียก sequence หมวด C → D สำหรับ EmployeeCode เดียว
- ⚠️ ถ้าแถวคนนั้นในงวด **ถูกล็อก (`FlagLocked=1`)** การกด re-cal จะ **ไม่มีผล** (proc ข้าม) — ต้องปลดล็อกก่อน

---

## หมวด G — 🔒 ปิดยอด / ล็อก / History (แก้ไขไม่ได้)

3 ธงควบคุมสถานะ (ยิ่งไปทางขวา = ยิ่งตายตัว):

| ธง | อยู่ที่ | ความหมาย |
|----|--------|----------|
| `IsEdited` | tTimeInOut / tPayroll | ถูกแก้ด้วยมือ (กันคำนวณทับค่าที่คนแก้เอง) |
| `FlagWork` · `TIOStatus` | tTimeInOut | สถานะของวันนั้น (คำนวณแล้ว/ผ่าน ≥9 = ปิด) |
| **`FlagLocked`** | tTimeInOut **และ** tPayroll | **ปิดยอด — proc คำนวณทุกตัวข้ามทันที** |
| `PMPeriodStatus` | tPMPeriod | สถานะทั้งงวด (ปิดงวด) |

**กลไก "ปิดแล้วแก้ไม่ได้":**
- ตอนปิดยอด → set `FlagLocked = 1`
- proc `sCAL_*` เกือบทุกตัวมี `WHERE FlagLocked = 0` → แถวที่ล็อกจะไม่ถูกคิดใหม่/เขียนทับ
- หน้า History = อ่าน `tPayroll` ของงวดที่ `FlagLocked=1` มาแสดงอย่างเดียว
- **ปิด/เปิดสิ้นปี:** `sBatch_ClosePeriod_Year` / `sBatch_UnClosePeriod_Year` (จัดการยกยอดวันลา carry, quota ปีใหม่ — เขียน `tEmployee`, `tTimeInOut`, `tEmployee_LeaveQuota`)
- **ปลดล็อกเพื่อแก้:** ต้อง un-close ก่อน (สิทธิ์เฉพาะ admin)

---

## หมวด H — 🧩 กรณีพิเศษ (ที่มักตกหล่น)

| เรื่อง | proc / table ที่เกี่ยวข้อง |
|--------|---------------------------|
| **ลาออกกลางงวด** | `sBatch_Resign` · `sBatch_fEmployee_Resign` · `sCalTaxByMonth_Resign*` (คิดภาษีปิดปีให้คนออก) |
| **พ้นทดลองงาน** | `sBatch_Probation` · `sBatch_fEmployee_Probation` |
| **วันลา → กระทบเวลา** | `tLeaveRequest` → `sCAL_Leave_New` → หัก `nWorkUnit` ใน tTimeInOut |
| **ยกยอดวันลา / โควตา** | `sBatchCarry` · `sRecalculateCarry` · `sBatchLeaveEntitleQuota` |
| **ไซต์งาน / เรตตามไซต์** | `tSiteRate` · `sMatchingDutyOfSite` · `sUpdateTimeInoutSiteRate` |
| **ลูกค้าเฉพาะราย** | `customize.*` — SCC (incentive/housing/โยกไซต์), MOD, Tropical |
| **เงินเดือน → บัญชี GL** | `sLoad_GLAccountNO*` → `tPayroll_GLAccNo*` |
| **วางบิล outsource** | `sCAL_BILL` · `sCAL_PaymentCharge` → schema `billing` |

---

## ✅ ลำดับรัน 1 งวด (สรุปให้ทำตามได้)

1. **ตั้งงวด** → `tPMPeriod` (ช่วงวัน + ช่วงย่อย OT/สาย/ลา/ขาด)
2. **นำเข้าสแกน** → `sImportTimeStamp` → `tTimeStamp`
3. **จับคู่กะ** → `sPushTimeInOut` → `tTimeInOut`
4. **คิดเวลา** → `sCAL_ALL` (+ `sReCal*`, `sCAL_Leave_New`) → เติม `n*` ใน `tTimeInOut`
5. **คิดเงิน** → `sCAL_ALL_Payroll` → `tPayroll` (`C*`)
6. **หักตามกฎหมาย** → `sCAL_SSOCT` → `sCAL_PVF` → `sCAL_TAX` → `sCAL_ALL_TOTAL_PAYROLL`
7. **ตรวจ / แก้รายคน** → re-cal ด้วย `sCAL_ALL 'EMPxxx' ...`
8. **ปิดยอด** → `FlagLocked = 1` → ออกสลิป/รายงาน/โอนแบงก์

> ระหว่าง 2–6 คือสิ่งที่ **`sBatch_Cal_All` รันให้อัตโนมัติทุกคืน** (ย้อนหลัง 15 วัน, เฉพาะที่ยังไม่ล็อก) — เราแค่มาตรวจตอนเช้าแล้ว re-cal เฉพาะเคสที่ผิด

---

*หมายเหตุ: engine หลัก (`sCAL_ALL`, `sCAL_ALL_Payroll`) เป็น dynamic SQL ขนาดใหญ่ (สร้าง SQL เป็น string แล้ว EXEC) — ลอจิกปลีกย่อยจึงต้องอ่านในตัว proc เอง เอกสารนี้สรุประดับ flow + ตารางที่กระทบ เพื่อใช้วางแผน step-by-step*

---

## 📦 รายการ Object ที่กระทบทั้งหมด (Inventory)

รวม **~23 Tables · ~10 Views · ~35 Stored Procedures** ที่อยู่ในเส้นทาง สแกน → เงิน

### 📋 Tables (23) — เก็บข้อมูลจริง

| # | Table | เก็บอะไร / ดึงจากไหน |
|---|-------|---------------------|
| 1 | `tTimeStamp` | สแกนดิบทีละครั้ง (cardID, เครื่อง, วันเวลา) — ป้อนโดย `sImportTimeStamp` |
| 2 | `Temp_TimeStamp` · `tTemp_TimeStampScan` | ที่พักสแกนระหว่างนำเข้า |
| 3 | `tTimeInOut` | **แกนเวลา** — 1 แถว/คน/วัน (เข้า-ออก, n*, ลา, ธง) |
| 4 | `tTimeInOut_Data` · `tTimeInOut_AddLeave` | ข้อมูลเสริม/ลาที่แทรกเข้าเวลา |
| 5 | `tTempBatch_TimeInOut` | ที่พักตอน batch คำนวณ (สร้างใหม่ทุกรอบ) |
| 6 | `tPayroll` | **แกนเงิน** — 1 แถว/คน/งวด (C*, ภาษี, ปกส., สุทธิ) |
| 7 | `tPayroll_Detail` | รายละเอียดบรรทัดเงิน |
| 8 | `tPMPeriod` | นิยามงวด + ช่วงวันย่อย (OT/สาย/ลา/ขาด) |
| 9 | `tShift` · `tShiftBreak` · `tShiftOT` · `tShiftLateIn` · `tShiftLateOut` · `tShiftGroup` | นิยามกะ — ตัวตั้งเกณฑ์คิดสาย/OT |
| 10 | `tEmployee` | ข้อมูลพนักงาน + อัตราจ้าง (WageRate) |
| 11 | `tEmployeeStatus` · `tEmployeeStatusGroup` | สถานะพนักงาน (ทำงาน/ลาออก) |
| 12 | `tProject` | โครงการ (ผูก SSO account) |
| 13 | `tSSO_Account` | บัญชีประกันสังคม (ผูกบริษัท) |
| 14 | `tCompany` | บริษัท |
| 15 | `tSiteTR` · `tSiteRate` | ไซต์งาน + เรตตามไซต์ |
| 16 | `tLeaveRequest` | ใบลา → ป้อนเข้า `sCAL_Leave_New` |
| 17 | `tWorkCalendar` · `tWorkCalendarDetail` · `tAssignWorkCalendar` | ปฏิทินงาน/วันหยุด |
| 18 | `tAssignShift` | จัดกะให้พนักงาน (ผ่าน `vAssignShift`) |
| 19 | `tCostCenter` | ศูนย์ต้นทุน OT |
| 20 | `tBU1`–`tBU4` | หน่วยงาน 4 ระดับ |
| 21 | `tEmployeeType1`–`3` · `tEmployeeTitle` · `tEmployeeLevel` | ประเภท/ตำแหน่ง/ระดับ |
| 22 | `tControlMOD` | สวิตช์เปิด/ปิดลอจิกลูกค้าเฉพาะ |
| 23 | `tLOG_TimeInOut` · `tLOG_TimeInOutDelete` | log การแก้/ลบเวลา |

### 👁️ Views (10) — ประกอบข้อมูลให้พร้อมใช้

| View | รวมมาจาก / ใช้ทำอะไร |
|------|---------------------|
| `vTimeInOut` | `tTimeInOut` + `tEmployee` + `tShift` + master ~20 ตาราง → หน้าจอ/รายงานเวลา · **ป้อน batch** |
| `vTimeInOut_Attendance` | เหมือนบน เน้นสรุปมา/ขาด/ลา |
| `vTimeInOut_LoadData` | เวอร์ชันสำหรับโหลดเข้า payroll |
| `vTimeInOut_Group` | สรุปแบบ group |
| `vAssignShift` | กะที่ถูก assign ต่อคน/วัน (ป้อน `vTimeInOut`) |
| `vNonWorkingBatch_Holiday` | วันหยุดในช่วง batch (สร้าง dynamic ทุกรอบ) |
| `vPayroll` · `vPayroll_detail` | `tPayroll` + master → สลิป/รายงานเงิน |
| `vMTDPayroll` · `vYTDPayroll` | ยอดสะสมเดือน/ปี |

### ⚙️ Stored Procedures (35) — ตามลำดับ pipeline

| ชั้น | Procedures |
|------|-----------|
| นำเข้าสแกน | `sImportTimeStamp` · `sImportTimeInOutFromExcel` |
| จับคู่กะ→เวลา | `sPushTimeInOut` (+`_Mode20`/`_SCC`/`_Tropical`) · `sMatchingShift` · `sMatchingTime` · `sMatchingDuty` · `sMatchingDutyOfSite` |
| คิดเวลา | `sCAL_ALL` · `sReCalLateIn` · `sReCalLateOut` · `sReCalFlagWork` · `sFullFillTime` · `sCAL_Leave_New` · `sUpdate_nWorkUnit_ForMonthly` · `sUpdateTimeInoutSiteRate` |
| คิดเงิน | `sCAL_ALL_Payroll` · `sCAL_SSOCT` · `sCAL_PVF` · `sCAL_TAX` · `sCalTaxByMonth*` · `sCAL_ALL_TOTAL_PAYROLL` · `sCAL_ALL_YTD_PAYROLL` |
| งวด | `sGen_PaymentPeriod` · `sGen_TaxPeriod` · `sAddPMPeriod` |
| batch/ปิดยอด | `sBatch_Cal_All` · `sBatch_AutoPost_TimeSheet` · `sBatch_FullFillTime` · `sBatch_Resign` · `sBatch_Probation` · `sBatch_ClosePeriod_Year` · `sBatch_UnClosePeriod_Year` |

---

## 🚨 ทำไม "ดึงข้อมูลไม่ครบ" — สาเหตุ + วิธีเช็ก

เรียงจากที่เจอบ่อยสุด → น้อยสุด:

### 0. 🔴🔴 ก่อนถึง DB เลย — เครื่อง standalone พึ่ง "คนไซต์ส่งไฟล์มือ" (สาเหตุนอกระบบ ตัวใหญ่สุด)
ตามหมวด B — เครื่องที่ไม่ต่อ LAN ต้องให้ **แอดมินไซต์ export ไฟล์ (`.ABT`) แล้วส่งมาให้ส่วนกลาง import เข้า ATT2000 เอง** ทั้งกระบวนการนี้ **ไม่มีตัวไหนอยู่ใน MAS DB เลย** จึงตรวจสอบ/แจ้งเตือนอัตโนมัติไม่ได้:
- ไซต์ลืมส่ง / ส่งช้ากว่ารอบ batch (เลย 15 วันตามข้อ 2 ด้านล่างไปอีก)
- ส่งไฟล์ผิดเครื่อง / ผิดช่วงวันที่ / ไฟล์ export ไม่ครบ (เครื่อง cache เต็มแล้วเขียนทับของเก่า)
- Import เข้า ATT2000 แล้วแต่ยังไม่ถูกส่งต่อเข้า MAS (ไม่มี job อัตโนมัติเชื่อม ATT2000 → MAS ที่ตรวจสอบได้จาก DB ฝั่งนี้)
- **เช็ก:** ถ้าคนขาดข้อมูลกระจุกอยู่ที่ **ไซต์เดียว/เครื่องเดียว** (ไม่ใช่กระจายทั้งระบบ) ให้สงสัยขั้นตอนนี้ก่อนสาเหตุอื่นทั้งหมด — ไล่ที่ไซต์/แอดมิน ไม่ใช่ที่ SQL

### 1. 🔴 `vTimeInOut` ใช้ INNER JOIN 6 ตาราง → แถวหลุดเงียบๆ (สาเหตุอันดับ 1 ฝั่ง DB)
`vTimeInOut` (ตัวที่ batch และหน้าจอส่วนใหญ่ใช้) มี **INNER JOIN** กับ:
`tEmployee` → `tProject` → `tEmployeeStatus` → `tEmployeeStatusGroup` → `tSSO_Account` → `tCompany`

> ถ้าพนักงานคนไหน **ข้อมูล master ไม่ครบแม้แต่ตัวเดียว** แถวเวลาของเขาจะ **หายทั้งแถว** จาก view (ไม่ error, ไม่เตือน):
> - พนักงานไม่ได้ผูกโครงการ (`PRJ_ID` ว่าง/โครงการถูกลบ)
> - โครงการไม่ได้ผูกบัญชีประกันสังคม (`tProject.SSOACC_ID` ว่าง)
> - บัญชี ปกส. ไม่ได้ผูกบริษัท (`tSSO_Account.CPN_ID` ว่าง)
> - สถานะพนักงาน/กลุ่มสถานะหาย
>
> **เช็ก:** `SELECT` จาก `tTimeInOut` ตรงๆ เทียบจำนวนแถวกับ `vTimeInOut` ช่วงเดียวกัน — ถ้าน้อยกว่า = โดน INNER JOIN ตัด
> (ส่วน `tShift`, `tSiteTR`, `tBU*` เป็น LEFT JOIN → ไม่ตัดแถว แค่ค่าเป็น NULL)

### 2. 🟠 Batch มองย้อนแค่ 15 วัน และไม่รวม "วันนี้"
`sBatch_Cal_All` ตั้ง `@BeginDate = วันนี้-15`, `@EndDate = เมื่อวาน (-1)`
- ข้อมูลเก่ากว่า 15 วัน (เช่นสแกนย้อนหลัง/แก้ทีหลัง) **batch จะไม่หยิบ** → ต้อง re-cal เอง
- **วันปัจจุบันไม่ถูกคำนวณ** (ตัดที่ -1) → ยอดวันนี้จะยังไม่ขึ้นจนกว่าจะรันพรุ่งนี้

### 3. 🟠 ตัวกรอง `FlagLocked = 0` และ `TIOStatus < 9`
ทั้ง batch และ proc คำนวณ ดึงเฉพาะแถวที่ **ยังไม่ล็อกและยังไม่ปิด**
- แถวที่ `FlagLocked=1` (ปิดยอดไปแล้ว) จะไม่ถูกดึงมาคิด/แสดงในบางรายงาน → ดู "เหมือนหาย"
- ถ้าเผลอ AutoPost/ปิดยอดก่อนเวลา → ข้อมูลถูกกันออกจากการคำนวณ

### 4. 🟠 สแกนไม่ match กับกะ → ไม่เกิดแถวใน `tTimeInOut`
`sPushTimeInOut`/`sMatchingShift` จับ scan ดิบเข้ากับกะ ถ้า:
- พนักงานไม่ได้ถูก assign กะวันนั้น (`tAssignShift` ว่าง, ไม่มี FIX_SHF_ID)
- เวลาสแกนอยู่นอกช่วงที่กะรับ → scan ค้างใน `tTimeStamp` แต่ **ไม่ถูก push** เข้า `tTimeInOut`
- **เช็ก:** เทียบ `tTimeStamp` (มี scan) กับ `tTimeInOut` (ไม่มีแถว) ของคน/วันนั้น

### 5. 🟡 วันที่ไม่มีสแกนเลย + ยังไม่รัน `sFullFillTime`
วันหยุด/วันที่พนักงานไม่มาและไม่มี scan จะ **ไม่มีแถว** จนกว่า `sFullFillTime`/`sBatch_FullFillTime` จะเติมให้ → รายงานเห็นวันขาดหาย

### 6. 🟡 ช่วงวันย่อยของงวดตั้งผิด (`BeginDate_OT` ฯลฯ)
ถ้า `tPMPeriod.BeginDate_Late`/`_OT`/`_Leave` ถูกตั้งแคบกว่าที่ควร → องค์ประกอบนั้นถูกตัดออกจากงวด แม้เวลาจะมีอยู่ใน `tTimeInOut`

### 7. 🟡 `sImportTimeStamp` อ่านแค่ 8 ช่อง
proc มี `@i <= 8` — ถ้าไฟล์สแกนส่งมาเกิน 8 คอลัมน์ ข้อมูลเกินจะถูกทิ้ง (rare แต่เกิดกับเครื่องรุ่นใหม่)

### 8. 🟡 Card/Employee mapping ไม่ตรง
scan มากับ cardID/machineID ถ้า cardID ไม่ map กับ EmployeeCode → row ค้างใน raw ไม่มีเจ้าของ

### 9. ⚪ พนักงานลาออก/ยังไม่เริ่มงานในช่วงงวด
`vTimeInOut` คิด `StartDate`/`ResignDate` — คนที่ resign ก่อนงวด หรือ start หลังงวด อาจถูกกรองในหน้าจอที่ filter ตามสถานะ

### 10. ⚪ View แยก tenant / filter (`_COMxxxx`, `_SCCDB01`)
บางหน้าจอใช้ view ที่ generate แยกบริษัท/เครื่อง (`sCreate_vTimeInOut_Filter`) — ถ้า view เหล่านี้ไม่ถูก refresh หลังเพิ่มพนักงาน/หน่วยงาน ข้อมูลใหม่จะไม่โผล่ (`sRefreshViewAll`)

### 🔍 ลำดับไล่เช็กเมื่อ "ดึงไม่ครบ"
```
[นอกระบบ] ไซต์นี้เป็นเครื่อง standalone ไหม? ส่งไฟล์ .ABT มาหรือยัง? import เข้า ATT2000 แล้วหรือยัง? (ข้อ 0)
   ↓
tTimeStamp (มี scan?) 
   → tTimeInOut (มีแถวไหม? ถ้าไม่ = ปัญหา match กะ ข้อ 4/5)
   → vTimeInOut (แถวหายไปจาก tTimeInOut? = INNER JOIN ตัด ข้อ 1)
   → ช่วงวัน/งวด ครอบไหม? (ข้อ 2/6)
   → FlagLocked/TIOStatus กันอยู่ไหม? (ข้อ 3)
```
