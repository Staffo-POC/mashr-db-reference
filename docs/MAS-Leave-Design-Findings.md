# 🏖️ MAS-HR — Leave Type / Policy / Request ออกแบบมาอย่างไร (Discovery Findings)

> คำตอบสำหรับ "Staffo Leave Policy / Leave Type Database Discovery Questions" อ้างอิงจาก schema, seed snapshot (`MAS_09_seed_all_top100_relaxed.sql`), row counts (`export-20260713`) และโค้ด proc/function จริงใน DB `MAS`
> สำรวจเมื่อ 2026-09-14 · คู่กับ [MAS-DB-Objects-Reference.md](MAS-DB-Objects-Reference.md) และ [MAS-Payroll-Process-Flow.md](MAS-Payroll-Process-Flow.md)

---

## 0. TL;DR — 8 ข้อที่ต้องรู้ก่อนออกแบบ Staffo

| # | ข้อค้นพบ | ผลต่อ Staffo |
|---|---|---|
| 1 | **`dbo.tLeaveRequest` มี 0 แถว** — ไม่ใช่ตารางใบลาที่ใช้งาน ใบลาจริงอยู่ที่ `dbo.tRequest` (generic request, 7,099 แถว) และ **ผลลัพธ์การลาถูกเขียนเป็นคอลัมน์ในแถว attendance รายวัน** (`tTimeInOut` + `tTimeInOut_AddLeave`, 726K แถว) | อย่า migrate จาก `tLeaveRequest`; source ของ leave fact = `tTimeInOut_AddLeave` + `tRequest` |
| 2 | Leave Type เป็น **fixed slot 19 ช่อง**: Sick / Personal / Vacation / L01–L15 / Compensate (+ Maternity, ParentalMom, ParentalDad เพิ่มทีหลังเป็นคอลัมน์แยก) ชื่อของ L01–L15 อยู่ที่ `tRequestType.Title` และ `tL0x_FieldCaption` (1 แถว = ทั้งระบบ) | รูปแบบเดียวกับ P01–P30: slot fix + label ตั้งเอง |
| 3 | ใช้จริงแค่ **7 ประเภท**: ลาป่วย, ลากิจ, ลาพักร้อน, L01 ลาคลอด, L02 ลาบวช, L03 ลางานศพ, L04 ลาไม่รับค่าจ้าง (L05–L15 ว่าง, Compensate มี column แต่ไม่มี label) | Catalog เริ่มต้น 7 รายการ + category |
| 4 | **Label เป็น global** (ไม่แยกบริษัท/โปรเจกต์) — `tL0x_FieldCaption` มี 1 แถว, `service.tTemp_LeaveTypes` ส่ง 7 ประเภทชุดเดียวกันไปทุก Company_Code | Company-level config ใน Staffo คือของใหม่ ไม่มีใน MAS |
| 5 | **Balance = คำนวณจาก ledger** (quota − SUM(leave units ใน tTimeInOut ของปี)) ไม่มี balance snapshot ยกเว้นตอนปิดปี (`tEmployee` → `tEmployee_LeaveQuota` ต่อ `LeaveYear`) | ตรงกับแนวทาง ledger/hybrid |
| 6 | Quota entitlement มี 3 ชั้น: default ใน `tRequestType.DefaultQuota` → ตามอายุงาน × ระดับ (`tEmployeeWork_Quota`) → override รายคนใน `tEmployee.n*YearQuota` | Auto-entitlement มีต้นแบบแล้ว (แต่ทำเฉพาะ Vacation) |
| 7 | **Carry-forward hardcode เฉพาะ Vacation** (`fCountCarry` ใช้ `RequestTypeID='3333…'`) MaxCarry=6, cap รวม=12, หมดอายุ 31/12 | Carry rule ควรเป็น policy attribute ไม่ใช่ code |
| 8 | Paid/Unpaid ตัดสิน **ต่อใบลา** (`@pPayLeave` → `IsPaySickLeave` ฯลฯ ในแถว attendance) ไม่ใช่ต่อประเภท; `tRequestType.PaymentType` แทบไม่ถูกใช้ | Leave request ต้องเก็บ `is_paid` เป็น outcome ของใบลา + default จาก policy |

---

## 1. Leave Type Master

### 1.1 ตารางที่เกี่ยว

| ตาราง | แถว | บทบาท |
|---|---|---|
| `dbo.tRequestSystem` | 8 | ระบบคำขอ: `Global`, `LEAVE_SYSTEM (1111…)`, `OT_SYSTEM`, `TIME_SYSTEM`, `CAR_SYSTEM`, `EXPENSE_SYSTEM`, `BENEFIT_SYSTEM`, `MODGM_SYSTEM` |
| `dbo.tRequestType` | 43 | ประเภทคำขอทุกระบบ — **19 แถวเป็น Leave** (`RequestSystemID = 1111…`), ที่เหลือคือ OT 6, Time 4, Car 4, Benefit 10 |
| `dbo.tL0x_FieldCaption` | 1 | label ของ L01–L15 + CompensateLeave (global, 1 แถว `ROW_ID = FFFF…`) |
| `dbo.fFindLeave_FieldCaption`, `fFindLeaveName` | – | function แปลง slot → ชื่อ |

