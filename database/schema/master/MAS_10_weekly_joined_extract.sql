/* =========================================================
   STAFFO — MAS-HR WEEKLY JOINED EXTRACT (Attendance + Leave + OT)
   Period: Monday 2026-09-14 → Wednesday 2026-09-16

   READ ONLY — no UPDATE / INSERT / DELETE

   ---------------------------------------------------------
   WHY THE PREVIOUS "TOP 100 JOIN ON EmployeeID" FAILED
   ---------------------------------------------------------
   1. ไม่มีตารางไหนใน MAS มีคอลัมน์ชื่อ EmployeeID
      key ของแต่ละตารางชื่อไม่เหมือนกัน:
        tTimeInOut / tTimeInOut_AddLeave / tLogAddLeaveManagement
                              → EmployeeCode + DateStamp (yyyyMMdd, varchar/char 8)
        tTimeStamp (raw scan) → CardID (= EmployeeCode) + DateStamp
                                (คอลัมน์ EmployeeCode ในตารางนี้ส่วนใหญ่ NULL)
        tRequest              → EmpRequestID (= EmployeeCode)
                                วันที่ของรายการอยู่ที่ VC04/VC05 (yyyyMMdd)
                                StartDate = เวลาที่ยื่นคำขอ ไม่ใช่วันลา/วัน OT
        tLOG_OTApprove        → EmployeeCode + DateStamp
        tLog_OTClaim          → Employeecode + Datestamp (varchar 50, ค่า yyyyMMdd)
   2. TOP 100 จากแต่ละตารางโดยไม่ filter ช่วงวันเดียวกัน
      → ได้คนละชุดพนักงาน/คนละปี (tTimeStamp ไม่มี ORDER BY ได้ปี 2023)
      → join แล้วว่างเป็นเรื่องปกติ
   3. Spine ที่ถูกต้องคือ dbo.tTimeInOut (1 แถว/คน/วัน, 3.5M rows)
      ไม่ใช่ tTimeInOut_AddLeave (726K rows = subset)
      และ OT จริง (nOT1, nOT1_5, nOT2, nOT3, CAL_nOT*, OTApproveStatus)
      อยู่ใน tTimeInOut ไม่ใช่ tShiftOT (tShiftOT = 0 rows, config เท่านั้น)

   ---------------------------------------------------------
   OT AUTHORITY (จาก row counts export-20260713)
   ---------------------------------------------------------
     tTimeInOut.nOT*/CAL_nOT*/OTApproveStatus  = ค่า OT รายวันที่ใช้คิดเงิน
     tLOG_OTApprove   (1,235,090 rows)          = log การอนุมัติ OT รายวัน
                                                  FieldName OT1/OT1_5/OT2/OT3,
                                                  PreviousValue → NewValue (ชั่วโมง)
     tRequest SystemType='OT_SYSTEM'            = ใบขอ OT (workflow)
                                                  VC04=วัน OT, D01/D02=เริ่ม H/M,
                                                  D03/D04=จบ H/M, D05=ชั่วโมงขอ
     tLog_OTClaim     (5,949 rows)              = OT ที่ขอ (Req_*) เทียบ OT ที่คำนวณ (CAL_*)
                                                  ผูก tRequest ด้วย RequestNo / code(=RequestID)
     tAssignOT, tOTx, tOTRequest_Form, tShiftOT = 0 rows → ไม่ใช้
   ========================================================= */

SET NOCOUNT ON;

DECLARE @FromDate date = '2026-09-14';
DECLARE @ToDate   date = '2026-09-16';

DECLARE @FromDateKey varchar(8) = CONVERT(varchar(8), @FromDate, 112); -- 20260914
DECLARE @ToDateKey   varchar(8) = CONVERT(varchar(8), @ToDate, 112);   -- 20260916


/* =========================================================
   0. DAILY SPINE (temp) — 1 row / EmployeeCode / DateStamp
   ใช้ซ้ำทุก result set ข้างล่าง
   ========================================================= */
IF OBJECT_ID('tempdb..#Spine') IS NOT NULL DROP TABLE #Spine;

SELECT
    RTRIM(tio.EmployeeCode) AS EmployeeCode,
    RTRIM(tio.DateStamp)    AS DateStamp
