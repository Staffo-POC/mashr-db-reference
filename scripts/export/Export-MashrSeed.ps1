#requires -version 3.0
<#
.SYNOPSIS
    Export a company/site/role-complete MAS HR dataset from the production SQL
    Server into seed .sql files that mashr-db-reference can import into Docker.

.DESCRIPTION
    Read-only. Runs SELECT statements only; never writes to the source database.

    Employee selection is stratified: for every (company x site x role)
    combination that exists in dbo.tEmployee it takes -EmployeesPerGroup
    employees, then backfills so that every distinct position, level, employee
    type, status, department and payroll group is represented by at least one
    employee. That is what makes joins resolve instead of coming back empty.

    Everything that hangs off those employees is then exported with them: the
    lookup masters they point at (full), and every table in the database that
    carries an EmployeeCode (filtered to the selected employees).

.EXAMPLE
    .\Export-MashrSeed.ps1 -DryRun
    Show the coverage plan and row counts without writing anything.

.EXAMPLE
    .\Export-MashrSeed.ps1 -EmployeesPerGroup 2 -Months 3

.EXAMPLE
    .\Export-MashrSeed.ps1 -SiteNo '999_S2','2800_S2' -EmployeesPerGroup 5 -Months 6
#>
[CmdletBinding()]
param(
    # --- connection -------------------------------------------------------
    [string]   $Server              = 'localhost',
    [string]   $Database            = 'MAS',
    [string]   $SqlUser             = '',            # blank = Windows auth
    [string]   $SqlPassword         = '',

    # --- site scope -------------------------------------------------------
    [string[]] $SiteNo              = @(),           # explicit Site_No list; empty = every site
    [int]      $TopSites            = 0,             # 0 = all sites, N = N sites with most employees

    # --- employee scope ---------------------------------------------------
    [int]      $EmployeesPerGroup   = 2,             # employees per company x site x role
    [int]      $MaxEmployees        = 1500,          # cap before dimension backfill
    [string]   $RoleColumn          = 'EMPTT_ID',    # dimension treated as "role"
    [switch]   $NoDimensionBackfill,                 # skip the every-role-represented pass
    [int]      $MaxTransferEmployees= 300,           # extra employees pulled in via site transfers

    # --- attendance window ------------------------------------------------
    [int]      $Months              = 3,
    [string]   $DateFrom            = '',            # yyyyMMdd (overrides -Months)
    [string]   $DateTo              = '',            # yyyyMMdd (default: latest date in data)

    # --- related tables ---------------------------------------------------
    [bool]     $IncludeRelatedTables = $true,        # every table carrying an EmployeeCode
    [string]   $ExcludeTablePattern  = '^(tTemp_|tTempBatch|tTempCalTime|tTempGet_|tTempImportPlan$|tTempTimeInOut$|tTempEmployee_|Temp_|tTraining_Temp$|TempTable)',

    # --- safety / privacy -------------------------------------------------
    [ValidateSet('None','Basic','Full')]
    [string]   $Mask                = 'Basic',
    [int]      $MaxRowsPerTable     = 50000,         # 0 = unlimited
    [switch]   $IncludeBinary,

    # --- output -----------------------------------------------------------
    [string]   $OutRoot             = '',
    [string]   $SnapshotName        = '',
    [switch]   $DryRun,
    [switch]   $NoZip
)

$ErrorActionPreference = 'Stop'
$script:Inv = [System.Globalization.CultureInfo]::InvariantCulture

# ---------------------------------------------------------------------------
# Lookup masters. Exported in full so every employee column resolves to a name.
# Tables that do not exist on the server are skipped and listed in the manifest.
# ---------------------------------------------------------------------------
$MasterTables = @(
    # company / org structure
    'dbo.tCompany', 'dbo.tProject', 'dbo.tSiteTR', 'dbo.tSiteRate',
    'dbo.tSiteTR_BU_Mapping', 'dbo.tSiteTR_MappingScan',
    'dbo.tSiteUpdatePlan', 'dbo.tSiteUpdate',
    'dbo.tBU1', 'dbo.tBU2', 'dbo.tBU3', 'dbo.tBU4',
    'dbo.tCostCenter', 'dbo.tCostCenter_BU_Mapping',
    # employee dimensions ("role" in every sense the app uses)
    'dbo.tEmployeeTitle', 'dbo.tEmployeeTitle2', 'dbo.tEmployeeLevel',
    'dbo.tEmployeeStatus', 'dbo.tEmployeeType1', 'dbo.tEmployeeType2',
    'dbo.tEmployeeType3', 'dbo.tEMPTP1_2_Mapping', 'dbo.tEMPTP2_3_Mapping',
    # personal lookups
    'dbo.tPrefix', 'dbo.tGender', 'dbo.tNationality', 'dbo.tMartialStatus',
    'dbo.tReligion', 'dbo.tProvince', 'dbo.tResignReason', 'dbo.tLeaveReason',
    'dbo.tBankBranch', 'dbo.tCourse', 'dbo.tTrainingCompany',
    # time / payroll configuration
    'dbo.tShift', 'dbo.tShiftGroup', 'dbo.tShiftProject',
    'dbo.tWorkCalendar', 'dbo.tWorkCalendarDetail', 'dbo.tWorkCalendarShiftPattern',
    'dbo.tBillChargeRate', 'dbo.tPeriod_ChargeRate', 'dbo.tPreset_Leave',
    'dbo.tBatchLeave', 'dbo.tBatchProbation', 'dbo.tOTRequest_Form',
    'dbo.tPVFSub', 'dbo.tPMPeriod', 'dbo.tPayroll_ColDef', 'dbo.tPayroll_GLAccNo',
    'dbo.tProject_GLAccNo', 'dbo.tProject_GLAccNoRow',
    # menus (so the app's navigation matches production)
    'dbo.tSYS_WebMenu', 'dbo.tSYSOutPayMenu', 'dbo.tSYSOutPayMenuAdvance',
    'dbo.tSystem_CustomMenu',
    # customize / SCC site module
    'customize.tSCC_AprvSite', 'customize.tMOD_LogSetting',
    'customize.tSCC_SettingPayAllowance'
)

