/* --------------------------------------------------------------------------
   Company / Site data-quality report for the local analysis database.

   Run from the repo root:  ./scripts/check-site-data.sh
   Sections:
     1 VOLUME     - row counts of every site-related table
     2 ORPHAN     - rows pointing at a Site_ID that is not in dbo.tSiteTR
     3 MASTER     - completeness of the site master itself
     4 COVERAGE   - how much of the dataset is actually usable for analysis
     5 EMPLOYEE   - company / site / role spread of the exported employees
     6 JOIN       - employee columns that do not resolve to their lookup table
   -------------------------------------------------------------------------- */
SET NOCOUNT ON;

DECLARE @r TABLE (
    seq     int IDENTITY(1,1),
    section varchar(10),
    metric  varchar(60),
    value   varchar(40),
    status  varchar(6)
);

/* ---------------- 1. VOLUME ---------------------------------------------- */
INSERT @r (section, metric, value, status)
SELECT 'VOLUME',
       s.name + '.' + t.name,
       CAST(SUM(p.rows) AS varchar(40)),
       CASE WHEN SUM(p.rows) = 0 THEN 'EMPTY' ELSE 'ok' END
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
WHERE s.name + '.' + t.name IN (
        'dbo.tCompany', 'dbo.tSiteTR', 'dbo.tSiteRate', 'dbo.tSiteTR_BU_Mapping',
        'dbo.tSiteTR_MappingScan', 'dbo.tSiteUpdate', 'dbo.tSiteUpdatePlan',
        'dbo.tShift', 'dbo.tEmployee', 'dbo.tTimeInOut', 'dbo.tTimeInOut_Data',
        'dbo.tPayroll', 'dbo.tCostAllocation', 'dbo.tTempTransfer',
        'dbo.tTimeSheet', 'dbo.tTimeSheet_MultiPeriod',
        'customize.tSCC_AprvSite', 'customize.tSCC_TranferSite',
        'customize.tSCC_TranferEmp', 'customize.tLog_Tranfersite',
        'customize.tSCC_SettingIncentive', 'customize.tSCC_SelectFilter',
        'customize.tSCC_PayAllowance', 'customize.tMOD_LogSetting')
GROUP BY s.name, t.name;

/* ---------------- 2. ORPHAN ---------------------------------------------- */
INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tEmployee.Site_ID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e
WHERE e.Site_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = e.Site_ID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tTimeInOut.Site_ID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tTimeInOut t
WHERE t.Site_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = t.Site_ID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tTimeInOut_Data.Time_Site_ID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tTimeInOut_Data d
WHERE d.Time_Site_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = d.Time_Site_ID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tShift.Site_ID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tShift sh
WHERE sh.Site_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = sh.Site_ID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tPayroll.Site_ID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tPayroll p
WHERE p.Site_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = p.Site_ID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tSCC_AprvSite.Site_ID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM customize.tSCC_AprvSite a
WHERE NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = a.Site_ID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tSCC_TranferSite.Tranfer_SiteID not in tSiteTR', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM customize.tSCC_TranferSite ts
WHERE NOT EXISTS (SELECT 1 FROM dbo.tSiteTR s WHERE s.Site_ID = ts.Tranfer_SiteID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tSCC_TranferEmp without matching TranferSite', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM customize.tSCC_TranferEmp te
WHERE NOT EXISTS (SELECT 1 FROM customize.tSCC_TranferSite ts WHERE ts.RequestID = te.RequestID);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tSCC_TranferEmp.EmployeeCode not in tEmployee', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM customize.tSCC_TranferEmp te
WHERE te.EmployeeCode IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tEmployee e WHERE e.EmployeeCode = te.EmployeeCode);

INSERT @r (section, metric, value, status)
SELECT 'ORPHAN', 'tTimeInOut.EmployeeCode not in tEmployee', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tTimeInOut t
WHERE NOT EXISTS (SELECT 1 FROM dbo.tEmployee e WHERE e.EmployeeCode = t.EmployeeCode);