INTO #Spine
FROM dbo.tTimeInOut tio
WHERE tio.DateStamp >= @FromDateKey
  AND tio.DateStamp <= @ToDateKey;

CREATE CLUSTERED INDEX IX_Spine ON #Spine (EmployeeCode, DateStamp);


/* =========================================================
   1. DAILY FACT — Attendance + Leave + OT รวมในแถวเดียว
      spine = tTimeInOut
      + tTimeInOut_AddLeave  (leave allocation)
      + tTimeStamp           (raw scan aggregate)
      + tLOG_OTApprove       (OT approval aggregate)
      + tLog_OTClaim         (OT claim aggregate)
      + tRequest OT_SYSTEM   (OT request aggregate)
      + tRequest LEAVE_SYSTEM(leave request aggregate, วันอยู่ในช่วง VC04..VC05)
      + tEmployee            (name / site / BU)
   ========================================================= */
SELECT
    s.EmployeeCode,
    s.DateStamp,

    -- employee master
    e.FirstName,
    e.LastName,
    e.EmployeeFlag,
    e.Site_ID,
    e.BU1_ID,
    e.FIX_SHF_ID,

    -- attendance (tTimeInOut)
    tio.SHF_ID,
    tio.JobType,
    tio.FlagWork,
    tio.FlagLocked,
    tio.TIOStatus,
    tio.InTime_Hour,  tio.InTime_Minute,
    tio.OutTime_Hour, tio.OutTime_Minute,
    tio.InTime2_Hour, tio.InTime2_Minute,
    tio.OutTime2_Hour, tio.OutTime2_Minute,
    tio.nWorkUnit,
    tio.Cal_ShiftWorkUnit,
    tio.nLateIn, tio.nLateOut,
    tio.nHoliday,
    tio.nShift,
    tio.IsEdited,
    tio.Note,

    -- OT (tTimeInOut = ค่าที่ใช้คิดเงิน)
    tio.InTimeOT_Hour,  tio.InTimeOT_Minute,
    tio.OutTimeOT_Hour, tio.OutTimeOT_Minute,
    tio.nOT1,  tio.nOT1_5,  tio.nOT2,  tio.nOT3,
    tio.CAL_nOT1, tio.CAL_nOT1_5, tio.CAL_nOT2, tio.CAL_nOT3, tio.CAL_nOT4,
    tio.naOT1, tio.naOT1_5, tio.naOT2, tio.naOT3,
    tio.OTApproveStatus,
    tio.FlagApp,
    tio.FlagEdit,

    -- leave (tTimeInOut)
    tio.nSickLeave, tio.nPersonalLeave, tio.nVacation,
    tio.L01, tio.L02, tio.L03, tio.L04,
    tio.nCompensateLeave,
    tio.IsPaySickLeave, tio.IsPayPersonalLeave, tio.IsPayVacation,
    tio.IsPayL01, tio.IsPayL02, tio.IsPayL03, tio.IsPayL04,
    tio.nSickLeave_StartTime, tio.nSickLeave_EndTime,
    tio.nPersonalLeave_StartTime, tio.nPersonalLeave_EndTime,
    tio.nVacation_StartTime, tio.nVacation_EndTime,
    tio.tSickLeaveReason, tio.tPersonalLeaveReason, tio.tVacationReason,
    tio.SickLeaveMedCert,
    tio.FlagLeave,

    -- leave allocation (tTimeInOut_AddLeave)
    al.nWorkUnit           AS AL_nWorkUnit,
    al.Cal_ShiftWorkUnit   AS AL_Cal_ShiftWorkUnit,
    al.FlagWork            AS AL_FlagWork,
    al.FlagCountSH         AS AL_FlagCountSH,
    al.nSickLeave          AS AL_nSickLeave,
    al.nSickLeave_Mins     AS AL_nSickLeave_Mins,
    al.nPersonalLeave      AS AL_nPersonalLeave,
    al.nPersonalLeave_Mins AS AL_nPersonalLeave_Mins,
    al.nVacation           AS AL_nVacation,
    al.nVacation_Mins      AS AL_nVacation_Mins,
    al.L01 AS AL_L01, al.L01_Mins AS AL_L01_Mins,
    al.L02 AS AL_L02, al.L02_Mins AS AL_L02_Mins,
    al.L03 AS AL_L03, al.L03_Mins AS AL_L03_Mins,
    al.L04 AS AL_L04, al.L04_Mins AS AL_L04_Mins,
    al.nCompensateLeave    AS AL_nCompensateLeave,
    al.nMaternityLeave     AS AL_nMaternityLeave,
    al.nParentalLeaveMom   AS AL_nParentalLeaveMom,
    al.nParentalLeaveDad   AS AL_nParentalLeaveDad,
    al.MinLeaveStartTime   AS AL_MinLeaveStartTime,
    al.MaxLeaveEndTime     AS AL_MaxLeaveEndTime,
    al.FlagLeave           AS AL_FlagLeave,

    -- raw scan aggregate (tTimeStamp, CardID = EmployeeCode)
    sc.ScanCount,
    sc.FirstScan_HHMM,
    sc.LastScan_HHMM,
    sc.MachineList,

    -- OT approval log aggregate (tLOG_OTApprove)
    oa.OTApproveEvents,
    oa.OTApprove_OT1,
    oa.OTApprove_OT1_5,
    oa.OTApprove_OT2,
    oa.OTApprove_OT3,
    oa.OTApprove_LastAt,

    -- OT claim aggregate (tLog_OTClaim)
    oc.OTClaimCount,
    oc.OTClaim_ReqHr,
    oc.OTClaim_Req_nOT1,
    oc.OTClaim_Req_nOT1_5,
    oc.OTClaim_Req_nOT2,
    oc.OTClaim_Req_nOT3,
    oc.OTClaim_CAL_nOT1_5,
    oc.OTClaim_CAL_nOT2,
    oc.OTClaim_RequestNos,

    -- OT request aggregate (tRequest OT_SYSTEM)
    otr.OTReqCount,
    otr.OTReq_Approved,
    otr.OTReq_Pending,
    otr.OTReq_Hours,
    otr.OTReq_RequestNos,

    -- leave request aggregate (tRequest LEAVE_SYSTEM ครอบวันนี้)
    lvr.LeaveReqCount,
    lvr.LeaveReq_Approved,
    lvr.LeaveReq_Pending,
    lvr.LeaveReq_RequestNos,
    lvr.LeaveReq_TypeIDs