# ---------------------------------------------------------------------------
# Site-scoped tables (no EmployeeCode column, so they are matched on Site_ID).
# ---------------------------------------------------------------------------
$SiteScopedTables = @(
    @{ Table='dbo.tCostAllocation';              Where='Site_ID IN (SELECT Site_ID FROM #Sites)' }
    @{ Table='dbo.tTimeSheet_MultiPeriod';       Where='Site_ID IN (SELECT Site_ID FROM #Sites)' }
    @{ Table='customize.tSCC_SettingIncentive';  Where='Site_ID IN (SELECT Site_ID FROM #Sites)' }
    @{ Table='customize.tMOD_SettingIncentive';  Where='Site_ID IN (SELECT Site_ID FROM #Sites)' }
    @{ Table='customize.tSCC_TranferSite';
       Where='Tranfer_SiteID IN (SELECT Site_ID FROM #Sites) OR RequestID IN (SELECT RequestID FROM customize.tSCC_TranferEmp WHERE EmployeeCode IN (SELECT EmployeeCode FROM #Emps))' }
)

# ---------------------------------------------------------------------------
# Employee-scoped tables that use a different column name than EmployeeCode,
# plus the date-limited attendance tables. Everything else with a plain
# EmployeeCode column is discovered automatically.
# ---------------------------------------------------------------------------
$EmployeeScopedOverrides = @{
    'dbo.tTimeInOut'      = "EmployeeCode IN (SELECT EmployeeCode FROM #Emps) AND DateStamp BETWEEN '{DATEFROM}' AND '{DATETO}'"
    'dbo.tLOG_TimeInOut'  = "EmployeeCode IN (SELECT EmployeeCode FROM #Emps) AND DateStamp BETWEEN '{DATEFROM}' AND '{DATETO}'"
    'dbo.tTimeStamp'      = "EmployeeCode IN (SELECT EmployeeCode FROM #Emps) AND DateStamp BETWEEN '{DATEFROM}' AND '{DATETO}'"
}
$ExtraEmployeeTables = @(
    @{ Table='dbo.tTimeInOut_Data'; Where="Time_EmployeeCode IN (SELECT EmployeeCode FROM #Emps) AND Time_DateStamp BETWEEN '{DATEFROM}' AND '{DATETO}'" }
    @{ Table='dbo.tTempTransfer';   Where='Site_ID IN (SELECT Site_ID FROM #Sites)' }
)