### 1.2 19 Leave Type ใน `tRequestType` (ค่าจริง)

| SEQ | RequestTypeID | Caption (code) | Title (label) | DefaultQuota | PaymentType | MaxCarry | YTDCarry | ExpireCarry | IsGender | ใช้จริง |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `1111…` | `Sick leave` | Sick leave | 30 | 1 | 0 | 0 | | 0 | ✅ |
| 2 | `2222…` | `Personal leave` | Personal leave | 3 | 1 | 0 | 0 | | 0 | ✅ |
| 3 | `3333…` | `Vacation leave` | Vacation leave | 0 (ตามอายุงาน) | 1 | **6** | **12** | 20261231 (31/12) | 0 | ✅ |
| 4 | `4444…` | `L01` | **ลาคลอด** | 0 | 1 | 0 | 0 | | **2** (หญิง) | ✅ |
| 5 | `5555…` | `L02` | **ลาบวช** | 30 | **0** | 0 | 0 | | 0 | ✅ |
| 6 | `6666…` | `L03` | **ลางานศพ** | 3 | 1 | 0 | 0 | | 0 | ✅ |
| 7 | `7777…` | `L04` | **ลาไม่รับค่าจ้าง** | 999 | 1 | 0 | 0 | | 0 | ✅ |
| 8–18 | `8888…`, `9999…`, GUID | `L05`–`L15` | *(ว่าง)* | 0 | 1 | 0 | 0 | | 0 | ❌ |
| 19 | GUID | `Compensate leave` | *(ว่าง)* | 0 | 1 | 0 | 0 | | 0 | ❌ |

ข้อสังเกต:
- `Caption` = **code ที่โค้ดใช้ hardcode** (`'Sick Leave'`, `'Vacation leave'`, `'L01'`…) ส่วน `Title` = label แสดงผล → เทียบเท่า `code` / `name_th` ใน Staffo
- ใน attendance/quota คอลัมน์ใช้ชื่ออีกชุด: `nSickLeave`, `nPersonalLeave`, `nVacation`, `L01`…`L15`, `nCompensateLeave` → ต้อง map 3 ชื่อ (Caption ↔ column ↔ RequestTypeID)
- `Including`=3 ของ L01 และ `MaxPay`=45 → ลาคลอดจ่ายสูงสุด 45 วัน (ตามกฎหมายแรงงาน)
- `IsGender` 0=ทุกเพศ, 2=หญิง (ลาคลอด)
- `AttachFile`, `ReasonOption`, `RequireAttachDate`, `DayRequest`, `MinHourLeave`, `MinMinuteLeave` = **0 ทุกแถว** — ฟีเจอร์มีใน schema แต่ไม่ได้ config ใช้งาน
- `tLeaveReasonOption` (dropdown เหตุผลต่อประเภท) = 0 แถว

### 1.3 Maternity / Parental — leave type รุ่นใหม่ที่ไม่อยู่ใน slot

`tEmployee`, `tEmployee_LeaveQuota`, `tTimeInOut_AddLeave` มีคอลัมน์ `nMaternityLeave*`, `nParentalLeaveMom*`, `nParentalLeaveDad*` (พร้อม `_Pay`, `_StartTime`, `_Reason`) แยกจาก L01 ลาคลอด → เป็นหลักฐานว่า **slot 15 ช่องไม่พอ/ไม่ยืดหยุ่น จนต้องเพิ่มคอลัมน์เฉพาะ** ไม่มีแถวใน `tRequestType`

### 1.4 คำตอบคำถามหมวด 1

| คำถาม | คำตอบจาก MAS |
|---|---|
| มี Leave Type กี่ประเภท | schema 19 (+3 maternity/parental) · config ใช้จริง 7 |
| `tRequestType` แถวไหนเป็น Leave | 19 แถวที่ `RequestSystemID = 11111111-…` |
| `tLeaveRequest.LeaveType` distinct | **ตารางว่าง** — ใช้ `tRequest.RequestTypeID` แทน (sample: Sick, Personal, Vacation) |
| LeaveType ตรง Caption หรือ Title | โค้ดใช้ **Caption** (`sBatchLeaveEntitleQuota WHERE X.Caption='Sick Leave'`) ส่วน `sAddLeave` รับ column name (`'nSickLeave'`) |
| L01–L15 ใช้จริงกี่ตัว | 4 (L01–L04) |
| Sick/Personal/Vacation เป็น fixed category ไหม | **Fixed** — มีคอลัมน์เฉพาะ (`nSickLeaveYearQuota`…) และ GUID คงที่ `1111/2222/3333` hardcode ในโค้ด |
| บริษัทต่างกันมี type ต่างกันไหม | **ไม่** — 1 ชุด global (`tL0x_FieldCaption` 1 แถว; `service.tTemp_LeaveTypes` ส่ง 7 ประเภทเดียวกันให้ 3 company) |
| ภาษาไทย/อังกฤษ | `tRequestType` มีช่องเดียว (`Title`) — TH/EN แยกเฉพาะตอน sync ออก (`tTemp_LeaveTypes.TitleTh/TitleEn`) |
| ปิดใช้งานได้ไหม | ไม่มี `IsActive` ใน `tRequestType` (มีเฉพาะ `tTemp_LeaveTypes.IsEnable` ฝั่ง sync) — "ปิด" = ปล่อย Title ว่าง |
| เปลี่ยนชื่อย้อนหลัง / version | **ไม่มี effective date** — เปลี่ยน label = เปลี่ยนย้อนหลังทั้งหมด |