/* ---------------- 3. MASTER ---------------------------------------------- */
INSERT @r (section, metric, value, status)
SELECT 'MASTER', 'tSiteTR rows', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'EMPTY' ELSE 'ok' END FROM dbo.tSiteTR;

INSERT @r (section, metric, value, status)
SELECT 'MASTER', 'sites active (Site_Status = 1)', CAST(COUNT(*) AS varchar(40)), 'info'
FROM dbo.tSiteTR WHERE Site_Status = 1;

INSERT @r (section, metric, value, status)
SELECT 'MASTER', 'sites with blank Site_No', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tSiteTR WHERE Site_No IS NULL OR LTRIM(RTRIM(Site_No)) = '';

INSERT @r (section, metric, value, status)
SELECT 'MASTER', 'sites with blank Site_Name', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tSiteTR WHERE Site_Name IS NULL OR LTRIM(RTRIM(Site_Name)) = '';

INSERT @r (section, metric, value, status)
SELECT 'MASTER', 'sites with blank Site_Area', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tSiteTR WHERE Site_Area IS NULL OR LTRIM(RTRIM(Site_Area)) = '';

INSERT @r (section, metric, value, status)
SELECT 'MASTER', 'duplicate Site_No', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM (SELECT Site_No FROM dbo.tSiteTR WHERE Site_No IS NOT NULL
      GROUP BY Site_No HAVING COUNT(*) > 1) d;

/* ---------------- 4. COVERAGE -------------------------------------------- */
INSERT @r (section, metric, value, status)
SELECT 'COVER', 'employees without Site_ID', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee WHERE Site_ID IS NULL;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'sites that have at least one employee', CAST(COUNT(DISTINCT Site_ID) AS varchar(40)), 'info'
FROM dbo.tEmployee WHERE Site_ID IS NOT NULL;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'sites with employees but no attendance rows', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM (SELECT DISTINCT e.Site_ID
      FROM dbo.tEmployee e
      WHERE e.Site_ID IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM dbo.tTimeInOut_Data d WHERE d.Time_Site_ID = e.Site_ID)) x;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'employees with attendance rows', CAST(COUNT(DISTINCT EmployeeCode) AS varchar(40)), 'info'
FROM dbo.tTimeInOut;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'attendance date range',
       ISNULL(MIN(DateStamp), '-') + ' .. ' + ISNULL(MAX(DateStamp), '-'), 'info'
FROM dbo.tTimeInOut;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'distinct sites seen in attendance', CAST(COUNT(DISTINCT Time_Site_ID) AS varchar(40)), 'info'
FROM dbo.tTimeInOut_Data WHERE Time_Site_ID IS NOT NULL;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'transfer requests spanning 2+ sites per employee', CAST(COUNT(*) AS varchar(40)), 'info'
FROM (SELECT te.EmployeeCode
      FROM customize.tSCC_TranferEmp te
      JOIN customize.tSCC_TranferSite ts ON ts.RequestID = te.RequestID
      GROUP BY te.EmployeeCode
      HAVING COUNT(DISTINCT ts.Tranfer_SiteID) > 1) x;

INSERT @r (section, metric, value, status)
SELECT 'COVER', 'shifts bound to a site', CAST(COUNT(*) AS varchar(40)), 'info'
FROM dbo.tShift WHERE Site_ID IS NOT NULL;


/* ---------------- 5. EMPLOYEE ---------------------------------------------- */
INSERT @r (section, metric, value, status)
SELECT 'EMP', 'employees', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'EMPTY' ELSE 'ok' END FROM dbo.tEmployee;

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'companies represented (via tProject.SSOACC_ID)',
       CAST(COUNT(DISTINCT pj.SSOACC_ID) AS varchar(40)), 'info'