FROM #Spine s
JOIN dbo.tTimeInOut tio
    ON  tio.EmployeeCode = s.EmployeeCode
    AND tio.DateStamp    = s.DateStamp
LEFT JOIN dbo.tEmployee e
    ON  e.EmployeeCode = s.EmployeeCode
LEFT JOIN dbo.tTimeInOut_AddLeave al
    ON  al.EmployeeCode = s.EmployeeCode
    AND al.DateStamp    = s.DateStamp

/* raw scans → 1 row/คน/วัน */
LEFT JOIN (
    SELECT
        RTRIM(ts.CardID)    AS EmployeeCode,
        RTRIM(ts.DateStamp) AS DateStamp,
        COUNT(*)            AS ScanCount,
        MIN(RIGHT('0' + CAST(ts.nHour AS varchar(2)), 2) + ':' + RIGHT('0' + CAST(ts.nMinute AS varchar(2)), 2)) AS FirstScan_HHMM,
        MAX(RIGHT('0' + CAST(ts.nHour AS varchar(2)), 2) + ':' + RIGHT('0' + CAST(ts.nMinute AS varchar(2)), 2)) AS LastScan_HHMM,
        STRING_AGG(CAST(ts.Machine_ID AS varchar(255)), ',') AS MachineList
    FROM dbo.tTimeStamp ts
    WHERE ts.DateStamp >= @FromDateKey
      AND ts.DateStamp <= @ToDateKey
    GROUP BY RTRIM(ts.CardID), RTRIM(ts.DateStamp)
) sc
    ON  sc.EmployeeCode = s.EmployeeCode
    AND sc.DateStamp    = s.DateStamp