---

## 2. Quota / Balance

### 2.1 โครงสร้าง 3 ชั้น + ปิดปี

```
tRequestType.DefaultQuota            ← ค่า default ต่อประเภท (Sick 30, Personal 3, L02 30, L03 3, L04 999)
        │
tEmployeeLevel_LeaveType (12 แถว)     ← ระดับพนักงาน × ประเภทลา  (ทั้ง 12 แถวชี้ Vacation 3333…)
   └ tEmployeeWork_Quota (22 แถว)     ← ขั้นบันได: nWorkDistance (เดือน) → nPermissionLeave (วัน)
        │  sBatchLeaveEntitleQuota   (batch: DATEDIFF(MONTH, StartDate, now) > nWorkDistance → เอาขั้นสูงสุด)
        ▼
tEmployee.n{Type}YearQuota / InitQuota / YearCarry / UsedCarry / UsedClaim   ← สิทธิ์ "ปีปัจจุบัน" รายคน (แก้มือได้)
        │  ปิดปี (tCalendarYear.Status 0=ปัจจุบัน 1=รอปิด 2=ปิดแล้ว) → sBatch_tEmployee_LeaveQuota
        ▼
tEmployee_LeaveQuota (12,087 แถว)     ← snapshot ต่อ EmployeeCode × LeaveYear (+ CarryExpire)
```

ตัวอย่างขั้นบันไดพักร้อน (`tEmployeeWork_Quota`): 12 เดือน → 1–6 วัน (แล้วแต่ระดับ), 15–20 เดือน → 6 วัน

ตัวอย่าง `tEmployee_LeaveQuota` ปี 2024: Sick 30, Personal 3, Vacation 6/8/12, L02 30, L03 3, L04 999

### 2.2 ปีลา (`fLeaveYear`) — กำหนดที่ **tProject**

| `tProject.LeaveViewPeriod` | ความหมาย |
|---|---|
| 1 | ปีปฏิทิน (`LEFT(DateStamp,4)`) |
| 2 | ปีตามวันเริ่มงานของพนักงาน (anniversary) |
| 3 | ปีตาม `tProject.LeavePeriod` (รอบบริษัท) |

`tProject.LeaveCalcuLateType` = 1 ให้สิทธิ์เต็มปี, อื่น ๆ = **prorate รายเดือน** (`quota/12 × เดือนปัจจุบัน`) · `tProject.HrPerDayLeave` = ชั่วโมง/วัน ใช้แปลงชั่วโมง→วัน

### 2.3 Balance คิดอย่างไร (`sCheckLeaveQuota`, `fGetLeave_BalanceHrs/Mins`)

```
balance = quota(tEmployee.n*YearQuota หรือ tEmployee_LeaveQuota ถ้าปิดปีแล้ว)
        − SUM( leave_units / ShiftWorkUnit )  FROM vTimeInOut WHERE DateStamp LIKE '<year>%'
        + carry ที่ยังไม่หมดอายุ (Vacation เท่านั้น)
```
→ **ledger-derived** จากแถว attendance ไม่ใช่ snapshot; หน่วยเก็บเป็น "วัน" (`decimal`) + "นาที" (`*_Mins`) คู่กัน

### 2.4 Carry-forward (`fCountCarry`, `sRecalculateCarry`, `sAddLeaveCarry`)

- ทำงานเฉพาะ **Vacation** (hardcode `RequestTypeID = '33333333-…'`) แม้ schema จะมี `nL01YearCarry`…`nL15YearCarry`, `nSickLeaveYearCarry`
- กฎ: carry = min(เหลือ, `MaxCarry`=6) และ quota ปีใหม่ + carry ≤ `YTDCarry`=12
- หมดอายุ: `ExpireCarry`='20261231' / `DateExpireCarry`=31 / `MonthExpireCarry`=12 → เก็บส่วนที่หมดอายุใน `nVacationCarryExpire`
- ใช้ carry ก่อน quota (`fCountVacationUsedOnlyCarry` / `…WithoutCarry`)

### 2.5 คำตอบคำถามหมวด 3

