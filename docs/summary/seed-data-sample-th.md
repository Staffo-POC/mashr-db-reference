# สรุปตัวอย่างข้อมูล Seed (2026-07-14)

สถานะ local Docker MSSQL (`localhost,14333`, database `MAS`) หลังจากลบ container/volume แล้วสร้างใหม่ทั้งหมด

## สถานะโดยรวม

- Schema: 570 ตาราง (ครบ)
- Seed ที่โหลดเข้าไป: `database/schema/master/MAS_09_seed_all_top100_relaxed.sql` → **288 ตาราง / ~14,653 แถว**

## ปัญหาที่เจอระหว่างทำซ้ำ (สำหรับครั้งหน้า)

1. **`./scripts/setup.sh` เดียว ๆ ได้ schema อย่างเดียว ทุกตาราง 0 แถว** — เพราะ `database/seed/` ในแพ็กเกจนี้ไม่มี snapshot จริงอยู่เลย (มีแค่ README/.gitkeep) และ `MASHR_SEED_SNAPSHOT` ใน `.env.example` ว่างอยู่ ขั้นตอน seed ใน `setup.sh`/`import.sh` เลยไม่มีอะไรให้ import
2. **`database/scripts/mssql/scripts/import-seed-file.sh` ใช้ `sqlcmd -b` ทำให้ import หยุดทั้งไฟล์ทันทีที่เจอ error แรก** — ไฟล์ `MAS_09_seed_all_top100_relaxed.sql` มีบาง row ที่ละเมิด NOT NULL constraint อยู่แล้วในตัวอย่าง 5 ตาราง (ตามที่บันทึกไว้ใน `07-seed-runbook.md`: `__MigrationHistory`, `sysdiagrams`, `tLogRequest_OT_Process`, `tRequest`, `service.tTemp_OTRequest`) พอใช้ `-b` มันจะหยุดที่ตัวแรกสุด (`__MigrationHistory` เพราะเรียงตามตัวอักษร) ทำให้ import ได้แค่ ~15 ตารางแรกเท่านั้น

   วิธีแก้: รัน `sqlcmd` โดย **ไม่ใส่ `-b`** เพื่อให้มันข้าม error แล้วทำงานต่อจนจบไฟล์:
   ```bash
   docker exec mashr-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$(grep MSSQL_SA_PASSWORD .env | cut -d= -f2)" -C -d MAS -r 1 \
     -i /workspace/database/schema/master/MAS_09_seed_all_top100_relaxed.sql
   ```
   วิธีนี้เขียนไว้ใน root [README.md](../../README.md#sample-seed-data) แล้ว
3. **`.mcp.json` password อาจไม่ตรงกับ `.env`** — ถ้า `MSSQL_PASSWORD` ใน `.mcp.json` ไม่ตรงกับ `MSSQL_SA_PASSWORD` ใน `.env` (เช่น เคยก็อปมาจาก container อื่น) ทุก query ผ่าน MCP จะ error `Login failed for user 'sa'` ทั้งที่ DB รันปกติดี และแก้ไฟล์ `.mcp.json` อย่างเดียวไม่พอ ต้อง reconnect/restart MCP server ในเซสชันด้วยถึงจะมีผล
4. **ลบ container ใน Docker Desktop แล้ว volume ไม่หายตาม** — volume `mashr-db-reference_mashr-db-data` ยังอยู่แม้ลบ container `mashr-db` ไปแล้ว พอสร้าง container ใหม่มันจะไปใช้ volume เก่าต่อ ทำให้ขั้นตอน reset/bootstrap ของ `setup.sh` เจอ "already exists" ได้ ถ้าอยากได้ของใหม่ล้วน ๆ ต้องใช้ `./scripts/reset.sh` (อันนี้ลบ volume ด้วย)

## Connection Info

```
Server   : localhost,14333
Database : MAS
Username : sa
Password : ดูใน .env (ตัวแปร MSSQL_SA_PASSWORD)
Container: mashr-db
```

## ตารางที่น่าดู (แบ่งกลุ่ม)

### 1. Master/Config ตัวเล็ก ๆ ที่ข้อมูล "ครบจริง" (ไม่ถูกตัดที่ TOP 100)

เหมาะเริ่มดูก่อนเพื่อเข้าใจ enum/lookup ของระบบ:

| ตาราง | แถว | ความหมาย |
|---|---:|---|
| `tCompany` | 3 | บริษัท |
| `tEmployeeStatus` / `tEmployeeStatusGroup` | 3 / 3 | สถานะพนักงาน |
| `tGender`, `tNationality`, `tMartialStatus`, `tPrefix` | 3 แต่ละตัว | enum พื้นฐาน |
| `tEmployeeType1/2/3` | 5/1/2 | ประเภทพนักงาน |
| `tEmployeeLevel` | 14 | ระดับพนักงาน |
| `tShift`, `tWorkCalendar` | 7, 3 | กะ/ปฏิทินทำงาน |
| `tBU2/3/4` | 4/1/1 | โครงสร้างองค์กร |
| `tProject`, `tCostCenter` | 5, 3 | โปรเจกต์/cost center |
| `tBankMaster`, `tBankName`, `tProvince` | 56, 36, 77 | ธนาคาร/จังหวัด |
| `tRequestType`, `tFlow`, `tFlowPath`, `tRule`, `tRequestSystem`, `tApproverList` | ≤43 | workflow config |
| `tUser` | 87 | บัญชีผู้ใช้ระบบ |

### 2. Entity/Fact ตัวหลัก (sample TOP 100 — โครงสร้างครบ แต่ไม่ใช่จำนวนจริง)

| ตาราง | ความหมาย |
|---|---|
| `dbo.tEmployee` | พนักงาน — จุดเริ่มต้นที่ดีที่สุด |
| `dbo.tPayroll`, `tPayroll_Detail`, `tPayroll_Tax`, `tPayroll_Allowance` | ข้อมูลเงินเดือนต่อรอบ/พนักงาน |
| `dbo.tRequest`, `tStage` | คำขอ/workflow อนุมัติ |
| `dbo.tEmployeeTitle`, `tSiteTR`, `tBU1`, `tResignReason` | master ที่ใหญ่กว่า 100 แถวจริง เลยถูกตัด (5 ตารางนี้ขาดข้อมูลจริงไปเยอะสุด ดู `09-data-count-summary.md`) |

### 3. ตารางที่ยังว่างเปล่า (schema อย่างเดียว)

พวก `billing.*`, `payroll.*`, `rosetta.*` และตารางใหญ่จริง ๆ อย่าง `tTimeStamp` (7.4 ล้านแถวใน production) — seed sample ไม่ครอบคลุมส่วนนี้เลย

## ตัวอย่างข้อมูลจริงแบ่งตามกลุ่ม

### 🏢 กลุ่มองค์กร

**`tCompany`** (3 แถว — ครบ)

| ชื่อบริษัท | Tax ID | จังหวัด | SSO Rate |
|---|---|---|---|
| ศรีสมบัติการช่าง (SSB) | 1111111111111 | – | 5.00% |
| บ.ศรีราชา โพรเทคทีฟ ซิสเต็มส์ (SPS) | 0205568038731 | ชลบุรี | 5.00% |
| บ.ศรีราชาคอนสตรัคชั่น (มหาชน) (SCC) | 0107554000305 | ชลบุรี | 5.00% |

**`tCostCenter`** — Direct / Indirect / CostCenter1 (3 แถว)
**`tBU2`** — D1, M1, M2, `-` (4 แถว, มี `BU1_ID` เชื่อมกับ `tBU1`)

### 👤 กลุ่ม Enum พนักงาน

| ตาราง | ค่า |
|---|---|
| `tGender` | Male, Female, They |
| `tNationality` | เมียนมา, เมียนม่า (สะกดซ้ำในข้อมูลต้นทาง), ไทย |
| `tEmployeeStatus` | อยู่ (active), ออก (resigned), แจ้งลาออก |
| `tEmployeeType1` | รหัส 00–03, 09 (5 ค่า) |
| `tEmployeeLevel` | 1–12 + มีค่าผิดปกติ "ไทย" ปนอยู่ 1 แถว (data quality issue ของต้นทาง) |

### 🔁 กลุ่ม Workflow/Request

**`tRequestSystem`** (8 ระบบ, ครบ): Global System, LEAVE_SYSTEM, OT_SYSTEM, TIME_SYSTEM, CAR_SYSTEM, EXPENSE_SYSTEM, BENEFIT_SYSTEM, MODGM_SYSTEM

**`tRequestType`** (43 แถว, ครบ) ตัวอย่าง: Sick leave, Personal leave, Vacation leave, ลาคลอด, OTHoliday, OTL, Shift, Out — แต่ละแถวผูกกับ `RequestSystemID`

### ⏰ กลุ่ม Attendance

**`tShift`** (7 แถว, ครบ) — มี ~190 คอลัมน์ (ตั้งค่า rounding/OT/late-in/late-out ละเอียดมาก) ตัวอย่างกะที่มี: `18.00-06.00`, `07.00-16.00`, `08.00-17.00`, `07.30-16.30`

### 💰 กลุ่ม Payroll (entity/fact, sample TOP 100 — ไม่ใช่จำนวนจริง)

**`tEmployee`** ตัวอย่าง:

| รหัส | คำนำหน้า | ชื่อ | นามสกุล | เกิด |
|---|---|---|---|---|
| C00018 | นาย | สุพล | สุยะ | 1966-07-09 |
| C00025 | นาย | สมบูรณ์ | กันชูลี | 1959-09-26 |
| C00040 | นาย | สมหมาย | ยามไธสง | 1972-05-14 |

**`tPayroll`** ตัวอย่าง (มี ~400 คอลัมน์ทั้งหมด, ดึงเฉพาะยอดรวม):

| รหัสพนักงาน | รายได้รวม | หัก | สุทธิ |
|---|---:|---:|---:|
| C00040 | 19,710.00 | 751.19 | 18,958.81 |
| C00048 | 23,624.69 | 966.65 | 22,658.04 |
| C00133 | 12,000.00 | 338.00 | 11,662.00 |

## ข้อควรระวัง

ข้อมูลชุดนี้มีชื่อบริษัทจริง/เลขภาษี/ชื่อพนักงานจริง/วันเกิดจริง ปนมาจาก production export (2026-07-13) — เก็บไว้ใน local เท่านั้น **ห้าม publish หรือแชร์ออกไปข้างนอก**