/* OT approval log → 1 row/คน/วัน (NewValue = ชั่วโมงที่อนุมัติ, เอาค่าล่าสุดต่อ FieldName) */
LEFT JOIN (
    SELECT
        EmployeeCode,
        DateStamp,
        COUNT(*) AS OTApproveEvents,
        MAX(CASE WHEN FieldName = 'OT1'   AND rn = 1 THEN NewValue END) AS OTApprove_OT1,
        MAX(CASE WHEN FieldName = 'OT1_5' AND rn = 1 THEN NewValue END) AS OTApprove_OT1_5,
        MAX(CASE WHEN FieldName = 'OT2'   AND rn = 1 THEN NewValue END) AS OTApprove_OT2,
        MAX(CASE WHEN FieldName = 'OT3'   AND rn = 1 THEN NewValue END) AS OTApprove_OT3,
        MAX(CreateDateTime) AS OTApprove_LastAt
    FROM (
        SELECT
            RTRIM(la.EmployeeCode) AS EmployeeCode,
            RTRIM(la.DateStamp)    AS DateStamp,
            la.FieldName,
            la.NewValue,
            la.CreateDateTime,
            ROW_NUMBER() OVER (PARTITION BY RTRIM(la.EmployeeCode), RTRIM(la.DateStamp), la.FieldName
                               ORDER BY la.CreateDateTime DESC) AS rn
        FROM dbo.tLOG_OTApprove la
        WHERE la.DateStamp >= @FromDateKey
          AND la.DateStamp <= @ToDateKey
    ) x
    GROUP BY EmployeeCode, DateStamp
) oa
    ON  oa.EmployeeCode = s.EmployeeCode
    AND oa.DateStamp    = s.DateStamp

/* OT claim → 1 row/คน/วัน */
LEFT JOIN (
    SELECT
        RTRIM(c.Employeecode) AS EmployeeCode,
        RTRIM(c.Datestamp)    AS DateStamp,
        COUNT(*)              AS OTClaimCount,
        SUM(c.ReqHr)          AS OTClaim_ReqHr,
        SUM(c.Req_nOT1)       AS OTClaim_Req_nOT1,
        SUM(c.Req_nOT1_5)     AS OTClaim_Req_nOT1_5,
        SUM(c.Req_nOT2)       AS OTClaim_Req_nOT2,
        SUM(c.Req_nOT3)       AS OTClaim_Req_nOT3,
        SUM(c.CAL_nOT1_5)     AS OTClaim_CAL_nOT1_5,
        SUM(c.CAL_nOT2)       AS OTClaim_CAL_nOT2,
        STRING_AGG(c.RequestNo, ',') AS OTClaim_RequestNos
    FROM dbo.tLog_OTClaim c
    WHERE c.Datestamp >= @FromDateKey
      AND c.Datestamp <= @ToDateKey
    GROUP BY RTRIM(c.Employeecode), RTRIM(c.Datestamp)
) oc
    ON  oc.EmployeeCode = s.EmployeeCode
    AND oc.DateStamp    = s.DateStamp

/* OT request (workflow) → 1 row/คน/วัน  วัน OT = VC04 */
LEFT JOIN (
    SELECT
        RTRIM(r.EmpRequestID) AS EmployeeCode,
        RTRIM(r.VC04)         AS DateStamp,
        COUNT(*)              AS OTReqCount,
        SUM(CASE WHEN r.ReqStatus = 1 THEN 1 ELSE 0 END) AS OTReq_Approved,
        SUM(CASE WHEN r.ReqStatus = 0 THEN 1 ELSE 0 END) AS OTReq_Pending,
        SUM(r.D05)            AS OTReq_Hours,
        STRING_AGG(r.RequestNo, ',') AS OTReq_RequestNos
    FROM dbo.tRequest r
    WHERE r.SystemType = 'OT_SYSTEM'
      AND r.VC04 >= @FromDateKey
      AND r.VC04 <= @ToDateKey
    GROUP BY RTRIM(r.EmpRequestID), RTRIM(r.VC04)
) otr
    ON  otr.EmployeeCode = s.EmployeeCode
    AND otr.DateStamp    = s.DateStamp

/* leave request (workflow) → 1 row/คน/วัน  ใบลาครอบวัน = VC04 <= day <= VC05 */
LEFT JOIN (
    SELECT
        sp.EmployeeCode,
        sp.DateStamp,
        COUNT(*) AS LeaveReqCount,
        SUM(CASE WHEN r.ReqStatus = 1 THEN 1 ELSE 0 END) AS LeaveReq_Approved,
        SUM(CASE WHEN r.ReqStatus = 0 THEN 1 ELSE 0 END) AS LeaveReq_Pending,
        STRING_AGG(r.RequestNo, ',') AS LeaveReq_RequestNos,
        STRING_AGG(CAST(r.RequestTypeID AS varchar(36)), ',') AS LeaveReq_TypeIDs
    FROM #Spine sp
    JOIN dbo.tRequest r
        ON  RTRIM(r.EmpRequestID) = sp.EmployeeCode
        AND r.SystemType = 'LEAVE_SYSTEM'
        AND r.VC04 <= sp.DateStamp
        AND r.VC05 >= sp.DateStamp
    GROUP BY sp.EmployeeCode, sp.DateStamp
) lvr
    ON  lvr.EmployeeCode = s.EmployeeCode
    AND lvr.DateStamp    = s.DateStamp