| คำถาม | คำตอบ |
|---|---|
| รายปีหรือราย period | รายปี — แต่นิยาม "ปี" เลือกได้ 3 แบบต่อ **project** |
| ผูกกับอะไร | company ❌ · **employee level + อายุงาน** ✅ (Vacation) · site ❌ · probation ❌ (ใช้ `nWorkDistance` เดือนแทน) · รายบุคคล ✅ (override ตรงใน `tEmployee`) |
| `tEmployee.n*YearQuota` คือ entitlement หรือ snapshot | **entitlement ปีปัจจุบัน** (mutable) · snapshot อยู่ `tEmployee_LeaveQuota` |
| `nL01YearQuota`… มาจากไหน | `tRequestType.DefaultQuota` (Caption `L01`…) ผ่าน `sBatchLeaveEntitleQuota` หรือกรอกมือ |
| Carry ใช้กับ type ไหน | Vacation เท่านั้น (โค้ด) |
| Carry หมดอายุไหม | ใช่ — วันที่คงที่ต่อประเภท (31/12) |
| Balance snapshot หรือ ledger | **ledger** (สรุปจาก attendance) + snapshot ตอนปิดปี |
| แก้ quota ย้อนหลัง audit อย่างไร | ไม่มี audit ระดับ quota (มี `tLogAddLeaveManagement` เฉพาะการเพิ่ม/แก้ใบลา) |
| ลาเกินสิทธิ์ได้ไหม | `sCheckLeaveQuota` คืน 0/1 ให้ UI เตือน · `tPreset_Leave.*AllowExceed` มี schema แต่ preset เดียว = 0 ทุกช่อง → **ไม่ block ที่ DB** |
| เกินสิทธิ์เป็น unpaid หรือ block | ไม่ block — ผู้บันทึกเลือก `PayLeave` เอง (0/1) |

---

## 3. Leave Request — โครงสร้างจริง

### 3.1 ตารางที่ใช้จริง = `dbo.tRequest` (generic ทุก request system)

| คอลัมน์ | ความหมายเมื่อเป็น Leave (จาก sample + `sCreate_LeaveRequest`) |
|---|---|
| `RequestID`, `RequestNo` | PK, เลขที่ `RQ2026-001709` |
| `RequestTypeID` | → `tRequestType` (`1111…` Sick, `2222…` Personal, …) |
| `SystemType` | `'LEAVE_SYSTEM'` |
| `EmpRequestID` | EmployeeCode ผู้ขอ |
| `RuleID` | → `tFlowPath.RuleID` (flow ที่ใช้) |
| `ReqStatus` | **0 pending · 1 approved · 2 reject · 3 cancel · อื่น discard** |
| `CurrentLV` | ขั้นอนุมัติปัจจุบัน |
| `VC01`, `VC02` | วันเริ่ม/สิ้นสุด (dd/MM/yyyy) · `VC04`, `VC05` = yyyyMMdd |
| `VC03` | เหตุผล |
| `VC08` | ชื่อไฟล์แนบ (`…pdf`) |
| `D01`, `D02` | ชั่วโมง/นาที (custom period เช่น 1.00 / 13.00) |
| `D06` | จำนวนชั่วโมงรวม (8.00 = เต็มวัน, 24.00 = 3 วัน, 4.00 = ครึ่งวัน) |
| `Quota_LeaveYear` | ปีลาที่ตัดสิทธิ์ (เลือกได้ต่างจากปีปฏิทิน) |
| `IsApproveClaim`, `DeductionType` | มี แต่ = 0 ใน sample |
| `Comment` | เหตุผล reject เช่น "ลาไม่ถูกประเภท" |
| `StatusRetro`, `IsRetro1-3` | ลาย้อนหลัง (retro) |

`tSuspend_Request` (0 แถวใน snapshot) = staging ระหว่างรออนุมัติ/ระงับ; `tRequest_byAdmin` (4,074) = admin บันทึกแทน

### 3.2 เมื่ออนุมัติ → เขียนลง attendance ผ่าน `sAddLeave`

```
sAddLeave(@EmployeeCode, @DateStamp, @LeaveType='nSickLeave'|'L01'…, @Value, @Reason,
          @StartTime, @EndTime, @PayLeave 0/1, @CountHS 0-3, @FlagApp 0=App/1=Web, @Quota_LeaveYear)
   ├ หากะของวันนั้น: FIX_SHF_ID (ทะเบียน) → tAssignShift → default
   ├ หา WorkCalendar → set FlagWork (S=วันหยุดประจำสัปดาห์, H=นักขัตฤกษ์, X=ทำงาน)
   ├ @Value = -1 → ใช้ ShiftWorkUnit ทั้งกะ (ลาเต็มวัน)
   ├ TIOStatus = 9 (อนุมัติเวลาแล้ว) → RAISERROR ห้ามแก้
   ├ @CountHS: 0=ข้ามวันหยุดทั้งหมด 1=นับ S ข้าม H 2=นับ H ข้าม S 3=นับทั้งคู่
   └ UPDATE tTimeInOut SET nSickLeave=@Value, tSickLeaveReason, nSickLeave_StartTime/EndTime,
            IsPaySickLeave=@PayLeave, Used_nSickLeave_Year=@Quota_LeaveYear
     UPDATE tTimeInOut_AddLeave SET nSickLeave, nSickLeave_Mins, FlagCountSH, Used_*_Year
```

