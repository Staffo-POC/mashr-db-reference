# MAS Data Count Summary

Snapshot of row counts and master-data candidates in the local Docker MSSQL analysis database (`localhost,14333`, database `MAS`, via the `mssql-mas` MCP server). Captured 2026-07-14, revised 2026-07-14 after correcting the master-data definition.

Row counts were pulled from `sys.partitions` (index_id 0/1), not `SELECT COUNT(*)`, so they are fast estimates rather than a live count — accurate enough for this snapshot since no writes were made after the `MAS_09` relaxed sample load (see [07-seed-runbook.md](./07-seed-runbook.md)). Production counts are cross-referenced from `database/metadata/export-20260713/05_row_counts.csv`.

## Overall

| Object type | Count |
|---|---:|
| Tables | 570 |
| Views | 437 |
| Stored procedures | 399 |

## Row Count Distribution (Local Seed)

| Row count bucket | Approx. table count | Notes |
|---|---:|---|
| = 100 | ~110 | Hits the seed export's `TOP 100` ceiling exactly — includes both entity tables (`tEmployee`, `tTimeInOut`, `tPayroll`) and some true config tables (see gaps below) |
| 10–98 | ~40 | Small lookup/config tables, e.g. `tProvince` (77), `tBankMaster` (56), `tRequestType` (43) |
| 1–9 | ~60 | Minimal master data, e.g. `tCompany` (3), `tGender` (3), `tNationality` (3) |
| 0 | ~350 | Empty — mostly temp/log/staging tables, and entire schemas (`billing`, `payroll`, `rosetta`) that the relaxed seed did not populate |

The exact-100 cluster confirms these rows are sample data from the `MAS_05_top100_all_tables.txt` export, not production volume.

## What Counts As Master Data Here

Master data = static config/enum/lookup tables and org-structure tables (department/division/site), shape is typically `ID + description`, and other tables reference it by FK. This explicitly **excludes**:

- `tUser`, `tEmployee`, `tEmployee_New` — these hold real entity records (actual people/accounts), not configuration
- `tTax91` — looked like a tax reference table by name, but `describe_table` shows columns `EmployeeCode` + `Period` plus dozens of per-period tax computation fields. It is a **transactional** table (one row per employee per tax period), not master data.

## สรุปที่แก้ไขแล้ว: Master/Config Data ที่แท้จริง

หลักการคัดกรอง: ตารางแบบ ID + คำอธิบาย (lookup/enum) หรือ org hierarchy — ไม่ใช่ตารางที่เก็บ record ของ entity จริง (คน/user) หรือ transaction รายงวด

| กลุ่ม | ตาราง | Production | Local (seed) | สถานะ |
|---|---|---:|---:|---|
| โครงสร้างองค์กร (แผนก/ฝ่าย) | `tCompany` | 3 | 3 | ✅ ครบ |
| | `tBU1` (org level 1) | 532 | 100 | ⚠️ ขาด 432 |
| | `tBU1_New` | 560 | 100 | ⚠️ ขาด 460 |
| | `tBU2` (level 2) | 4 | 4 | ✅ ครบ |
| | `tBU3` / `tBU4` (level 3/4) | 1 / 1 | 1 / 1 | ✅ ครบ |
| | `tCostCenter` | 3 | 3 | ✅ ครบ |
| | `tProject` | 5 | 5 | ✅ ครบ |
| | `tSiteTR` (site master) | 187 | 100 | ⚠️ ขาด 87 |
| Enum/Type พนักงาน | `tEmployeeType1/2/3` | 5/1/2 | เท่ากัน | ✅ ครบ |
| | `tEmployeeStatus`, `tEmployeeStatusGroup` | 3, 3 | เท่ากัน | ✅ ครบ |
| | `tEmployeeLevel` | 14 | 14 | ✅ ครบ |
| | `tEmployeeTitle` (ตำแหน่งงาน) | 209 | 100 | ⚠️ ขาด 109 |
| | `tGender`, `tNationality`, `tMartialStatus`, `tPrefix` | 3,3,5,3 | เท่ากัน | ✅ ครบ |
| | `tResignReason` | 678 | 100 | ⚠️ ขาด 578 |
| Enum วินัย/รางวัล | `tGUILTY_Type`, `tPENALTY_Type`, `tPunishmentStyle`, `tAward_Type`, `tCertificationStyle`, `tBadgeStyle`, `tCardStatus_Type` | ≤39 ทุกตัว | เท่ากัน | ✅ ครบ |
| อบรม | `tTrainingType/Mode/Place/Company` | ≤7 | เท่ากัน (บาง 0) | ✅ ครบ (ว่างจริง) |
| ธนาคาร/ภูมิศาสตร์ | `tBankMaster`, `tBankName`, `tProvince` | 56, 36, 77 | เท่ากัน | ✅ ครบ |
| Workflow/Request config | `tRequestType`, `tFlow`, `tFlowPath`, `tRule`, `tRequestSystem`, `tApproverList` | ≤43 ทุกตัว | เท่ากัน | ✅ ครบ |
| ระบบ | `tSysParm`, `tSysConfig`, `tSysSettings` | 58,6,2 | เท่ากัน | ✅ ครบ |
| กะ/ปฏิทิน | `tShift`, `tWorkCalendar` | 7, 3 | เท่ากัน | ✅ ครบ |

ตัดออกจาก master data:

- `tUser`, `tEmployee`, `tEmployee_New` → entity records ของคนจริง ไม่ใช่ config
- `tTax91` → ตรวจ schema แล้วมีคอลัมน์ `EmployeeCode` + `Period` คือบันทึกภาษีรายคนรายงวด เป็น transactional ไม่ใช่ config

## สรุป: ต้องไปดึงเพิ่ม 5 ตารางนี้

| ตาราง | ขาดไป |
|---|---:|
| `tResignReason` | 578 แถว |
| `tBU1_New` | 460 แถว |
| `tBU1` | 432 แถว |
| `tEmployeeTitle` | 109 แถว |
| `tSiteTR` | 87 แถว |

ตัวเหล่านี้เล็ก (รวมกันไม่ถึง 1,700 แถว) ดึงเต็มจำนวนจาก production ได้เลยโดยไม่กระทบขนาด seed มาก — ดูขั้นตอน export/import ที่ [07-seed-runbook.md](./07-seed-runbook.md)

นอกเหนือจาก 5 ตารางนี้ master/config table อื่นๆ ทั้งหมด local seed ตรงกับ production 100%

## How To Reproduce

```sql
SELECT s.name AS schema_name, t.name AS table_name, p.rows AS row_count
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
ORDER BY p.rows DESC;
```

Run via the `mssql-mas` MCP server (`execute_read_query`) or any client connected to `localhost,14333` / database `MAS`. Production counts referenced above come from `database/metadata/export-20260713/05_row_counts.csv`, not from a live query against production.