FROM dbo.tEmployee e JOIN dbo.tProject pj ON pj.PRJ_ID = e.PRJ_ID;

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'payroll groups represented (PRJ_ID)', CAST(COUNT(DISTINCT PRJ_ID) AS varchar(40)), 'info'
FROM dbo.tEmployee WHERE PRJ_ID IS NOT NULL;

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'roles represented (EMPTT_ID) of master', 
       CAST((SELECT COUNT(DISTINCT EMPTT_ID) FROM dbo.tEmployee WHERE EMPTT_ID IS NOT NULL) AS varchar(20))
       + ' / ' + CAST((SELECT COUNT(*) FROM dbo.tEmployeeTitle) AS varchar(20)), 'info';

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'employee levels represented (EmpLevel_ID)',
       CAST((SELECT COUNT(DISTINCT EmpLevel_ID) FROM dbo.tEmployee WHERE EmpLevel_ID IS NOT NULL) AS varchar(20))
       + ' / ' + CAST((SELECT COUNT(*) FROM dbo.tEmployeeLevel) AS varchar(20)), 'info';

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'employee types represented (EMPTP1_ID)',
       CAST((SELECT COUNT(DISTINCT EMPTP1_ID) FROM dbo.tEmployee WHERE EMPTP1_ID IS NOT NULL) AS varchar(20))
       + ' / ' + CAST((SELECT COUNT(*) FROM dbo.tEmployeeType1) AS varchar(20)), 'info';

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'distinct company x site x role combinations', CAST(COUNT(*) AS varchar(40)), 'info'
FROM (SELECT DISTINCT pj.SSOACC_ID AS c, e.Site_ID AS s, e.EMPTT_ID AS r
      FROM dbo.tEmployee e LEFT JOIN dbo.tProject pj ON pj.PRJ_ID = e.PRJ_ID) x;

INSERT @r (section, metric, value, status)
SELECT 'EMP', 'employee-related tables holding rows', CAST(COUNT(*) AS varchar(40)), 'info'
FROM (SELECT t.object_id
      FROM sys.tables t
      JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'EmployeeCode'
      JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
      GROUP BY t.object_id
      HAVING SUM(p.rows) > 0) x;

/* ---------------- 6. JOIN -------------------------------------------------- */
INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.EMPTT_ID not in tEmployeeTitle', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.EMPTT_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tEmployeeTitle m WHERE m.EMPTT_ID = e.EMPTT_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.EmpLevel_ID not in tEmployeeLevel', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.EmpLevel_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tEmployeeLevel m WHERE m.EmpLevel_ID = e.EmpLevel_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.EMPTP1_ID not in tEmployeeType1', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.EMPTP1_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tEmployeeType1 m WHERE m.EMPTP1_ID = e.EMPTP1_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.EMPST_ID not in tEmployeeStatus', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.EMPST_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tEmployeeStatus m WHERE m.EMPST_ID = e.EMPST_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.PRJ_ID not in tProject', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.PRJ_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tProject m WHERE m.PRJ_ID = e.PRJ_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.BU1_ID not in tBU1', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.BU1_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tBU1 m WHERE m.BU1_ID = e.BU1_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.FIX_SHF_ID not in tShift', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.FIX_SHF_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tShift m WHERE m.SHF_ID = e.FIX_SHF_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tEmployee.FIX_WCD_ID not in tWorkCalendar', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tEmployee e WHERE e.FIX_WCD_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tWorkCalendar m WHERE m.WCD_ID = e.FIX_WCD_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tProject.SSOACC_ID not in tCompany', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tProject p WHERE p.SSOACC_ID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.tCompany c WHERE c.CPN_ID = p.SSOACC_ID);

INSERT @r (section, metric, value, status)
SELECT 'JOIN', 'tPayroll rows without a matching employee', CAST(COUNT(*) AS varchar(40)),
       CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'WARN' END
FROM dbo.tPayroll p
WHERE NOT EXISTS (SELECT 1 FROM dbo.tEmployee e WHERE e.EmployeeCode = p.EmployeeCode);

SELECT section, metric, value, status FROM @r ORDER BY seq;

PRINT '';
PRINT 'status: ok = clean, WARN = needs a look, EMPTY = no rows, info = context only.';
PRINT 'EMPTY on tSiteRate / tSiteTR_*_Mapping / tSiteUpdate* / tCostAllocation is expected -';
PRINT 'those tables are also empty in production.';