→ **1 ใบลาหลายวัน = loop เรียก sAddLeave ทีละวัน** (`sAutoLeaveGroup`, `sAddLeavesForGroup`) ไม่มี FK จาก attendance กลับไป `tRequest`; ทุกการเพิ่ม/แก้ log ลง `tLogAddLeaveManagement` (81,606 แถว: `EventLeave` Insert/Update, `Flagapp` Application/Web, `EditType` เช่น `PayLeave`, `PreviousValue`)

### 3.3 คำตอบคำถามหมวด 4

| คำถาม | คำตอบ |
|---|---|
| field ของใบลา | ดู 3.1 — ประเภท, ช่วงวัน, เวลาเริ่ม/จบ, จำนวน (วัน + นาที), เหตุผล, ไฟล์แนบ, ปีที่ตัดสิทธิ์, paid flag, นับวันหยุดแบบไหน |
| วัน/ครึ่งวัน/ชั่วโมง | รองรับทั้ง 3 — `leave_period` full_day / custom, เก็บ `_StartTime/_EndTime` + `_Mins`; `tW_Option.Leave_System.Flag6` = auto push เวลาเข้า-ออกหลังลาครึ่งวัน |
| `BeginHourLeave…` ใน tLeaveRequest | ตารางว่าง — ของจริงคือ `tTimeInOut.n*_StartTime/EndTime` (varchar 'HH:mm') |
| วันหยุด/นักขัตฤกษ์นับไหม | **เลือกได้ต่อใบลา** (`@CountHS`/`FlagCountSH`) ไม่ใช่ต่อประเภท |
| กะ/เสาร์-อาทิตย์ | ใช้ `FlagWork` จาก WorkCalendar ของแต่ละคน (S/H) ไม่ hardcode เสาร์-อาทิตย์ |
| overlap กับใบลาเดิม | ตรวจใน `sAutoLeaveGroup` (sum ทุกช่อง > 0 → error "ช่วงเวลาดังกล่าวมีการลา") |
| overlap กับ OT / แก้เวลา | ไม่ตรวจ; block เฉพาะ `TIOStatus = 9` |
| ลาย้อนหลัง | ได้ (`StatusRetro`, `IsRetro*`) |
| ลาล่วงหน้ากี่วัน | `tRequestType.DayRequest` = 0 ทุกแถว (ไม่บังคับ); `tW_Option.Alert_LeaveSubmitTimeLimit` = 0 |
| cancel/withdraw หลัง approve | `ReqStatus = 3 cancel` มีใน mapping; ฝั่ง attendance ใช้ `sDeleteLeave` |

---

## 4. Attachment / Evidence

| คำถาม | คำตอบ |
|---|---|
| type ไหนต้องแนบ | `tRequestType.AttachFile` = 0 ทุกแถว → **ไม่บังคับ** |
| ใบรับรองแพทย์เกินกี่วัน | `RequireAttachDate` = 0 → ไม่ config; แต่มี `tTimeInOut.SickLeaveMedCert` (smallint) และเหตุผลใน log "มีใบแพทย์/ไม่มีใบแพทย์" → **บันทึกเป็น flag/ข้อความ ไม่ enforce** |
| `RequireAttachDate` คืออะไร | ตาม schema = จำนวนวันขั้นต่ำที่ต้องแนบ (คู่กับ `AttachFile` = mode) — ไม่มีการใช้ในโค้ด |
| `AttachFile` boolean หรือ mode | `varchar(2)` default '0' — ออกแบบเป็น mode แต่ใช้เป็น 0 |
| version เอกสาร | ไม่มี — `VC08` เก็บชื่อไฟล์เดียว; ฝั่ง mobile sync มี `file1–3` (URL S3) |
| ใครเห็นได้ | ไม่มี ACL ระดับ attachment |

---

## 5. Approval Workflow

```
tEmployee.flowleaveid ──► tFlow (29: L_295, L_297, L_999_S3, OT_295, Payroll, IT, …)
                              │  RequestSystemID = 0000… (Global)
                              ▼
                          tFlowPath (29)  RuleID / LV / IsAnd / IsFinishPath / TimeOut
                              │
                          tSelectApprover (60) ──► tApproverList (24: EmployeeID, IsEnable, Delegate…)
tRequest.RuleID ──► tFlowPath.RuleID ; tRequest.CurrentLV = ขั้นปัจจุบัน
```