ORDER BY s.EmployeeCode, s.DateStamp;


/* =========================================================
   2. RAW SCAN DETAIL — ทุก punch ในช่วง พร้อม flag ว่ามีแถว daily รองรับไหม
      (สแกนที่ CardID ไม่ตรง EmployeeCode / ไม่มี tTimeInOut
       = กรณี ATT2000 offline หรือ card map ไม่เจอ)
   ========================================================= */
SELECT
    ts.CardID,
    RTRIM(ts.CardID)            AS EmployeeCode_FromCard,
    ts.EmployeeCode             AS EmployeeCode_Raw,      -- ส่วนใหญ่ NULL
    ts.Machine_ID,
    ts.DateInput,               -- วันที่สแกนจริง
    ts.DateStamp,               -- วันงานหลัง match กะ (ใช้ join)
    ts.nHour, ts.nMinute,
    ts.Duty,
    ts.JobType,
    ts.ShiftTime_Type,
    ts.CalculatedResult,
    ts.ScanNumber,
    ts.CreateDateTime,
    CASE WHEN e.EmployeeCode IS NULL THEN 0 ELSE 1 END AS HasEmployee,
    CASE WHEN s.EmployeeCode IS NULL THEN 0 ELSE 1 END AS HasDailyRow
FROM dbo.tTimeStamp ts
LEFT JOIN dbo.tEmployee e
    ON  e.EmployeeCode = RTRIM(ts.CardID)
LEFT JOIN #Spine s
    ON  s.EmployeeCode = RTRIM(ts.CardID)
    AND s.DateStamp    = RTRIM(ts.DateStamp)
WHERE ts.DateStamp >= @FromDateKey
  AND ts.DateStamp <= @ToDateKey
ORDER BY ts.CardID, ts.DateStamp, ts.nHour, ts.nMinute;


/* =========================================================
   3. LEAVE EVENT LOG + daily row ที่ log นั้นชี้ถึง
      (เก็บทุก Insert/Update/Delete ให้ importer ตัดสิน)
   ========================================================= */
SELECT
    lg.EmployeeCode,
    lg.DateStamp,
    lg.LeaveType,          -- 'nSickLeave' | 'nPersonalLeave' | 'nVacation' | 'L01'..
    lg.PayLeave,
    lg.EventLeave,         -- Insert / Update / Delete
    lg.Flagapp,            -- Application / Web
    lg.CreateDate,
    lg.ReqStatus,
    lg.Reason,
    lg.UserID,
    lg.PreviousValue,
    lg.EditType,
    CASE WHEN s.EmployeeCode IS NULL THEN 0 ELSE 1 END AS HasDailyRow,
    tio.nSickLeave      AS Daily_nSickLeave,
    tio.nPersonalLeave  AS Daily_nPersonalLeave,
    tio.nVacation       AS Daily_nVacation,
    tio.L01 AS Daily_L01, tio.L02 AS Daily_L02, tio.L03 AS Daily_L03, tio.L04 AS Daily_L04,
    tio.IsPaySickLeave, tio.IsPayPersonalLeave, tio.IsPayVacation
FROM dbo.tLogAddLeaveManagement lg
LEFT JOIN #Spine s
    ON  s.EmployeeCode = RTRIM(lg.EmployeeCode)
    AND s.DateStamp    = RTRIM(lg.DateStamp)
LEFT JOIN dbo.tTimeInOut tio
    ON  tio.EmployeeCode = s.EmployeeCode
    AND tio.DateStamp    = s.DateStamp
WHERE lg.DateStamp >= @FromDateKey
  AND lg.DateStamp <= @ToDateKey
ORDER BY lg.EmployeeCode, lg.DateStamp, lg.CreateDate;