# ---------------------------------------------------------------------------
# PII masking rules (column-name based, applied to every exported table).
# ---------------------------------------------------------------------------
$script:MaskRules = @(
    @{ Pattern='^(FirstName|LastName|EnglishName|FirstName_EN|LastName_EN|NickName|FatherName|MotherName|SpouseName|EmergencyName)$'; Kind='Name' }
    @{ Pattern='^(Address|Address2|Address_EN|Address2_EN|CurrentAddress|RegisterAddress)$';                                          Kind='Address' }
    @{ Pattern='^(TelNO|TelNO2|OTP_TelNo|MobileNo|FaxNo|EmergencyTel)$';                                                              Kind='Phone' }
    @{ Pattern='^(Email|Email2|PersonalEmail)$';                                                                                      Kind='Email' }
    @{ Pattern='^(TAXID|IDCardNo|ID_Card|PersonalID|CitizenID|PassportNo|SSO_CardID|SSORSR_Code)$';                                    Kind='IdNo' }
    @{ Pattern='^(Accountno|AccountNo|BankAccountNo|BankOption_EmpId|BankName|BankBranch)$';                                           Kind='Bank' }
    @{ Pattern='^(SSO_Hospital1|SSO_Hospital2|SSO_Hospital3|SSO_LastCompany|SSO_ManyCompany)$';                                        Kind='Free' }
    @{ Pattern='^(BirthDate)$';                                                                                                       Kind='BirthDate' }
)
$script:MaskRulesFull = @(
    @{ Pattern='^(WageRate|OT1Rate|OT1_5Rate|OT2Rate|OT3Rate|BillWageRate|BillOT1Rate|BillOT1_5Rate|BillOT2Rate|BillOT3Rate|NetIncome_REG|Salary|BaseSalary)$'; Kind='Zero' }
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Step { param([string]$Text) Write-Host "  $Text" }

function Get-StableHash {
    param([string]$Text)
    # 0xFFFFFFFF parses as a signed int (-1) in Windows PowerShell, which would
    # leave the accumulator unmasked and overflow into a double - use the
    # explicit 64-bit literal instead.
    $mask = 4294967295L
    $h = [int64]2166136261
    foreach ($ch in $Text.ToCharArray()) {
        $h = ($h -bxor [int64][int]$ch) -band $mask
        $h = ($h * 16777619) -band $mask
    }
    return $h
}

function Get-MaskedValue {
    param([object]$Value, [string]$Column, [string]$Mode)
    if ($Mode -eq 'None') { return $Value }
    if ($null -eq $Value -or $Value -is [System.DBNull]) { return $Value }

    $kind = $null
    foreach ($rule in $script:MaskRules) {
        if ($Column -match $rule.Pattern) { $kind = $rule.Kind; break }
    }
    if (-not $kind -and $Mode -eq 'Full') {
        foreach ($rule in $script:MaskRulesFull) {
            if ($Column -match $rule.Pattern) { $kind = $rule.Kind; break }
        }
    }
    if (-not $kind) { return $Value }

    $h = Get-StableHash ([string]$Value)
    switch ($kind) {
        'Name'      { return ('EMP-{0:X6}' -f ($h % 16777216)) }
        'Address'   { return ('ADDR-{0:X6}' -f ($h % 16777216)) }
        'Phone'     { return ('08{0:D8}' -f ($h % 100000000)) }
        'Email'     { return ('user{0:x8}@example.local' -f $h) }
        'IdNo'      { return ('{0:D13}' -f (1000000000000 + ($h % 999999999999))) }
        'Bank'      { return ('ACC{0:D10}' -f ($h % 10000000000)) }
        'Free'      { return ('MASKED-{0:X6}' -f ($h % 16777216)) }
        'BirthDate' { return (New-Object System.DateTime(([datetime]$Value).Year, 1, 1)) }
        'Zero'      { return 0 }
    }
    return $Value
}

function Join-Wrapped {
    # sqlcmd refuses to read very long input lines, and a wide table such as
    # tEmployee produces column/value lists of tens of thousands of characters.
    # Join the parts with ", " but break to a new physical line before the
    # statement gets too wide. SQL itself does not care about the newlines.
    param([string[]]$Parts, [int]$MaxLineLength = 700)
    $sb  = New-Object System.Text.StringBuilder
    $len = 0
    for ($i = 0; $i -lt $Parts.Count; $i++) {
        $piece = $Parts[$i]
        if ($i -lt $Parts.Count - 1) { $piece = $piece + ',' }
        if ($len -gt 0 -and ($len + $piece.Length + 1) -gt $MaxLineLength) {
            [void]$sb.Append("`n")
            $len = 0
        } elseif ($len -gt 0) {
            [void]$sb.Append(' ')
            $len = $len + 1
        }
        [void]$sb.Append($piece)
        $len = $len + $piece.Length
    }
    return $sb.ToString()
}

function Format-SqlLiteral {
    param([object]$Value, [string]$Type)
    if ($null -eq $Value -or $Value -is [System.DBNull]) { return 'NULL' }
    $t = $Type.ToLowerInvariant()

    if ($t -eq 'bit') { if ([bool]$Value) { return '1' } else { return '0' } }
    if (@('tinyint','smallint','int','bigint') -contains $t) { return [string][int64]$Value }
    if (@('decimal','numeric','money','smallmoney') -contains $t) { return ([decimal]$Value).ToString($script:Inv) }
    if (@('float','real') -contains $t) { return ([double]$Value).ToString('R', $script:Inv) }
    if ($t -eq 'uniqueidentifier') { return "N'" + $Value.ToString() + "'" }
    if ($t -eq 'date') { return "N'" + ([datetime]$Value).ToString('yyyy-MM-dd') + "'" }
    if (@('datetime','smalldatetime','datetime2') -contains $t) {
        return "N'" + ([datetime]$Value).ToString('yyyy-MM-ddTHH:mm:ss.fff') + "'"
    }
    if ($t -eq 'datetimeoffset') { return "N'" + ([datetimeoffset]$Value).ToString('yyyy-MM-ddTHH:mm:ss.fffzzz') + "'" }
    if ($t -eq 'time') { return "N'" + ([timespan]$Value).ToString('hh\:mm\:ss\.fffffff') + "'" }
    if (@('binary','varbinary','image') -contains $t) {
        $bytes = [byte[]]$Value
        if ($bytes.Length -eq 0) { return '0x' }
        return '0x' + [System.BitConverter]::ToString($bytes).Replace('-','')
    }
    return "N'" + ([string]$Value).Replace("'","''") + "'"
}

function Invoke-Scalar {
    param($Connection, [string]$Sql, [hashtable]$Parameters = @{})
    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $Sql
    $cmd.CommandTimeout = 0
    foreach ($key in $Parameters.Keys) { [void]$cmd.Parameters.AddWithValue($key, $Parameters[$key]) }
    try { return $cmd.ExecuteScalar() } finally { $cmd.Dispose() }
}

function Invoke-NonQuery {
    param($Connection, [string]$Sql, [hashtable]$Parameters = @{})
    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $Sql
    $cmd.CommandTimeout = 0
    foreach ($key in $Parameters.Keys) { [void]$cmd.Parameters.AddWithValue($key, $Parameters[$key]) }
    try { return $cmd.ExecuteNonQuery() } finally { $cmd.Dispose() }
}

function Invoke-Rows {
    param($Connection, [string]$Sql, [hashtable]$Parameters = @{})
    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $Sql
    $cmd.CommandTimeout = 0
    foreach ($key in $Parameters.Keys) { [void]$cmd.Parameters.AddWithValue($key, $Parameters[$key]) }
    $reader = $cmd.ExecuteReader()
    $rows = @()
    while ($reader.Read()) {
        $row = @{}
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $v = $reader.GetValue($i)
            if ($v -is [System.DBNull]) { $v = $null }
            $row[$reader.GetName($i)] = $v
        }
        $rows += [pscustomobject]$row
    }
    $reader.Close()
    $cmd.Dispose()
    return $rows
}