| คำถาม | คำตอบ |
|---|---|
| flow เดียวทุกบริษัท | ไม่ — **ผูกรายคน** (`tEmployee.flowleaveid`, `flowOTid`, `FlowTimeID`, …แยกต่อระบบ) ชื่อ flow บอกว่า scope = site (`L_295`, `L_297`, `L_999_S3`) |
| `flowleaveid` override รายคน | ใช่ — เป็นวิธีเดียวที่กำหนด flow |
| route ขึ้นกับอะไร | ไม่มี rule engine — คนตั้งค่าเลือก flow ให้พนักงานเอง (ไม่ผูก leave type) |
| ทีละ step หรือ all | `tFlowPath.IsAnd` (0 = คนใดคนหนึ่ง, 1 = ทุกคนใน LV) · sample ทุก flow มี `LV=1, IsFinishPath=1` = **อนุมัติขั้นเดียว** |
| `ISReqAllApprove` | คอลัมน์ใน `tLeaveRequest` (ว่าง) — เทียบเท่า `IsAnd` |
| `LRQStatus` | ไม่ได้ใช้ — ใช้ `tRequest.ReqStatus` 0/1/2/3 |
| Reject ต้องใส่เหตุผล | เก็บใน `tRequest.Comment` (มีข้อมูล) ไม่บังคับที่ DB |
| Approver แก้จำนวนวัน | ไม่มีใน flow — แต่ HR แก้ได้ที่ attendance (`Flagapp = Web`, `EditType = PayLeave`) |
| HR override | ได้ — `tRequest_byAdmin` (4,074 แถว) และ `tTemp_Leaves.RequestNo = 'by Admin'` |

---

## 6. Payroll / Attendance Impact

| คำถาม | คำตอบ |
|---|---|
| paid/unpaid ตัดสินที่ไหน | **ต่อใบลา**: `sAddLeave @pPayLeave` → `tTimeInOut.IsPay{Type}` (0/1) · default จาก `tRequestType.PaymentType` (L02 ลาบวช = 0) แต่ log แสดง Personal/Vacation ถูก insert ด้วย 0 แล้ว update เป็น 1 บ่อย → **มนุษย์ตัดสิน** |
| `PayLeave`, `PaymentType`, `PayRate` | `PayLeave` = flag ต่อวัน · `PaymentType` = default ต่อประเภท (1 จ่าย/0 ไม่จ่าย) · `PayRate` NULL ทุกแถว (ไม่ใช้) · `MaxPay`=45 เฉพาะลาคลอด |
| กระทบ attendance อย่างไร | ลา **คือ** คอลัมน์ของแถว attendance (`n{Type}`, `_Mins`, `_StartTime`, `FlagLeave`) ไม่มี status `LEAVE` แยก |
| Leave สร้าง status หรือ attendance consume | MAS: leave **เขียนทับ** attendance โดยตรง (`sAddLeave`) |
| Unpaid หักอย่างไร | payroll คิดวันจ่าย = `nWorkUnit + Σ(IsPay{Type}=1 ? n{Type} : 0)` (proc `sCAL_ALL_Payroll` ~L10038) → unpaid = ไม่นับเป็นวันทำงาน; `tPayroll.nLeave/LeaveRate/CLeave` = ยอดหักรวม |
| Paid นับเป็น work unit | ใช่ (สูตรด้านบน) |
| ครึ่งวันกระทบสาย/ออกก่อน | `MinLeaveStartTime/MaxLeaveEndTime` ในแถว attendance ใช้ตัดช่วงคำนวณสาย; `Flag6` auto push เวลา |
| มี punch แต่มี leave approved | ไม่มีกฎ resolve — ค่าทั้งคู่อยู่แถวเดียวกัน, payroll รวมทั้งสอง |
| Payroll lock แล้วแก้ใบลาได้ไหม | block ที่ `TIOStatus = 9` (อนุมัติเวลา) และ `FlagLocked` ของงวด; `tAddLeaveManagement` (0 แถว) ออกแบบไว้เก็บ "ลาที่เพิ่มหลังปิดงวด" พร้อม `PMPeriod_ID` + `b*` (before) columns |
| version/snapshot ตอนปิดงวด | `tPayroll.nSickLeave…L15`, `YTD*` = snapshot จำนวนวันลาที่ใช้คิดเงินของงวด |

---

## 7. Integration ภายนอก (`service.*`) — mobile app sync

`service.tTemp_LeaveTypes / tTemp_LeaveBalance / tTemp_LeaveRequest / tTemp_Leaves / tTemp_LeaveFlow / tTemp_LeaveApproved / tTemp_LeaveNonRequest` = **outbox/inbox sync กับแอปมือถือ** (ไฟล์แนบชี้ S3 `control-a-solutions-prod-file`) ไม่ใช่ตารางธุรกิจ

- แอปใช้ `leave_type_local_id = tRequestType.SEQ` (1–7) และ `type` เป็น string `sick|personal|vacation|other`
- `tTemp_LeaveBalance` ส่ง balance เป็น `Bal_D / Bal_H / Bal_M` (วัน/ชม./นาที) ต่อ `SEQ` ต่อ `LeaveYear` → ยืนยันว่า balance ภายนอกถูก **คำนวณแล้ว push** ไม่ได้อ่านจาก table
- `tTemp_LeaveNonRequest` = การลาที่ admin บันทึกตรงโดยไม่มีใบขอ (ต้อง sync กลับไปแอป) → Staffo ต้องรองรับ "leave fact without request"