/* =========================================================
   4. REQUEST WORKFLOW (LEAVE + OT) — filter ด้วยวันรายการ (VC04/VC05)
      หรือวันยื่น (StartDate) เพื่อไม่พลาด retro request
   ========================================================= */
SELECT
    r.RequestID,
    r.RequestNo,
    r.SystemType,          -- LEAVE_SYSTEM / OT_SYSTEM
    r.RequestTypeID,
    rt.Caption  AS RequestType_Caption,
    rt.Title    AS RequestType_Title,
    r.EmpRequestID AS EmployeeCode,
    r.ReqStatus,           -- 0 pending, 1 approved, 2 reject, 3 cancel
    r.CurrentLV,
    r.StartDate,           -- เวลายื่น
    r.CreateDateTime,
    r.VC01, r.VC02,        -- dd/MM/yyyy start / end
    r.VC04, r.VC05,        -- yyyyMMdd start / end  ← ใช้ join กับ DateStamp
    r.VC03  AS Reason,
    r.VC08  AS AttachFile,
    r.D01, r.D02, r.D03, r.D04, r.D05, r.D06,
    r.D11, r.D12, r.D13, r.D14, r.D15, r.D16,
    r.SHF_ID,
    r.Quota_LeaveYear,
    r.IsApproveClaim,
    r.DeductionType,
    r.StatusRetro, r.IsRetro1, r.IsRetro2, r.IsRetro3,
    r.Comment,
    r.FinishBy,
    r.ManRequestID,
    r.GroupNo,
    r.RuleID,
    CASE WHEN e.EmployeeCode IS NULL THEN 0 ELSE 1 END AS HasEmployee
FROM dbo.tRequest r
LEFT JOIN dbo.tRequestType rt
    ON  rt.RequestTypeID = r.RequestTypeID
LEFT JOIN dbo.tEmployee e
    ON  e.EmployeeCode = RTRIM(r.EmpRequestID)
WHERE r.SystemType IN ('LEAVE_SYSTEM', 'OT_SYSTEM')
  AND (
        (r.VC04 <= @ToDateKey AND r.VC05 >= @FromDateKey)          -- รายการครอบช่วง
     OR (r.StartDate >= @FromDate AND r.StartDate < DATEADD(day, 1, @ToDate))
      )
ORDER BY r.SystemType, r.EmpRequestID, r.VC04, r.RequestNo;


/* =========================================================
   5. OT APPROVAL LOG (raw) — join daily OT ที่ใช้คิดเงิน
   ========================================================= */
SELECT
    la.LOG_ID,
    la.EmployeeCode,
    la.DateStamp,
    la.FieldName,          -- OT1 / OT1_5 / OT2 / OT3
    la.PreviousValue,
    la.NewValue,
    la.NoteApporve,
    la.UID,
    la.CreateDateTime,
    tio.nOT1, tio.nOT1_5, tio.nOT2, tio.nOT3,
    tio.CAL_nOT1, tio.CAL_nOT1_5, tio.CAL_nOT2, tio.CAL_nOT3,
    tio.OTApproveStatus,
    tio.FlagLocked
FROM dbo.tLOG_OTApprove la
LEFT JOIN dbo.tTimeInOut tio
    ON  tio.EmployeeCode = RTRIM(la.EmployeeCode)
    AND tio.DateStamp    = RTRIM(la.DateStamp)
WHERE la.DateStamp >= @FromDateKey
  AND la.DateStamp <= @ToDateKey
ORDER BY la.EmployeeCode, la.DateStamp, la.CreateDateTime;


/* =========================================================
   6. OT CLAIM LOG (raw) — join tRequest ผ่าน RequestNo
   ========================================================= */
SELECT
    c.LogID,
    c.Employeecode,
    c.Datestamp,
    c.BeginDate,
    c.InTime, c.OutTime,
    c.ReqStart, c.ReqEnd,
    c.ReqHr,
    c.Req_nOT1, c.Req_nOT1_5, c.Req_nOT2, c.Req_nOT3,
    c.CAL_nOT1, c.CAL_nOT1_5, c.CAL_nOT2, c.CAL_nOT3,
    c.Diff,
    c.RequestDate,
    c.ReqStatus,
    c.RequestNo,
    c.code            AS RequestID_Ref,
    c.Comment,
    c.CreateDateTime,
    c.StatusRetro,
    r.RequestID       AS tRequest_RequestID,
    r.ReqStatus       AS tRequest_ReqStatus,
    r.VC04            AS tRequest_OTDate,
    r.D05             AS tRequest_ReqHours