function Test-ObjectExists {
    param($Connection, [string]$FullName)
    $parts = $FullName.Split('.')
    $oid = Invoke-Scalar $Connection 'SELECT OBJECT_ID(@o)' @{ '@o' = "[$($parts[0])].[$($parts[1])]" }
    return ($null -ne $oid -and $oid -isnot [System.DBNull])
}

function Test-ColumnExists {
    param($Connection, [string]$FullName, [string]$Column)
    $parts = $FullName.Split('.')
    $n = Invoke-Scalar $Connection @'
SELECT COUNT(*) FROM sys.columns
WHERE object_id = OBJECT_ID(@o) AND name = @c
'@ @{ '@o' = "[$($parts[0])].[$($parts[1])]"; '@c' = $Column }
    return ([int]$n -gt 0)
}

function Get-TableColumns {
    param($Connection, [string]$Schema, [string]$Table, [bool]$WithBinary)
    $sql = @"
SELECT c.name AS ColumnName, ty.name AS TypeName, c.is_identity AS IsIdentity
FROM sys.columns c
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID(@obj)
  AND c.is_computed = 0
  AND ty.name NOT IN ('timestamp','rowversion','sql_variant','hierarchyid','geography','geometry')
ORDER BY c.column_id
"@
    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $sql
    [void]$cmd.Parameters.AddWithValue('@obj', "[$Schema].[$Table]")
    $reader = $cmd.ExecuteReader()
    $cols = @()
    while ($reader.Read()) {
        $type = $reader['TypeName']
        if (-not $WithBinary -and (@('binary','varbinary','image') -contains $type)) { continue }
        $cols += [pscustomobject]@{
            Name       = [string]$reader['ColumnName']
            Type       = [string]$type
            IsIdentity = [bool]$reader['IsIdentity']
        }
    }
    $reader.Close()
    $cmd.Dispose()
    return $cols
}

# ---------------------------------------------------------------------------
# Connect
# ---------------------------------------------------------------------------
if ($SqlUser) {
    $connString = "Server=$Server;Database=$Database;User ID=$SqlUser;Password=$SqlPassword;TrustServerCertificate=True;Application Name=mashr-export"
} else {
    $connString = "Server=$Server;Database=$Database;Integrated Security=SSPI;TrustServerCertificate=True;Application Name=mashr-export"
}

Write-Host ''
Write-Host '=== MAS HR seed export ===' -ForegroundColor Cyan
Write-Step "Server   : $Server"
Write-Step "Database : $Database"
Write-Step "Mask     : $Mask"

$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()