---

## 8. Migration Mapping → Staffo

### 8.1 Leave type → `company_leave_types`

| MAS `Caption` | attendance column | RequestTypeID | Staffo `code` | `category` | `name_th` | default | is_paid default | หมายเหตุ |
|---|---|---|---|---|---|---|---|---|
| Sick leave | `nSickLeave` | `1111…` | `SICK` | SICK | ลาป่วย | 30 | true | `SickLeaveMedCert` flag |
| Personal leave | `nPersonalLeave` | `2222…` | `PERSONAL` | PERSONAL | ลากิจ | 3 | true | |
| Vacation leave | `nVacation` | `3333…` | `VACATION` | VACATION | ลาพักร้อน | by seniority | true | carry 6 / cap 12 / exp 31-12 |
| L01 | `L01` | `4444…` | `MATERNITY` | MATERNITY | ลาคลอด | 0 | true (≤45) | gender F |
| L02 | `L02` | `5555…` | `ORDINATION` | OTHER | ลาบวช | 30 | **false** | |
| L03 | `L03` | `6666…` | `FUNERAL` | OTHER | ลางานศพ | 3 | true | |
| L04 | `L04` | `7777…` | `UNPAID` | OTHER | ลาไม่รับค่าจ้าง | 999 | false | |
| Compensate leave | `nCompensateLeave` | GUID | `COMPENSATE` | COMPENSATE | ชดเชยวันลา | 0 | true | ไม่มี label/data |
| – | `nMaternityLeave`, `nParentalLeaveMom/Dad` | – | – | MATERNITY / PARENTAL | | | | คอลัมน์ใหม่ ตรวจว่ามีข้อมูลก่อน migrate |

เก็บ `legacy_request_type_id`, `legacy_caption`, `legacy_column` ไว้ 3 ค่าเพราะโค้ดเดิมอ้าง 3 แบบ

### 8.2 Leave fact / request

| Staffo | source | หมายเหตุ |
|---|---|---|
| `leave_requests` | `dbo.tRequest WHERE SystemType='LEAVE_SYSTEM'` (+ `tRequest_byAdmin`) | `RequestNo`, `ReqStatus` map 0 pending/1 approved/2 rejected/3 cancelled; `Quota_LeaveYear`; `VC08` attachment |
| `leave_request_days` / ledger | `dbo.tTimeInOut_AddLeave` (แถวที่ Σ leave cols > 0) | ต่อวัน: type, units (วัน), mins, start/end, `IsPay*`, `FlagCountSH`, `Used_*_Year` — **ไม่มี FK ไป tRequest** ต้อง match ด้วย EmployeeCode + date + type |
| audit | `dbo.tLogAddLeaveManagement` | Insert/Update, Web/Application, PreviousValue |
| `leave_balances` (snapshot ต่อปี) | `dbo.tEmployee_LeaveQuota` | LeaveYear 2024, 2026 (12,087 แถว) + carry/expire |
| current entitlement | `dbo.tEmployee.n*YearQuota/InitQuota/YearCarry` | ปีปัจจุบัน |
| entitlement rule | `tEmployeeLevel_LeaveType` + `tEmployeeWork_Quota` | Vacation by level × months of service |
| leave year policy | `tProject.LeaveViewPeriod / LeaveCalcuLateType / HrPerDayLeave / LeavePeriod` | policy อยู่ระดับ **project** (ไม่ใช่ company) |

### 8.3 คำตอบคำถามหมวด 8

| คำถาม | คำตอบ |
|---|---|
| `tLeaveRequest.LeaveType` → code | ไม่ต้อง (ตารางว่าง) ใช้ `tRequest.RequestTypeID` |
| L01–L15 label | `tRequestType.Title` (primary) และ `tL0x_FieldCaption` (ค่าเดียวกัน) |
| type ที่มี quota แต่ไม่มี request | L02/L03/L04 มี quota ทุกคน (30/3/999) — migrate catalog + quota แม้ไม่มี request |
| quota = 0 คือไม่มีสิทธิ์หรือยังไม่ setup | **ไม่แน่ชัด** — Vacation 0 = ยังไม่ครบ 12 เดือน (ถูกต้อง), L05–L15 0 = ไม่ใช้ slot; ต้องดู `nVacationInitQuota` ประกอบ |
| history ทั้งหมดหรือ balance | แนะนำ: catalog + `tEmployee_LeaveQuota` ทุกปี + `tTimeInOut_AddLeave` ย้อนหลังเท่าปีที่ยัง carry (Vacation) + `tRequest` เฉพาะ pending |
| legacy id ที่ต้องเก็บ | `RequestTypeID`, `RequestID`/`RequestNo`, `EmployeeCode`, `DateStamp`, `LeaveYear`, `FlowID` |
| source lineage | request: `tRequest.RequestID` · day: (`EmployeeCode`,`DateStamp`,column) · balance: (`EmployeeCode`,`LeaveYear`) · policy: `RequestTypeID` + `PRJ_ID` |

---

