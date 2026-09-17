# Export ข้อมูลจาก server เข้ามาใน Docker

ชุดสคริปต์นี้ใช้ดึงข้อมูลจริงจาก SQL Server ตัว production ออกมาเป็นไฟล์ seed
แล้วนำกลับเข้า Docker (`mashr-db-reference`) เพื่อวิเคราะห์ต่อ

- `Export-MashrSeed.ps1` — รันบนเครื่อง server (อ่านอย่างเดียว ไม่เขียน DB)
- `run-export.cmd` — ตัวห่อ ให้ดับเบิลคลิกหรือรันจาก cmd ได้เลย ไม่ต้องแก้ ExecutionPolicy

---

## ขั้นที่ 1 — คัดลอกไปเครื่อง server

ก๊อปทั้งโฟลเดอร์ `scripts/export/` ไปวางที่เครื่องที่มี SQL Server (เช่น `D:\mashr-export\`)
ต้องการแค่ PowerShell 3.0 ขึ้นไป — ไม่ต้องติดตั้งโมดูล `SqlServer` หรือ `sqlcmd`

## ขั้นที่ 2 — ลองดูปริมาณข้อมูลก่อน (ไม่เขียนไฟล์)

```powershell
.\run-export.cmd -DryRun
```

จะได้ตารางจำนวนแถวของทุกตารางที่จะ export พร้อมบอกว่าตารางไหนจะถูก cap
ถ้าจำนวนแถวเยอะเกินไป ให้ลด `-Months` / `-MaxEmployeesPerSite` / `-TopSites`

## ขั้นที่ 3 — export จริง

```powershell
:: ใช้ค่า default: 8 ไซต์ที่มีพนักงานมากสุด, 30 คน/ไซต์, ย้อนหลัง 3 เดือน
.\run-export.cmd

:: หรือระบุไซต์เองตาม Site_No
.\run-export.cmd -SiteNo 999_S2,2800_S2,270_00 -Months 6 -MaxEmployeesPerSite 50
```

ผลลัพธ์อยู่ที่ `out\<YYYYMMDD>\` และไฟล์ zip `out\mashr-seed-<YYYYMMDD>.zip`

## ขั้นที่ 4 — ส่ง zip กลับมา แล้วโหลดเข้า Docker

ที่เครื่องวิเคราะห์ (repo root):

```bash
./scripts/load-seed-export.sh ~/Downloads/mashr-seed-20260907.zip
./scripts/check-site-data.sh
```

`load-seed-export.sh` จะแตกไฟล์เข้า `database/seed/<snapshot>/`, ตั้งค่า
`MASHR_SEED_SNAPSHOT` ใน `.env` ให้อัตโนมัติ แล้วรัน `./scripts/setup.sh` ต่อให้
จากนั้น `check-site-data.sh` จะพิมพ์รายงานคุณภาพข้อมูลฝั่ง company/site ออกมา

---

## พารามิเตอร์

| พารามิเตอร์ | ค่า default | ความหมาย |
|---|---|---|
| `-Server` | `localhost` | ชื่อ/IP ของ SQL Server เช่น `SCCDB01` หรือ `10.0.0.5,1433` |
| `-Database` | `MAS` | ชื่อฐานข้อมูล |
| `-SqlUser` / `-SqlPassword` | (ว่าง) | ถ้าเว้นว่างจะใช้ Windows Authentication |
| `-SiteNo` | (ว่าง) | ระบุ `Site_No` เองได้หลายค่า คั่นด้วย comma |
| `-TopSites` | `8` | ถ้าไม่ระบุ `-SiteNo` จะเลือกไซต์ที่มีพนักงานมากที่สุด N ไซต์ |
| `-MaxEmployeesPerSite` | `30` | จำนวนพนักงานต่อไซต์ (`0` = ทั้งหมด) |
| `-MaxTransferEmployees` | `300` | ดึงพนักงานที่ถูกโอนย้ายเข้าไซต์เหล่านั้นเพิ่ม |
| `-Months` | `3` | ช่วงเวลาของข้อมูลลงเวลา นับถอยหลังจากวันล่าสุดที่มีข้อมูลจริง |
| `-DateFrom` / `-DateTo` | (auto) | กำหนดช่วงเองแบบ `yyyyMMdd` |
| `-Mask` | `Basic` | `None` / `Basic` / `Full` — ดูหัวข้อถัดไป |
| `-MaxRowsPerTable` | `50000` | เพดานแถวต่อตาราง (`0` = ไม่จำกัด) |
| `-IncludeBinary` | ปิด | รวมคอลัมน์รูปภาพ/binary (ทำให้ไฟล์ใหญ่มาก) |
| `-DryRun` | ปิด | นับแถวอย่างเดียว ไม่เขียนไฟล์ |
| `-NoZip` | ปิด | ไม่ต้อง zip |

## การปิดบังข้อมูลส่วนบุคคล (`-Mask`)

| โหมด | ปิดบังอะไร |
|---|---|
| `None` | ไม่ปิดบังเลย — ใช้เฉพาะเมื่อได้รับอนุมัติแล้วเท่านั้น |
| `Basic` (default) | ชื่อ-นามสกุล, ที่อยู่, เบอร์โทร, อีเมล, เลขบัตร/ผู้เสียภาษี, เลขบัญชี/ธนาคาร, โรงพยาบาลประกันสังคม, วันเกิด (เหลือเฉพาะปี) |
| `Full` | ทุกอย่างของ `Basic` + ค่าจ้าง/เรต OT/รายได้สุทธิ (ตั้งเป็น 0) |

การปิดบังเป็นแบบ deterministic (ค่าเดิม → ค่าปลอมเดิมเสมอ) ดังนั้นการ join
ระหว่างตารางยังคงถูกต้อง แต่ `EmployeeCode` และ ID ทั้งหมด **ไม่ถูกแตะต้อง**
เพราะเป็นกุญแจที่ต้องใช้วิเคราะห์

> ค่า default คือ `Basic` — ถ้าต้องการข้อมูลดิบต้องสั่ง `-Mask None` เอง
> และตามกติกาใน `database/seed/README.md` ห้าม commit ข้อมูลดิบขึ้น git
> (ให้เก็บไว้ใต้ `sensitive/` ซึ่งถูก ignore ไว้แล้ว)

## ตารางที่ export

**ดึงทั้งตาราง (master)** — `tCompany` · `tSiteTR` · `tSiteRate` · `tSiteTR_BU_Mapping` ·
`tSiteTR_MappingScan` · `tSiteUpdate` · `tSiteUpdatePlan` · `tShift` · `tBU1`–`tBU4` ·
`tCostCenter` · `tEmployeeTitle` · `tPMPeriod` · `tSYS_WebMenu` · `tSYSOutPayMenu` ·
`customize.tSCC_AprvSite` · `customize.tMOD_LogSetting` · `customize.tSCC_SettingPayAllowance`

**กรองตามไซต์/พนักงาน/ช่วงวันที่** — `tEmployee` · `tTimeInOut` · `tTimeInOut_Data` ·
`tPayroll` · `tTimeSheet` · `tTimeSheet_MultiPeriod` · `tTempTransfer` · `tCostAllocation` ·
`customize.tSCC_TranferSite` · `customize.tSCC_TranferEmp` · `customize.tLog_Tranfersite` ·
`customize.tSCC_SettingIncentive` · `customize.tSCC_SelectFilter` · `customize.tSCC_PayAllowance`

ตารางที่ไม่มีในฐานข้อมูลนั้นจะถูกข้ามและระบุไว้ใน `_manifest.json`
ตารางที่ export ได้ 0 แถวจะไม่สร้างไฟล์ และจะไม่ถูกใส่ในรายการ `DELETE`
ของ `00_disable_constraints.sql` — ข้อมูลเดิมใน Docker จึงไม่ถูกล้างทิ้งโดยไม่ตั้งใจ

## ข้อควรระวัง

- สคริปต์รันเฉพาะคำสั่ง `SELECT` — ไม่มีการเขียน/แก้ไขฐานข้อมูลต้นทาง
- ควรรันนอกเวลาปิดงวดเงินเดือน และควรใช้ SQL login ที่มีสิทธิ์ `db_datareader` เท่านั้น
- ถ้ามี replica / standby ให้ชี้ `-Server` ไปที่ replica จะปลอดภัยกว่า
- ไฟล์ที่ได้เป็น `INSERT` ล้วน ๆ เปิดตรวจด้วย text editor ได้ก่อนส่งออกจากองค์กร