try {
    # -----------------------------------------------------------------------
    # Validate the role dimension
    # -----------------------------------------------------------------------
    if (-not (Test-ColumnExists $conn 'dbo.tEmployee' $RoleColumn)) {
        throw "-RoleColumn '$RoleColumn' does not exist on dbo.tEmployee."
    }
    $roleCol = '[' + $RoleColumn + ']'

    # -----------------------------------------------------------------------
    # Scope: #Sites
    # -----------------------------------------------------------------------
    Invoke-NonQuery $conn "IF OBJECT_ID('tempdb..#Sites') IS NOT NULL DROP TABLE #Sites;
CREATE TABLE #Sites (Site_ID uniqueidentifier PRIMARY KEY);" | Out-Null

    $allSites = $false
    if ($SiteNo.Count -gt 0) {
        $params = @{}
        $names  = @()
        for ($i = 0; $i -lt $SiteNo.Count; $i++) {
            $names  += "@s$i"
            $params["@s$i"] = $SiteNo[$i]
        }
        $inList = $names -join ','
        Invoke-NonQuery $conn "INSERT #Sites (Site_ID) SELECT Site_ID FROM dbo.tSiteTR WHERE Site_No IN ($inList);" $params | Out-Null
    } elseif ($TopSites -gt 0) {
        Invoke-NonQuery $conn @"
INSERT #Sites (Site_ID)
SELECT TOP (@n) s.Site_ID
FROM dbo.tSiteTR s
LEFT JOIN (SELECT Site_ID, COUNT(*) AS c FROM dbo.tEmployee WHERE Site_ID IS NOT NULL GROUP BY Site_ID) e
       ON e.Site_ID = s.Site_ID
ORDER BY ISNULL(e.c, 0) DESC, s.Site_Status DESC, s.Site_No;
"@ @{ '@n' = $TopSites } | Out-Null
    } else {
        $allSites = $true
        Invoke-NonQuery $conn 'INSERT #Sites (Site_ID) SELECT Site_ID FROM dbo.tSiteTR;' | Out-Null
    }

    $siteCount = [int](Invoke-Scalar $conn 'SELECT COUNT(*) FROM #Sites')
    if ($siteCount -eq 0) { throw 'No sites matched. Check -SiteNo values against dbo.tSiteTR.Site_No.' }
    if ($allSites) { Write-Step "Sites    : $siteCount (all sites)" }
    else {
        $siteNames = Invoke-Scalar $conn @"
SELECT STUFF((SELECT ', ' + ISNULL(s.Site_No, '(null)')
              FROM dbo.tSiteTR s WHERE s.Site_ID IN (SELECT Site_ID FROM #Sites)
              ORDER BY s.Site_No FOR XML PATH('')), 1, 2, '')
"@
        Write-Step "Sites    : $siteCount  ($siteNames)"
    }

    # -----------------------------------------------------------------------
    # Scope: #Emps - stratified over company x site x role
    # -----------------------------------------------------------------------
    Invoke-NonQuery $conn "IF OBJECT_ID('tempdb..#Emps') IS NOT NULL DROP TABLE #Emps;
CREATE TABLE #Emps (EmployeeCode varchar(100) COLLATE DATABASE_DEFAULT PRIMARY KEY);" | Out-Null

    # Prefer employees who are still employed, when the column is available.
    $preference = "0"
    if (Test-ColumnExists $conn 'dbo.tEmployee' 'ResignDate') {
        $preference = "CASE WHEN e.ResignDate IS NULL THEN 0 ELSE 1 END"
    }
    $siteFilter = 'e.Site_ID IN (SELECT Site_ID FROM #Sites)'
    if ($allSites) { $siteFilter = "($siteFilter OR e.Site_ID IS NULL)" }

    $comboSql = @"
;WITH scoped AS (
    SELECT e.EmployeeCode,
           ISNULL(CONVERT(varchar(36), pj.SSOACC_ID), ISNULL(CONVERT(varchar(36), e.PRJ_ID), '-')) AS CompanyKey,
           ISNULL(CONVERT(varchar(36), e.Site_ID), '-')  AS SiteKey,
           ISNULL(CONVERT(varchar(36), e.$roleCol), '-') AS RoleKey,
           $preference AS Pref
    FROM dbo.tEmployee e
    LEFT JOIN dbo.tProject pj ON pj.PRJ_ID = e.PRJ_ID
    WHERE $siteFilter
), ranked AS (
    SELECT EmployeeCode,
           ROW_NUMBER() OVER (PARTITION BY CompanyKey, SiteKey, RoleKey ORDER BY Pref, EmployeeCode) AS rn
    FROM scoped
)
INSERT #Emps (EmployeeCode)
SELECT TOP (@cap) EmployeeCode
FROM ranked
WHERE rn <= @k
ORDER BY rn, EmployeeCode;
"@
    # ORDER BY rn first means round 1 (one employee per combination) is taken
    # before any second pick, so the cap costs depth, never coverage.
    Invoke-NonQuery $conn $comboSql @{ '@cap' = $MaxEmployees; '@k' = $EmployeesPerGroup } | Out-Null
    $afterCombo = [int](Invoke-Scalar $conn 'SELECT COUNT(*) FROM #Emps')

    # Backfill: make sure every distinct value of each employee dimension is
    # represented by at least one exported employee.
    $dimensions = @('EMPTT_ID','EmpLevel_ID','EMPTP1_ID','EMPTP2_ID','EMPTP3_ID','EMPST_ID','PRJ_ID','BU1_ID','Site_ID','FIX_SHF_ID','FIX_WCD_ID')
    $backfilled = 0
    if (-not $NoDimensionBackfill) {
        foreach ($dim in $dimensions) {
            if (-not (Test-ColumnExists $conn 'dbo.tEmployee' $dim)) { continue }
            $d = '[' + $dim + ']'
            $n = Invoke-NonQuery $conn @"
INSERT #Emps (EmployeeCode)
SELECT MIN(e.EmployeeCode)
FROM dbo.tEmployee e
WHERE e.$d IS NOT NULL
  AND NOT EXISTS (
        SELECT 1 FROM dbo.tEmployee m
        JOIN #Emps s ON s.EmployeeCode = m.EmployeeCode
        WHERE m.$d = e.$d)
GROUP BY e.$d;
"@
            if ($n -gt 0) { $backfilled += $n }
        }
    }

    # Employees transferred into the selected sites.
    if ($MaxTransferEmployees -gt 0 -and
        (Test-ObjectExists $conn 'customize.tSCC_TranferEmp') -and
        (Test-ObjectExists $conn 'customize.tSCC_TranferSite')) {
        Invoke-NonQuery $conn @"
INSERT #Emps (EmployeeCode)
SELECT DISTINCT TOP (@cap) te.EmployeeCode
FROM customize.tSCC_TranferEmp te
JOIN customize.tSCC_TranferSite ts ON ts.RequestID = te.RequestID
WHERE ts.Tranfer_SiteID IN (SELECT Site_ID FROM #Sites)
  AND te.EmployeeCode IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM #Emps m WHERE m.EmployeeCode = te.EmployeeCode)
  AND EXISTS (SELECT 1 FROM dbo.tEmployee e WHERE e.EmployeeCode = te.EmployeeCode);
"@ @{ '@cap' = $MaxTransferEmployees } | Out-Null
    }

    $empCount = [int](Invoke-Scalar $conn 'SELECT COUNT(*) FROM #Emps')
    Write-Step "Employees: $empCount  (combinations $afterCombo + backfill $backfilled + transfers)"

    # -----------------------------------------------------------------------
    # Coverage report
    # -----------------------------------------------------------------------
    $coverage = @()
    $comboCoverSql = @"
SELECT
  (SELECT COUNT(*) FROM (
      SELECT DISTINCT ISNULL(CONVERT(varchar(36), pj.SSOACC_ID), ISNULL(CONVERT(varchar(36), e.PRJ_ID),'-')) AS CompanyKey,
                      ISNULL(CONVERT(varchar(36), e.Site_ID),'-')  AS SiteKey,
                      ISNULL(CONVERT(varchar(36), e.$roleCol),'-') AS RoleKey
      FROM dbo.tEmployee e LEFT JOIN dbo.tProject pj ON pj.PRJ_ID = e.PRJ_ID) x) AS TotalCombos,
  (SELECT COUNT(*) FROM (
      SELECT DISTINCT ISNULL(CONVERT(varchar(36), pj.SSOACC_ID), ISNULL(CONVERT(varchar(36), e.PRJ_ID),'-')) AS CompanyKey,
                      ISNULL(CONVERT(varchar(36), e.Site_ID),'-')  AS SiteKey,
                      ISNULL(CONVERT(varchar(36), e.$roleCol),'-') AS RoleKey
      FROM dbo.tEmployee e
      JOIN #Emps s ON s.EmployeeCode = e.EmployeeCode
      LEFT JOIN dbo.tProject pj ON pj.PRJ_ID = e.PRJ_ID) x) AS CoveredCombos
"@
    $comboCover = (Invoke-Rows $conn $comboCoverSql)[0]
    $coverage += [pscustomobject]@{ Dimension = "company x site x $RoleColumn"; Total = [int]$comboCover.TotalCombos; Covered = [int]$comboCover.CoveredCombos }

    foreach ($dim in $dimensions) {
        if (-not (Test-ColumnExists $conn 'dbo.tEmployee' $dim)) { continue }
        $d = '[' + $dim + ']'
        $row = (Invoke-Rows $conn @"
SELECT
  (SELECT COUNT(DISTINCT e.$d) FROM dbo.tEmployee e) AS Total,
  (SELECT COUNT(DISTINCT e.$d) FROM dbo.tEmployee e JOIN #Emps s ON s.EmployeeCode = e.EmployeeCode) AS Covered
"@)[0]
        $coverage += [pscustomobject]@{ Dimension = $dim; Total = [int]$row.Total; Covered = [int]$row.Covered }
    }

    Write-Host ''
    Write-Host '  Coverage of the exported employee set:' -ForegroundColor Cyan
    foreach ($c in $coverage) {
        $mark = 'ok'
        if ($c.Covered -lt $c.Total) { $mark = 'partial' }
        Write-Host ("    {0,-28} {1,6} / {2,-6} {3}" -f $c.Dimension, $c.Covered, $c.Total, $mark)
    }

    # -----------------------------------------------------------------------
    # Date window
    # -----------------------------------------------------------------------
    if (-not $DateTo) {
        $maxDate = Invoke-Scalar $conn 'SELECT MAX(DateStamp) FROM dbo.tTimeInOut WHERE EmployeeCode IN (SELECT EmployeeCode FROM #Emps)'
        if ($maxDate -and $maxDate -isnot [System.DBNull]) { $DateTo = [string]$maxDate }
        else { $DateTo = (Get-Date).ToString('yyyyMMdd') }
    }
    if (-not $DateFrom) {
        $toDate   = [datetime]::ParseExact($DateTo, 'yyyyMMdd', $script:Inv)
        $DateFrom = $toDate.AddMonths(-$Months).ToString('yyyyMMdd')
    }
    Write-Host ''
    Write-Step "Dates    : $DateFrom .. $DateTo"

    # -----------------------------------------------------------------------
    # Build the table list
    # -----------------------------------------------------------------------
    $resolved = @()
    $skipped  = @()
    $seen     = @{}

    function Add-Spec {
        param([string]$FullName, [string]$Where, [string]$Note)
        if ($seen.ContainsKey($FullName.ToLowerInvariant())) { return }
        if (-not (Test-ObjectExists $conn $FullName)) {
            $script:skippedList += "$FullName (not present in this database)"
            return
        }
        $seen[$FullName.ToLowerInvariant()] = $true
        $parts = $FullName.Split('.')
        $w = $Where.Replace('{DATEFROM}', $DateFrom).Replace('{DATETO}', $DateTo)
        $script:resolvedList += [pscustomobject]@{
            Schema = $parts[0]
            Table  = $parts[1]
            Where  = $w
            Note   = $Note
        }
    }
    $script:resolvedList = @()
    $script:skippedList  = @()

    foreach ($m in $MasterTables) { Add-Spec $m '' 'master (full)' }
    Add-Spec 'dbo.tEmployee' 'EmployeeCode IN (SELECT EmployeeCode FROM #Emps)' 'employees (stratified)'
    foreach ($s in $SiteScopedTables) { Add-Spec $s.Table $s.Where 'site-scoped' }
    foreach ($e in $ExtraEmployeeTables) { Add-Spec $e.Table $e.Where 'employee-scoped' }

    if ($IncludeRelatedTables) {
        $related = Invoke-Rows $conn @'
SELECT SCHEMA_NAME(t.schema_id) AS sch, t.name AS tbl
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'EmployeeCode'
WHERE t.is_ms_shipped = 0
ORDER BY SCHEMA_NAME(t.schema_id), t.name
'@
        foreach ($r in $related) {
            $full = "$($r.sch).$($r.tbl)"
            if ($r.tbl -match $ExcludeTablePattern) {
                $script:skippedList += "$full (excluded: scratch/temp table)"
                continue
            }
            $where = $EmployeeScopedOverrides[$full]
            if (-not $where) { $where = 'EmployeeCode IN (SELECT EmployeeCode FROM #Emps)' }
            Add-Spec $full $where 'employee-related'
        }
    }

    $resolved = $script:resolvedList
    $skipped  = $script:skippedList
    Write-Step "Tables   : $($resolved.Count) to export, $($skipped.Count) skipped"
    Write-Host ''

    # -----------------------------------------------------------------------
    # Dry run
    # -----------------------------------------------------------------------
    if ($DryRun) {
        Write-Host 'DRY RUN - row counts only, nothing is written.' -ForegroundColor Yellow
        Write-Host ''
        $report = @()
        $total  = [int64]0
        foreach ($t in $resolved) {
            $sql = "SELECT COUNT_BIG(*) FROM [$($t.Schema)].[$($t.Table)]"
            if ($t.Where) { $sql += " WHERE $($t.Where)" }
            $n = [int64](Invoke-Scalar $conn $sql)
            if ($MaxRowsPerTable -gt 0 -and $n -gt $MaxRowsPerTable) { $total += $MaxRowsPerTable } else { $total += $n }
            $capped = ''
            if ($MaxRowsPerTable -gt 0 -and $n -gt $MaxRowsPerTable) { $capped = "-> capped to $MaxRowsPerTable" }
            if ($n -gt 0) {
                $report += [pscustomobject]@{ Table = "$($t.Schema).$($t.Table)"; Rows = $n; Note = ("$($t.Note) $capped").Trim() }
            }
        }
        $report | Sort-Object -Property Rows -Descending | Format-Table -AutoSize
        Write-Host ("Tables with data: {0} of {1}" -f $report.Count, $resolved.Count)
        Write-Host ("Estimated exported rows: {0}" -f $total)
        Write-Host ''
        Write-Host 'Re-run without -DryRun to produce the export.' -ForegroundColor Cyan
        return
    }

    # -----------------------------------------------------------------------
    # Output folder
    # -----------------------------------------------------------------------
    if (-not $OutRoot) { $OutRoot = Join-Path $PSScriptRoot 'out' }
    if (-not $SnapshotName) { $SnapshotName = (Get-Date).ToString('yyyyMMdd') }
    $outDir = Join-Path $OutRoot $SnapshotName
    $suffix = 1
    while (Test-Path $outDir) {
        $outDir = Join-Path $OutRoot ($SnapshotName + '_' + $suffix)
        $suffix++
    }
    [void](New-Item -ItemType Directory -Path $outDir -Force)
    $snapshotFolder = Split-Path $outDir -Leaf
    Write-Step "Output   : $outDir"
    Write-Host ''

    # -----------------------------------------------------------------------
    # Export
    # -----------------------------------------------------------------------
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $results   = @()
    $index     = 10

    foreach ($t in $resolved) {
        $label = "$($t.Schema).$($t.Table)"
        $cols  = @(Get-TableColumns $conn $t.Schema $t.Table ([bool]$IncludeBinary))
        if ($cols.Count -eq 0) {
            $skipped += "$label (no exportable columns)"
            continue
        }

        $colNames   = @($cols | ForEach-Object { '[' + $_.Name + ']' })
        $selectCols = $colNames -join ', '
        $insertCols = Join-Wrapped $colNames
        $topClause  = ''
        if ($MaxRowsPerTable -gt 0) { $topClause = "TOP ($MaxRowsPerTable) " }
        $sql = "SELECT $topClause$selectCols FROM [$($t.Schema)].[$($t.Table)]"
        if ($t.Where) { $sql += " WHERE $($t.Where)" }

        $hasIdentity = (@($cols | Where-Object { $_.IsIdentity })).Count -gt 0
        $fileName    = ('{0:D3}_{1}.{2}.sql' -f $index, $t.Schema, $t.Table)
        $filePath    = Join-Path $outDir $fileName

        $cmd = $conn.CreateCommand()
        $cmd.CommandText    = $sql
        $cmd.CommandTimeout = 0
        $reader = $cmd.ExecuteReader()

        $writer = New-Object System.IO.StreamWriter($filePath, $false, $utf8NoBom)
        $writer.WriteLine("USE [$Database]")
        $writer.WriteLine('GO')
        $writer.WriteLine()
        if ($hasIdentity) {
            $writer.WriteLine("SET IDENTITY_INSERT [$($t.Schema)].[$($t.Table)] ON")
            $writer.WriteLine()
        }

        $rows = 0
        $insertHeader = "INSERT [$($t.Schema)].[$($t.Table)] (`n$insertCols`n)`nVALUES ("
        while ($reader.Read()) {
            $values = New-Object System.Collections.Generic.List[string]
            for ($i = 0; $i -lt $cols.Count; $i++) {
                $raw = $reader.GetValue($i)
                $raw = Get-MaskedValue $raw $cols[$i].Name $Mask
                $values.Add((Format-SqlLiteral $raw $cols[$i].Type))
            }
            $writer.WriteLine($insertHeader + "`n" + (Join-Wrapped $values.ToArray()) + "`n)")
            $rows++
            if ($rows % 500 -eq 0) {
                $writer.WriteLine('GO')
                if ($hasIdentity) { $writer.WriteLine("SET IDENTITY_INSERT [$($t.Schema)].[$($t.Table)] ON") }
            }
        }
        $reader.Close()
        $cmd.Dispose()

        if ($hasIdentity) {
            $writer.WriteLine()
            $writer.WriteLine("SET IDENTITY_INSERT [$($t.Schema)].[$($t.Table)] OFF")
        }
        $writer.WriteLine('GO')
        $writer.Flush()
        $writer.Close()

        $capped  = ($MaxRowsPerTable -gt 0 -and $rows -eq $MaxRowsPerTable)
        $fileRef = $fileName
        if ($rows -eq 0) {
            Remove-Item $filePath -Force
            $fileRef = $null
        } else {
            $flag = ''
            if ($capped) { $flag = '  ** capped **' }
            Write-Host ("  {0,-46} {1,8}{2}" -f $label, $rows, $flag)
            $index++
        }

        $results += [pscustomobject]@{
            File   = $fileRef
            Schema = $t.Schema
            Table  = $t.Table
            Rows   = $rows
            Capped = $capped
            Note   = $t.Note
        }
    }

    $exported = @($results | Where-Object { $_.Rows -gt 0 })

    # -----------------------------------------------------------------------
    # 000_disable_constraints.sql / 999_enable_constraints.sql
    # Only tables we actually exported are cleared, so an empty result never
    # wipes data that the base seed already loaded.
    # -----------------------------------------------------------------------
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("USE [$Database]")
    [void]$sb.AppendLine('GO')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("PRINT 'Disabling all foreign key constraints...';")
    [void]$sb.AppendLine("EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';")
    [void]$sb.AppendLine('GO')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("PRINT 'Clearing existing data from target tables...';")
    for ($i = $exported.Count - 1; $i -ge 0; $i--) {
        [void]$sb.AppendLine("DELETE FROM [$($exported[$i].Schema)].[$($exported[$i].Table)];")
    }
    [void]$sb.AppendLine('GO')
    [System.IO.File]::WriteAllText((Join-Path $outDir '000_disable_constraints.sql'), $sb.ToString(), $utf8NoBom)

    $enable = @"
USE [$Database]
GO

PRINT 'Enabling all foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH NOCHECK CHECK CONSTRAINT ALL';
GO
"@
    [System.IO.File]::WriteAllText((Join-Path $outDir '999_enable_constraints.sql'), $enable, $utf8NoBom)

    # -----------------------------------------------------------------------
    # Manifest
    # -----------------------------------------------------------------------
    $manifest = [pscustomobject]@{
        snapshot            = $snapshotFolder
        exportedAtUtc       = (Get-Date).ToUniversalTime().ToString('s') + 'Z'
        sourceServer        = $Server
        sourceDatabase      = $Database
        mask                = $Mask
        includeBinary       = [bool]$IncludeBinary
        maxRowsPerTable     = $MaxRowsPerTable
        siteCount           = $siteCount
        allSites            = $allSites
        employeeCount       = $empCount
        employeesPerGroup   = $EmployeesPerGroup
        roleColumn          = $RoleColumn
        dateFrom            = $DateFrom
        dateTo              = $DateTo
        tableCount          = $exported.Count
        totalRows           = ($results | Measure-Object -Property Rows -Sum).Sum
        coverage            = $coverage
        tables              = $results
        skipped             = $skipped
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $outDir '_manifest.json') -Encoding UTF8

    $coverageLines = ($coverage | ForEach-Object { "| ``$($_.Dimension)`` | $($_.Covered) / $($_.Total) |" }) -join "`n"
    $readme = @"
# MAS seed snapshot ``$snapshotFolder``

| | |
|---|---|
| Exported (UTC) | $($manifest.exportedAtUtc) |
| Source | $Server / $Database |
| Sites | $siteCount |
| Employees | $empCount ($EmployeesPerGroup per company x site x $RoleColumn) |
| Date window | $DateFrom .. $DateTo |
| PII masking | $Mask |
| Tables with data | $($exported.Count) |
| Total rows | $($manifest.totalRows) |

## Coverage

| Dimension | Covered / Total |
|---|---|
$coverageLines

Load it into the local Docker database from the repo root:

``````bash
./scripts/load-seed-export.sh <path-to-this-folder-or-zip>
./scripts/check-site-data.sh
``````

Files import in file-name order: ``000_disable_constraints.sql`` clears only the
tables present in this snapshot, each ``NNN_schema.table.sql`` inserts, then
``999_enable_constraints.sql`` re-enables foreign keys.
"@
    Set-Content -Path (Join-Path $outDir '_README.md') -Value $readme -Encoding UTF8

    Write-Host ''
    Write-Host "Tables with data: $($exported.Count)   Total rows: $($manifest.totalRows)" -ForegroundColor Green

    if (-not $NoZip) {
        $zipPath = Join-Path $OutRoot ("mashr-seed-$snapshotFolder.zip")
        if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
        if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
            Compress-Archive -Path $outDir -DestinationPath $zipPath
            Write-Host ''
            Write-Host "ZIP: $zipPath" -ForegroundColor Green
        } else {
            Write-Host 'Compress-Archive not available (PowerShell < 5). Zip the folder manually.' -ForegroundColor Yellow
        }
    }

    Write-Host ''
    Write-Host 'Next: copy the zip to the analysis machine, then run:' -ForegroundColor Cyan
    Write-Host '  ./scripts/load-seed-export.sh <zip>' -ForegroundColor Cyan
    Write-Host '  ./scripts/check-site-data.sh' -ForegroundColor Cyan
}
finally {
    $conn.Close()
    $conn.Dispose()
}