## 9. สิ่งที่เอกสาร Discovery ตั้งสมมติฐานไว้ต่างจากของจริง

| สมมติฐานในเอกสาร | ของจริงใน MAS |
|---|---|
| `tLeaveRequest` เป็นตารางใบลา | ว่าง — ใบลาอยู่ `tRequest` (generic VC/D columns) และผลอยู่ใน attendance |
| Leave Type ต่างกันต่อบริษัท | global ชุดเดียว; policy (ปีลา, prorate, ชม./วัน) อยู่ระดับ **project** |
| `service.tTemp_*` เป็น source ควร inspect | เป็น sync buffer ไปแอปมือถือ — ใช้ยืนยัน mapping ได้ แต่ไม่ใช่ source of truth |
| Paid/unpaid เป็น attribute ของ type | เป็น attribute ของ **ใบลา/วัน** (`IsPay*` ต่อแถว) โดย HR เปลี่ยนได้ทีหลัง |
| Carry เป็น policy ต่อ type | schema รองรับทุก type แต่โค้ดทำเฉพาะ Vacation |
| Approval route ตาม company/dept/type | ผูก flow รายพนักงาน (`flowleaveid`) เท่านั้น; sample ทั้งหมดขั้นเดียว |
| ต้องมี Attachment rule ต่อ type | schema มี (`AttachFile`, `RequireAttachDate`) แต่ = 0 ทั้งหมด; ใช้ free-text "มีใบแพทย์" |

### ข้อเสนอเพิ่มใน Staffo model (จากหลักฐาน)

1. `company_leave_types` ควรมี `legacy_column`, `legacy_request_type_id`, `gender_restriction`, `max_paid_days` (ลาคลอด 45), `carry_max_days`, `carry_cap_total_days`, `carry_expire_mmdd`
2. `leave_year_policy` ระดับ company/payroll-group: `year_basis` (CALENDAR | HIRE_ANNIVERSARY | CUSTOM_PERIOD), `proration` (FULL | MONTHLY), `hours_per_day`
3. `leave_entitlement_rules`: `employee_level_id` × `leave_type_id` × `min_service_months` → `days` (แทน `tEmployeeWork_Quota`)
4. `leave_request_days` ต้องมี `is_paid`, `count_holiday_mode` (0–3), `minutes`, `start_time/end_time`, `quota_year` — เพราะ MAS ตัดสินระดับวัน
5. รองรับ **leave fact ที่ไม่มี request** (`source = ADMIN | IMPORT | REQUEST`) เพราะ `tRequest_byAdmin` 4,074 แถว และ `tTemp_LeaveNonRequest`
6. Attendance ต้อง **consume** approved leave (ไม่ให้ leave เขียนทับ) เพื่อเลิกปัญหา "punch + leave ในแถวเดียว ไม่มีกฎ resolve"

---

## Appendix — objects ที่อ้างอิง

| ประเภท | ชื่อ |
|---|---|
| Config | `tRequestSystem`, `tRequestType`, `tL0x_FieldCaption`, `tLeaveReasonOption`(0), `tPreset_Leave`(1), `tBatchLeave`(1), `tW_Option` (`Leave_System`, `Alert_LeaveSubmitTimeLimit`, `UI_LeaveAppForm_*`), `tProject.Leave*` |
| Entitlement | `tEmployeeLevel_LeaveType`, `tEmployeeWork_Quota`, `tEmployeeTitle_LeaveQuota`(0), `tEmployee.n*Quota/Carry`, `tEmployee_LeaveQuota`, `tCalendarYear` |
| Request/Flow | `tRequest`, `tRequest_byAdmin`, `tSuspend_Request`, `tFlow`, `tFlowPath`, `tSelectApprover`, `tApproverList`, `tApproverGroup`(0), `tLeaveGroup`/`tLeaveGroupDetail` (ลาหมู่) |
| Fact | `tTimeInOut` (n*, IsPay*, *_StartTime, *Reason, SickLeaveMedCert), `tTimeInOut_AddLeave`, `tAddLeaveManagement`(0), `tLogAddLeaveManagement`, `tPayroll.n*/YTD*/nLeave/CLeave` |
| Procs | `sAddLeave`, `sDeleteLeave`, `sAutoLeaveGroup`, `sAddLeavesForGroup`, `sCheckLeaveQuota`, `sBatchLeaveEntitleQuota`, `sBatch_tEmployee_LeaveQuota`, `sRecalculateCarry(_admin)`, `sAddLeaveCarry`, `sBatchCarry`, `sCAL_Leave(_New)`, `sFullFillTime_AddLeave`, `service.sCreate_Leave*` |
| Functions | `fLeaveYear`, `fGetLeaveQuota`, `fGetLeave_BalanceHrs/Mins`, `fCountCarry`, `fCountVacationUsedOnlyCarry/WithoutCarry`, `fFindVacationQuota_OfYear`, `fFindLeave_FieldCaption`, `fFindLeaveName`, `fGenLeaveDay`, `fRecalculateCarryWating` |