FROM dbo.tLog_OTClaim c
LEFT JOIN dbo.tRequest r
    ON  r.RequestNo = c.RequestNo
WHERE c.Datestamp >= @FromDateKey
  AND c.Datestamp <= @ToDateKey
ORDER BY c.Employeecode, c.Datestamp, c.CreateDateTime;


/* =========================================================
   7. RECONCILIATION — row counts + unmatched
   ========================================================= */
SELECT 'tTimeInOut (spine)' AS source_table, COUNT(*) AS row_count
FROM #Spine

UNION ALL
SELECT 'tTimeInOut_AddLeave', COUNT(*)
FROM dbo.tTimeInOut_AddLeave
WHERE DateStamp >= @FromDateKey AND DateStamp <= @ToDateKey

UNION ALL
SELECT 'tTimeInOut_AddLeave without tTimeInOut', COUNT(*)
FROM dbo.tTimeInOut_AddLeave al
LEFT JOIN #Spine s ON s.EmployeeCode = RTRIM(al.EmployeeCode) AND s.DateStamp = RTRIM(al.DateStamp)
WHERE al.DateStamp >= @FromDateKey AND al.DateStamp <= @ToDateKey
  AND s.EmployeeCode IS NULL

UNION ALL
SELECT 'tTimeStamp punches', COUNT(*)
FROM dbo.tTimeStamp
WHERE DateStamp >= @FromDateKey AND DateStamp <= @ToDateKey

UNION ALL
SELECT 'tTimeStamp punches without tTimeInOut', COUNT(*)
FROM dbo.tTimeStamp ts
LEFT JOIN #Spine s ON s.EmployeeCode = RTRIM(ts.CardID) AND s.DateStamp = RTRIM(ts.DateStamp)
WHERE ts.DateStamp >= @FromDateKey AND ts.DateStamp <= @ToDateKey
  AND s.EmployeeCode IS NULL

UNION ALL
SELECT 'tTimeStamp CardID not in tEmployee', COUNT(*)
FROM dbo.tTimeStamp ts
LEFT JOIN dbo.tEmployee e ON e.EmployeeCode = RTRIM(ts.CardID)
WHERE ts.DateStamp >= @FromDateKey AND ts.DateStamp <= @ToDateKey
  AND e.EmployeeCode IS NULL

UNION ALL
SELECT 'tLogAddLeaveManagement', COUNT(*)
FROM dbo.tLogAddLeaveManagement
WHERE DateStamp >= @FromDateKey AND DateStamp <= @ToDateKey

UNION ALL
SELECT 'tRequest LEAVE_SYSTEM (VC04..VC05 overlap)', COUNT(*)
FROM dbo.tRequest
WHERE SystemType = 'LEAVE_SYSTEM' AND VC04 <= @ToDateKey AND VC05 >= @FromDateKey

UNION ALL
SELECT 'tRequest OT_SYSTEM (VC04 in range)', COUNT(*)
FROM dbo.tRequest
WHERE SystemType = 'OT_SYSTEM' AND VC04 >= @FromDateKey AND VC04 <= @ToDateKey

UNION ALL
SELECT 'tRequest by StartDate (any system)', COUNT(*)
FROM dbo.tRequest
WHERE StartDate >= @FromDate AND StartDate < DATEADD(day, 1, @ToDate)

UNION ALL
SELECT 'tLOG_OTApprove', COUNT(*)
FROM dbo.tLOG_OTApprove
WHERE DateStamp >= @FromDateKey AND DateStamp <= @ToDateKey

UNION ALL
SELECT 'tLog_OTClaim', COUNT(*)
FROM dbo.tLog_OTClaim
WHERE Datestamp >= @FromDateKey AND Datestamp <= @ToDateKey

UNION ALL
SELECT 'tTimeInOut rows with any OT > 0', COUNT(*)
FROM dbo.tTimeInOut
WHERE DateStamp >= @FromDateKey AND DateStamp <= @ToDateKey
  AND (nOT1 > 0 OR nOT1_5 > 0 OR nOT2 > 0 OR nOT3 > 0);


DROP TABLE #Spine;
