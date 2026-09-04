# 📝 MAS HR Database — Schema Detailed Reference
**เอกสารรวบรวมตารางและคอลัมน์ทั้งหมดของระบบเดิม (MAS) สำหรับเปรียบเทียบเทียบและวิเคราะห์การออกแบบระบบใหม่ (Staffo New HR)**

> **คำแนะนำ:** คลิกที่ชื่อตารางเพื่อเปิดแสดงตารางคอลัมน์ทั้งหมดของตารางนั้น ๆ โดยตารางที่มีขนาดใหญ่ (เช่น tEmployee, tPayroll, tTimeInOut) จะแสดงทุกคอลัมน์ที่มีอยู่ทั้งหมดในระบบเพื่อใช้เป็น Source of Truth ในการตรวจสอบ

---

## 1. 🔑 User & User Profile (ข้อมูลผู้ใช้หลังบ้าน)

**คำอธิบาย:** เก็บข้อมูลบัญชีล็อกอินและโปรไฟล์การเข้าใช้งานระบบของแอดมินหรือพนักงานทั่วไป (หลังบ้าน)

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** จะสอดคล้องกับ schema **`identity`** ของ Staffo ใหม่ เช่น ตาราง `identity.users` และ `identity.user_profiles` โดยส่วนของรหัสผ่านจะถูกลบออกและทดแทนด้วย ID ของผู้ให้บริการล็อกอินภายนอก (เช่น Keycloak ผ่านฟิลด์ `external_subject` ของตาราง `identity.users`)

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tUser</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `UID` | `uniqueidentifier` | NO | (newid()) |
  | `Username` | `varchar(50)` | YES |  |
  | `Password` | `varchar(50)` | YES |  |
  | `UserDesc` | `varchar(255)` | YES |  |
  | `UI_TIO_ROWHEIGHT` | `decimal(5,1)` | NO | (10.5) |
  | `UI_TIO_FONTSIZE` | `decimal(5,1)` | NO | (8.25) |
  | `USG_ID` | `uniqueidentifier` | YES |  |
  | `UI_TIO_SUMGRIDHEIGHT` | `int` | NO | (3300) |
  | `UI_TIO_DISPLAYMODE` | `smallint` | NO | (1) |
  | `UI_TIO_GROUPGRIDHEIGHT` | `int` | NO | (3300) |
  | `UI_PRL_ROWHEIGHT` | `decimal(5,1)` | NO | (10.5) |
  | `UI_PRL_FONTSIZE` | `decimal(5,1)` | NO | (8.25) |
  | `Email01` | `varchar(255)` | NO | ('') |
  | `Email02` | `varchar(255)` | NO | ('') |
  | `UserAppType` | `smallint` | NO | (0) |
  | `UI_TIO_COLFREEZE` | `smallint` | NO | (0) |
  | `User_EmpCode` | `varchar(255)` | YES |  |
  | `UI_PRL_Decimal` | `smallint` | NO | ((2)) |
  | `UI_PRL_COLFREEZE` | `smallint` | NO | ((27)) |
  | `LastLogin` | `datetime` | YES |  |
  | `UWG_ID` | `uniqueidentifier` | YES |  |
  | `IsRequireChangePassword` | `int` | YES | ((0)) |
  | `IsDisableResultEmailAfterOwnApprove` | `int` | YES | ((0)) |
  | `IsDisableAllWorkflowEmail` | `int` | YES | ((0)) |
  | `DefaultWebLanguage` | `varchar(10)` | YES | ('Eng') |
  | `IsAutoDisplayBrowseEmployee` | `int` | NO | ((1)) |
  | `IsAutoPhotoBrowseEmployee` | `smallint` | NO | ((1)) |
  | `IsAutoShowOTClaim` | `int` | NO | ((0)) |
  | `IsAutoShowOTClaimRetro` | `int` | NO | ((0)) |
  | `IsAutoShowSuspendList` | `int` | NO | ((0)) |
  | `IsAutofADMW_HRApprovalHistory` | `int` | NO | ((0)) |
  | `IsAutofADM_Employee` | `int` | NO | ((0)) |
  | `IsAutofADM_Employee_Simple` | `int` | NO | ((0)) |
  | `IsAutofADM_Organization` | `int` | NO | ((0)) |
  | `IsAutoDocumentList` | `int` | NO | ((0)) |
  | `IsAutofADMW_RetroApproval` | `int` | NO | ((0)) |
  | `IsAutofADMW_RetroApprovalHistory` | `int` | NO | ((0)) |
  | `IsActivateUser` | `smallint` | NO | ((0)) |
  | `IsAutoShowOTRequest` | `int` | NO | ((0)) |
  | `IsDisable` | `smallint` | YES | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tUser_LoginStat</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `RowID` | `uniqueidentifier` | NO | (newid()) |
  | `UID` | `uniqueidentifier` | YES |  |
  | `LoginDateTime` | `datetime` | YES | (getdate()) |
  | `IP` | `varchar(20)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tUserAD</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `UID` | `uniqueidentifier` | NO |  |
  | `UsernameAD` | `varchar(50)` | YES |  |

</details>

---

## 2. 🔐 Role, Permission & Access Control (การควบคุมสิทธิ์เข้าถึง)

**คำอธิบาย:** จัดกลุ่มสิทธิ์การเข้าใช้งานเมนู เข้าถึงข้อมูลเฉพาะแผนก หรือสิทธิ์ตามระดับสายงาน

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** ระบบของ Staffo ใหม่จะออกแบบด้วยกลไก **Scoped RBAC** ตารางในกลุ่มนี้จะสอดคล้องกับ `identity.roles`, `identity.permissions`, `identity.role_permissions` และตารางเด่นคือ **`identity.user_role_assignments`** ที่ใช้ล็อก Data Scope ของบทบาทผู้ใช้ตามโครงสร้างบริษัทหรือไซต์งาน เช่น `scope_type` ('COMPANY', 'SITE', 'DEPARTMENT')

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tUserGroup</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `USG_ID` | `uniqueidentifier` | NO | (newid()) |
  | `UserGroupName` | `varchar(50)` | NO |  |
  | `UserGroupDesc` | `varchar(255)` | YES |  |
  | `UserGroupSystemLevel` | `varchar(3)` | NO | ('NM') |
  | `IsDisable` | `smallint` | YES | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tAssignUserRole</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `ROLE_ID` | `varchar(20)` | NO |  |
  | `USG_ID` | `uniqueidentifier` | NO |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSYSUserRole</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `ROLE_ID` | `varchar(20)` | NO |  |
  | `ROLEDESC` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tAssignMenuPermission</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `USG_ID` | `uniqueidentifier` | NO |  |
  | `SwitchboardID` | `smallint` | NO |  |
  | `ItemNumber` | `smallint` | NO |  |
  | `MenuID` | `varchar(50)` | NO |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSYS_WebMenu</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `Menu_ID` | `varchar(255)` | NO |  |
  | `MenuName_en` | `varchar(255)` | NO | ('') |
  | `MenuName_th` | `varchar(255)` | NO | ('') |
  | `SystemID` | `varchar(50)` | YES |  |
  | `Level` | `int` | NO | ((0)) |
  | `MenuGroup` | `varchar(255)` | NO | ('') |
  | `Seq` | `int` | NO | ((0)) |
  | `IsHidden` | `int` | NO | ((0)) |
  | `Menu_Sequence` | `varchar(50)` | YES |  |
  | `Menu_Flag` | `varchar(100)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tUserBUPermission</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `UWG_ID` | `uniqueidentifier` | NO |  |
  | `BU_ID` | `uniqueidentifier` | NO |  |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tUserProjectPermission</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `UWG_ID` | `uniqueidentifier` | NO |  |
  | `PRJ_ID` | `varchar(255)` | NO |  |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |

</details>

---

## 3. 🏢 Company, Site & Organization (บริษัท ไซต์งาน และผังองค์กร)

**คำอธิบาย:** กำหนดความสัมพันธ์เชิงกายภาพของบริษัท ลูกค้า โครงการ ไซต์งานปฏิบัติการ และหน่วยงานย่อยตามผังองค์กร

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** ตารางบริษัทจะตรงกับ **`hr.companies`** สายบังคับบัญชาแผนกและ BU1-4 จะถูกยุบรวมเป็นตารางที่เป็นแบบ Hierarchy (Parent-Child) ตารางเดียวคือ **`hr.organization_units`** ซึ่งระบุประเภทหน่วยงานผ่านคอลัมน์ `organization_unit_type` ('organization_unit' หรือ 'department') ตามเอกสาร ADR 0011

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tCompany</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `CPN_ID` | `uniqueidentifier` | NO | (newid()) |
  | `CompanyName` | `varchar(255)` | NO |  |
  | `CompanyName_En` | `varchar(255)` | YES | ('') |
  | `CompanyAlias` | `varchar(10)` | NO |  |
  | `CompanyTAXID` | `varchar(50)` | NO |  |
  | `SSOAccountNo` | `varchar(50)` | YES |  |
  | `PVFID` | `varchar(50)` | YES |  |
  | `Address1` | `varchar(255)` | NO | ('') |
  | `Address2` | `varchar(255)` | NO | ('') |
  | `Province` | `varchar(255)` | NO | ('') |
  | `PostalCode` | `varchar(10)` | NO | ('') |
  | `Address1_en` | `varchar(255)` | NO | ('') |
  | `Address2_en` | `varchar(255)` | NO | ('') |
  | `Province_en` | `varchar(255)` | NO | ('') |
  | `PostalCode_en` | `varchar(10)` | NO | ('') |
  | `TelNo` | `varchar(255)` | NO | ('') |
  | `FaxNo` | `varchar(255)` | NO | ('') |
  | `Email` | `varchar(255)` | NO | ('') |
  | `SSOCT_Rate` | `decimal(18,2)` | NO | (5) |
  | `SSOCT_EY_Rate` | `decimal(18,2)` | NO | (5) |
  | `MinTotalIncomeForSSO` | `decimal(18,2)` | NO | (1650) |
  | `MaxTotalIncomeForSSO` | `decimal(18,2)` | NO | (15000) |
  | `PVFCT_MinRate` | `decimal(18,2)` | NO | (3) |
  | `PVFCT_EY_Rate` | `decimal(18,2)` | NO | (3) |
  | `SPFCT_Rate` | `decimal(18,2)` | NO | (0) |
  | `SmallPhoto` | `image` | YES |  |
  | `SmallPhotoFileType` | `varchar(50)` | YES |  |
  | `LargePhoto` | `image` | YES |  |
  | `LargePhotoFileType` | `varchar(5)` | YES |  |
  | `Cal_SSO` | `smallint` | YES | ((1)) |
  | `Company_Code` | `nvarchar(MAX)` | YES |  |
  | `IsUpload` | `smallint` | YES | ((0)) |
  | `Tax50_SmallPhoto` | `image` | YES |  |
  | `Tax50_LargePhoto` | `image` | YES |  |
  | `Tax50_SmallPhoto_FileType` | `varchar(20)` | YES |  |
  | `Tax50_LargePhoto_FileType` | `varchar(20)` | YES |  |
  | `Tax50_SignSmall` | `image` | YES |  |
  | `Tax50_SignLarge` | `image` | YES |  |
  | `Tax50_SignSmall_FileType` | `varchar(20)` | YES |  |
  | `Tax50_SignLarge_FileType` | `varchar(20)` | YES |  |
  | `WelfareFund_Emp_Rate` | `decimal(9,2)` | NO | ((0)) |
  | `WelfareFund_Comp_Rate` | `decimal(9,2)` | NO | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tProject</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `PRJ_ID` | `uniqueidentifier` | NO | (newid()) |
  | `ProjectName` | `varchar(100)` | NO |  |
  | `BankCode` | `varchar(10)` | YES |  |
  | `PaymentPeriod` | `smallint` | NO | (1) |
  | `SSOACC_ID` | `uniqueidentifier` | NO | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |
  | `IsClosed` | `int` | NO | (0) |
  | `ChargeRateSource` | `smallint` | NO | (0) |
  | `CurrentPeriod` | `int` | NO | (1) |
  | `IsIncentiveUsed` | `smallint` | NO | (0) |
  | `ICR_ID` | `uniqueidentifier` | YES |  |
  | `LeaveViewPeriod` | `smallint` | YES | (1) |
  | `LeaveCalcuLateType` | `smallint` | YES | (1) |
  | `HrPerDay` | `decimal(9,2)` | NO | (8) |
  | `DayPerMonth` | `int` | NO | (30) |
  | `DecimalPlace` | `int` | NO | (4) |
  | `MergeLate` | `int` | NO | (1) |
  | `MonthEndLate` | `int` | NO | (1) |
  | `EmpTypeLate` | `int` | NO | (3) |
  | `IsCalLateIn` | `int` | NO | (2) |
  | `TypeCountIn` | `int` | NO | (1) |
  | `ExceptLateIn` | `int` | NO | (0) |
  | `TypeDeductIn` | `int` | NO | (1) |
  | `DeductLateIn` | `int` | NO | (0) |
  | `IsCalLateOut` | `int` | NO | (2) |
  | `TypeCountOut` | `int` | NO | (1) |
  | `ExceptLateOut` | `int` | NO | (0) |
  | `TypeDeductOut` | `int` | NO | (1) |
  | `DeductLateOut` | `int` | NO | (0) |
  | `MonthEndAbsent` | `int` | NO | (1) |
  | `EmpTypeAbsent` | `int` | NO | (3) |
  | `IsCalAbsent` | `int` | NO | (2) |
  | `ExceptAbsent` | `int` | NO | (0) |
  | `TypeDeductAbsent` | `int` | NO | (1) |
  | `DeductAbsent` | `int` | NO | (0) |
  | `TypeDecimalTax` | `int` | NO | (1) |
  | `TypeDecimalSSO` | `int` | NO | (1) |
  | `TypeDecimalPVF` | `int` | NO | (1) |
  | `TypeDecimalNetIncome` | `int` | NO | (1) |
  | `LeavePeriod` | `varchar(8)` | YES |  |
  | `LeaveStartPeriodOption` | `smallint` | NO | ((0)) |
  | `TypeDecimalGPF` | `int` | NO | ((1)) |
  | `TypeDecimalCWU` | `int` | NO | ((1)) |
  | `TypeDecimalOT` | `int` | NO | ((1)) |
  | `TypeDecimalIncome` | `int` | NO | ((1)) |
  | `TypeDecimalDeduct` | `int` | NO | ((1)) |
  | `TypeDecimalTotalIncome` | `int` | NO | ((1)) |
  | `TypeDecimalTotalDeduct` | `int` | NO | ((1)) |
  | `TypeDecimalIncomeForSSO` | `int` | NO | ((1)) |
  | `TypeDecimalIncomeForPVF` | `int` | NO | ((1)) |
  | `TypeDecimalIncomeForGPF` | `int` | NO | ((1)) |
  | `TypeDecimalIncomeForTAX` | `int` | NO | ((1)) |
  | `IsApproveAttendance` | `int` | NO | ((0)) |
  | `SSOACC_Option` | `smallint` | NO | ((0)) |
  | `HrPerDayLeave` | `decimal(9,2)` | NO | ((8)) |
  | `DayPerMonthLeave` | `int` | NO | ((30)) |
  | `DecimalPlaceLeave` | `int` | NO | ((4)) |
  | `ChargeRateSourcePNx` | `smallint` | NO | ((0)) |
  | `TypeDecimalTotalLeaveLate` | `int` | NO | ((1)) |
  | `CalTypeAbsent` | `varchar(2)` | YES |  |
  | `CalTypeLateIn` | `varchar(2)` | YES |  |
  | `CalTypeLateOut` | `varchar(2)` | YES |  |
  | `CalTypeLeave` | `varchar(2)` | YES |  |
  | `TypeDecimalIncomeForWelfare` | `smallint` | NO | ((1)) |
  | `TypeDecimalWelfare` | `smallint` | NO | ((1)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tBU1</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `BU1_ID` | `uniqueidentifier` | NO | (newid()) |
  | `BU1DESC` | `varchar(255)` | YES |  |
  | `BU1DESC2` | `varchar(255)` | YES |  |
  | `BU1DESC_EN` | `varchar(255)` | YES |  |
  | `BU1DESC2_EN` | `varchar(255)` | YES |  |
  | `ChangesetID` | `bigint` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tBU2</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `BU2_ID` | `uniqueidentifier` | NO | (newid()) |
  | `BU2DESC` | `varchar(255)` | YES |  |
  | `BU1_ID` | `uniqueidentifier` | YES |  |
  | `BU2DESC2` | `varchar(255)` | YES |  |
  | `BU2DESC_EN` | `varchar(255)` | YES |  |
  | `BU2DESC2_EN` | `varchar(255)` | YES |  |
  | `ChangesetID` | `bigint` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tBU3</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `BU3_ID` | `uniqueidentifier` | NO | (newid()) |
  | `BU3DESC` | `varchar(255)` | YES |  |
  | `BU2_ID` | `uniqueidentifier` | YES |  |
  | `BU3DESC2` | `varchar(255)` | YES |  |
  | `BU3DESC_EN` | `varchar(255)` | YES |  |
  | `BU3DESC2_EN` | `varchar(255)` | YES |  |
  | `ChangesetID` | `bigint` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tBU4</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `BU4_ID` | `uniqueidentifier` | NO | (newid()) |
  | `BU4DESC` | `varchar(255)` | YES |  |
  | `BU3_ID` | `uniqueidentifier` | YES |  |
  | `BU4DESC2` | `varchar(255)` | YES |  |
  | `BU4DESC_EN` | `varchar(255)` | YES |  |
  | `BU4DESC2_EN` | `varchar(255)` | YES |  |
  | `ChangesetID` | `bigint` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tCostCenter</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `CostCenter_ID` | `uniqueidentifier` | NO | (newid()) |
  | `CostCenterCode` | `varchar(255)` | YES |  |
  | `CostCenterName` | `varchar(255)` | YES |  |
  | `CostCenterName_EN` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSiteTR</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `Site_ID` | `uniqueidentifier` | NO | (newid()) |
  | `Site_No` | `varchar(255)` | YES |  |
  | `Site_Name` | `varchar(255)` | YES |  |
  | `Site_Area` | `varchar(255)` | YES |  |
  | `Other_Country` | `smallint` | YES | ((0)) |
  | `Site_Status` | `smallint` | YES | ((1)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSiteRate</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `Site_ID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `Site_Rate` | `decimal(18,4)` | NO | (0) |

</details>

---

## 4. 👤 Employee Master & Personal Info (ประวัติและทะเบียนพนักงานหลัก)

**คำอธิบาย:** ตารางศูนย์กลางที่ใช้เก็บประวัติพนักงาน ประวัติการศึกษา เลขบัญชีจ่ายเงินเดือน และเกณฑ์สถานะต่าง ๆ

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** ระบบใหม่จะแยกข้อมูลบุคคลออกจากข้อมูลสัญญาจ้างงานตามดีไซน์ของ ADR 0009 เพื่อรองรับกรณีการจ้างงานซ้ำ (Rehire) โดยข้อมูลประวัติส่วนตัวจะตรงกับ **`hr.persons`** และข้อมูลสัญญา/สังกัดในแต่ละรอบการจ้างงานจะตรงกับ **`hr.employments`** ตารางตำแหน่งงานเดิมจะถูกแปลงเป็นตารางตำแหน่งระบบแบบเป็นมาตรฐานที่ **`hr.hr_positions`**

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tEmployee</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `Prefix` | `varchar(50)` | NO | ('') |
  | `FirstName` | `varchar(255)` | NO | ('') |
  | `LastName` | `varchar(255)` | NO | ('') |
  | `EnglishName` | `varchar(500)` | YES | ('') |
  | `PID` | `varchar(50)` | YES |  |
  | `Address` | `varchar(255)` | NO | ('') |
  | `Moo` | `varchar(50)` | NO | ('') |
  | `Soi` | `varchar(100)` | NO | ('') |
  | `Street` | `varchar(50)` | NO | ('') |
  | `Village` | `varchar(100)` | NO | ('') |
  | `Tumbol` | `varchar(50)` | NO | ('') |
  | `Amphor` | `varchar(50)` | NO | ('') |
  | `Province` | `varchar(50)` | NO | ('') |
  | `PostalCode` | `varchar(10)` | NO | ('') |
  | `TelNO` | `varchar(50)` | NO | ('') |
  | `Education` | `varchar(255)` | YES |  |
  | `Institute` | `varchar(100)` | YES |  |
  | `Major` | `varchar(100)` | YES |  |
  | `GPA` | `varchar(50)` | YES |  |
  | `GraduatedDate` | `smalldatetime` | YES |  |
  | `Education2` | `varchar(255)` | YES | ('') |
  | `Institute2` | `varchar(100)` | YES |  |
  | `Major2` | `varchar(100)` | YES |  |
  | `GPA2` | `varchar(50)` | YES |  |
  | `GraduatedDate2` | `smalldatetime` | YES |  |
  | `MartialStatus` | `varchar(50)` | YES |  |
  | `Sex` | `varchar(50)` | YES |  |
  | `BirthDate` | `smalldatetime` | YES |  |
  | `YearAge` | `int` | NO | (0) |
  | `MonthAge` | `int` | NO | (0) |
  | `StartDate` | `smalldatetime` | NO | (getdate()) |
  | `ResignDate` | `smalldatetime` | YES |  |
  | `ResignNoticeDate` | `smalldatetime` | YES |  |
  | `ResignDueDate` | `smalldatetime` | YES |  |
  | `ResignReason` | `uniqueidentifier` | YES |  |
  | `ResignOtherReason` | `varchar(255)` | YES |  |
  | `ResignRemark` | `varchar(255)` | YES |  |
  | `EMPST_ID` | `uniqueidentifier` | NO | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `Accountno` | `varchar(50)` | YES |  |
  | `BankName` | `varchar(50)` | YES |  |
  | `CreateDateTime` | `smalldatetime` | NO | (getdate()) |
  | `EMPTP1_ID` | `uniqueidentifier` | YES |  |
  | `EMPTP2_ID` | `uniqueidentifier` | YES |  |
  | `EMPTP3_ID` | `uniqueidentifier` | YES |  |
  | `BU1_ID` | `uniqueidentifier` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `BU2_ID` | `uniqueidentifier` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `BU3_ID` | `uniqueidentifier` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `BU4_ID` | `uniqueidentifier` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `EMPTT_ID` | `uniqueidentifier` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `Race` | `varchar(50)` | YES |  |
  | `Religion` | `varchar(50)` | YES |  |
  | `BloodGroup` | `varchar(50)` | YES |  |
  | `REF01` | `varchar(255)` | YES |  |
  | `REF02` | `varchar(255)` | YES |  |
  | `REF03` | `varchar(255)` | YES |  |
  | `REF04` | `varchar(255)` | YES |  |
  | `REF05` | `varchar(255)` | YES |  |
  | `REF06` | `varchar(255)` | YES |  |
  | `REF07` | `varchar(255)` | YES |  |
  | `REF08` | `varchar(255)` | YES |  |
  | `REF09` | `varchar(255)` | YES |  |
  | `REF10` | `varchar(255)` | YES |  |
  | `Address2` | `varchar(255)` | NO | ('') |
  | `Moo2` | `varchar(50)` | NO | ('') |
  | `Street2` | `varchar(50)` | NO | ('') |
  | `Soi2` | `varchar(100)` | NO | ('') |
  | `Village2` | `varchar(100)` | NO | ('') |
  | `Tumbol2` | `varchar(50)` | NO | ('') |
  | `Amphor2` | `varchar(50)` | NO | ('') |
  | `Province2` | `varchar(50)` | NO | ('') |
  | `PostalCode2` | `varchar(10)` | NO | ('') |
  | `TelNO2` | `varchar(50)` | NO | ('') |
  | `Height` | `varchar(50)` | YES |  |
  | `Weight` | `varchar(50)` | YES |  |
  | `OccupiedDate` | `smalldatetime` | YES |  |
  | `EntryToLineDate` | `smalldatetime` | YES | (getdate()) |
  | `EmpCode1` | `varchar(100)` | YES |  |
  | `EmpCode2` | `varchar(100)` | YES |  |
  | `EmpCode3` | `varchar(100)` | YES |  |
  | `EmpCode4` | `varchar(100)` | YES |  |
  | `LPS_ID` | `uniqueidentifier` | NO | ('FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF') |
  | `PaymentWay` | `int` | NO | (0) |
  | `PRJ_ID` | `uniqueidentifier` | NO | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `WageRate` | `decimal(18,4)` | NO | (0) |
  | `SSO_Hospital1` | `varchar(255)` | YES |  |
  | `SSO_Hospital2` | `varchar(255)` | YES |  |
  | `SSO_Hospital3` | `varchar(255)` | YES |  |
  | `SSO_StartDate` | `smalldatetime` | YES |  |
  | `SSO_CardReceivedDate` | `smalldatetime` | YES |  |
  | `SSO_CardIssued` | `smallint` | NO | (0) |
  | `SSO_CardID` | `varchar(50)` | YES |  |
  | `SSORSR_Code` | `varchar(10)` | YES |  |
  | `NAT_ID` | `uniqueidentifier` | NO | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `MTS_ID` | `uniqueidentifier` | NO | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `IDType` | `smallint` | NO | (1) |
  | `ModDateTime` | `datetime` | YES |  |
  | `EmployeeFlag` | `smallint` | NO | (1) |
  | `TAXID` | `varchar(20)` | YES |  |
  | `OT1Rate` | `decimal(18,4)` | NO | (0) |
  | `OT1_5Rate` | `decimal(18,4)` | NO | (0) |
  | `OT2Rate` | `decimal(18,4)` | NO | (0) |
  | `OT3Rate` | `decimal(18,4)` | NO | (0) |
  | `AccountNoLock` | `smallint` | NO | (0) |
  | `nSickLeaveYearQuota` | `decimal(18,4)` | YES | (0) |
  | `nPersonalLeaveYearQuota` | `decimal(18,4)` | YES | (0) |
  | `nVacationYearQuota` | `decimal(18,4)` | YES | (0) |
  | `nL01YearQuota` | `decimal(18,4)` | YES | (0) |
  | `nL02YearQuota` | `decimal(18,4)` | YES | (0) |
  | `nL03YearQuota` | `decimal(18,4)` | YES | (0) |
  | `nL04YearQuota` | `decimal(18,4)` | YES | (0) |
  | `nL05YearQuota` | `decimal(18,4)` | YES | (0) |
  | `nL06YearQuota` | `decimal(18,4)` | YES | (0) |
  | `NetIncome_REG` | `decimal(18,4)` | NO | (0) |
  | `CSSOCT_REG` | `decimal(18,4)` | NO | (0) |
  | `CTAX_REG` | `decimal(18,4)` | NO | (0) |
  | `TaxCalMethod` | `smallint` | NO | (0) |
  | `TaxPercentDeduct` | `decimal(9,2)` | NO | (3) |
  | `PVFRate` | `decimal(9,2)` | NO | (0) |
  | `PVFRate_EY` | `decimal(9,2)` | YES | (0) |
  | `PVFMemberNo` | `varchar(50)` | YES |  |
  | `FIX_WCD_ID` | `uniqueidentifier` | YES |  |
  | `FIX_SHF_ID` | `uniqueidentifier` | YES |  |
  | `PVFMemberType` | `smallint` | NO | (0) |
  | `PVFJoinDate` | `smalldatetime` | YES |  |
  | `PVFQuitDate` | `smalldatetime` | YES |  |
  | `MilitaryStatus` | `smallint` | YES |  |
  | `MilitaryExceptReason` | `varchar(255)` | YES |  |
  | `ProbationInterval` | `smallint` | NO | (120) |
  | `Fix_BillCHR_ID` | `uniqueidentifier` | YES | (null) |
  | `IncentiveAgeMonth` | `smallint` | YES | (0) |
  | `IsCalSSO` | `smallint` | NO | (0) |
  | `P01` | `decimal(18,4)` | YES | (0) |
  | `P02` | `decimal(18,4)` | YES | (0) |
  | `P03` | `decimal(18,4)` | YES | (0) |
  | `P04` | `decimal(18,4)` | YES | (0) |
  | `P05` | `decimal(18,4)` | YES | (0) |
  | `P06` | `decimal(18,4)` | YES | (0) |
  | `P07` | `decimal(18,4)` | YES | (0) |
  | `P08` | `decimal(18,4)` | YES | (0) |
  | `P09` | `decimal(18,4)` | YES | (0) |
  | `P10` | `decimal(18,4)` | YES | (0) |
  | `ProbationDuration` | `smallint` | NO | (120) |
  | `IsRequireAttendance` | `smallint` | NO | ((-1)) |
  | `IsComputeIncentive` | `smallint` | NO | ((-1)) |
  | `UID` | `uniqueidentifier` | YES |  |
  | `BatchLeave_ID` | `uniqueidentifier` | NO | ([dbo].[fDefaultRowGuid]()) |
  | `BatchProbation_ID` | `uniqueidentifier` | NO | ([dbo].[fDefaultRowGuid]()) |
  | `BankBranch` | `varchar(255)` | YES |  |
  | `N01` | `decimal(18,4)` | NO | (0) |
  | `N02` | `decimal(18,4)` | NO | (0) |
  | `N03` | `decimal(18,4)` | NO | (0) |
  | `N04` | `decimal(18,4)` | NO | (0) |
  | `N05` | `decimal(18,4)` | NO | (0) |
  | `N06` | `decimal(18,4)` | NO | (0) |
  | `N07` | `decimal(18,4)` | NO | (0) |
  | `N08` | `decimal(18,4)` | NO | (0) |
  | `N09` | `decimal(18,4)` | NO | (0) |
  | `N10` | `decimal(18,4)` | NO | (0) |
  | `TypeCalTax` | `smallint` | NO | (0) |
  | `Supervisor` | `varchar(255)` | YES |  |
  | `Manager` | `varchar(255)` | YES |  |
  | `BillWageRate` | `decimal(18,4)` | NO | (0) |
  | `BillOT1Rate` | `decimal(18,4)` | NO | (0) |
  | `BillOT1_5Rate` | `decimal(18,4)` | NO | (0) |
  | `BillOT2Rate` | `decimal(18,4)` | NO | (0) |
  | `BillOT3Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP01` | `decimal(18,4)` | NO | (0) |
  | `BillP02` | `decimal(18,4)` | NO | (0) |
  | `BillP03` | `decimal(18,4)` | NO | (0) |
  | `BillP04` | `decimal(18,4)` | NO | (0) |
  | `BillP05` | `decimal(18,4)` | NO | (0) |
  | `BillP06` | `decimal(18,4)` | NO | (0) |
  | `BillP07` | `decimal(18,4)` | NO | (0) |
  | `BillP08` | `decimal(18,4)` | NO | (0) |
  | `BillP09` | `decimal(18,4)` | NO | (0) |
  | `BillP10` | `decimal(18,4)` | NO | (0) |
  | `BillN01` | `decimal(18,4)` | NO | (0) |
  | `BillN02` | `decimal(18,4)` | NO | (0) |
  | `BillN03` | `decimal(18,4)` | NO | (0) |
  | `BillN04` | `decimal(18,4)` | NO | (0) |
  | `BillN05` | `decimal(18,4)` | NO | (0) |
  | `BillN06` | `decimal(18,4)` | NO | (0) |
  | `BillN07` | `decimal(18,4)` | NO | (0) |
  | `BillN08` | `decimal(18,4)` | NO | (0) |
  | `BillN09` | `decimal(18,4)` | NO | (0) |
  | `BillN10` | `decimal(18,4)` | NO | (0) |
  | `SSO_LastCompany` | `varchar(255)` | NO | ('') |
  | `SSO_ManyCompany` | `varchar(255)` | NO | ('') |
  | `PieceWork` | `int` | NO | (0) |
  | `IsCalPVF` | `smallint` | NO | (1) |
  | `GroupID` | `varchar(50)` | YES |  |
  | `Email` | `varchar(100)` | NO | ('') |
  | `IsCalGPF` | `smallint` | NO | ((1)) |
  | `GPFRate` | `decimal(9,2)` | NO | ((0)) |
  | `PercentInPND1` | `int` | NO | ((0)) |
  | `IsHire_Contract` | `smallint` | NO | ((0)) |
  | `Hire_ContractEndDate` | `smalldatetime` | YES |  |
  | `Cal_PVFUnit` | `smallint` | NO | ((0)) |
  | `nL07YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL08YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL09YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL10YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL11YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL12YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL13YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL14YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `nL15YearQuota` | `decimal(18,4)` | YES | ((0)) |
  | `OTCostCenter_ID` | `uniqueidentifier` | YES |  |
  | `ShiftGroup_ID` | `uniqueidentifier` | YES |  |
  | `EmpLevel_ID` | `uniqueidentifier` | YES |  |
  | `IsOTRequest` | `smallint` | NO | ((1)) |
  | `ShiftMode` | `int` | NO | ((0)) |
  | `nSickLeaveYearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nPersonalLeaveYearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nVacationYearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL01YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL02YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL03YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL04YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL05YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL06YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL07YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL08YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL09YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL10YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL11YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL12YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL13YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL14YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `nL15YearCarry` | `decimal(18,4)` | YES | ((0)) |
  | `flowleaveid` | `uniqueidentifier` | YES |  |
  | `flowOTid` | `uniqueidentifier` | YES |  |
  | `FlowTimeID` | `uniqueidentifier` | YES |  |
  | `FlowCarID` | `uniqueidentifier` | YES |  |
  | `FlowExpenseID` | `uniqueidentifier` | YES |  |
  | `FlowBenefitID` | `uniqueidentifier` | YES |  |
  | `Benefit1` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit2` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit3` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit4` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit5` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit6` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit7` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit8` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit9` | `decimal(18,2)` | NO | ((0)) |
  | `Benefit10` | `decimal(18,2)` | NO | ((0)) |
  | `PVFSUB_ID` | `varchar(15)` | YES |  |
  | `Site_ID` | `uniqueidentifier` | YES |  |
  | `nSickLeaveInitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nPersonalLeaveInitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nVacationInitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL01InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL02InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL03InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL04InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL05InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL06InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL07InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL08InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL09InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL10InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL11InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL12InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL13InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL14InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nL15InitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nSickLeaveUsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nPersonalLeaveUsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nVacationUsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL01UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL02UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL03UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL04UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL05UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL06UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL07UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL08UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL09UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL10UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL11UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL12UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL13UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL14UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nL15UsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nSickLeaveUsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nPersonalLeaveUsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nVacationUsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL01UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL02UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL03UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL04UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL05UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL06UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL07UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL08UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL09UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL10UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL11UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL12UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL13UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL14UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nL15UsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `PIDTaxType` | `smallint` | NO | ((-1)) |
  | `OtherID` | `varchar(50)` | YES |  |
  | `OTP_Way` | `smallint` | NO | ((0)) |
  | `OtherID_ExpDate` | `smalldatetime` | YES |  |
  | `OTP_TelNo` | `varchar(50)` | YES |  |
  | `IsNotAdjPVFRate` | `smallint` | NO | ((0)) |
  | `IsNotAdjPVFRate_EY` | `smallint` | NO | ((0)) |
  | `BranchCode` | `varchar(10)` | YES |  |
  | `OTRF_ID` | `uniqueidentifier` | YES |  |
  | `FlowWelfareID` | `uniqueidentifier` | YES |  |
  | `IsShowSSO_Y60` | `int` | NO | ((0)) |
  | `P11` | `decimal(18,4)` | NO | ((0)) |
  | `P12` | `decimal(18,4)` | NO | ((0)) |
  | `P13` | `decimal(18,4)` | NO | ((0)) |
  | `P14` | `decimal(18,4)` | NO | ((0)) |
  | `P15` | `decimal(18,4)` | NO | ((0)) |
  | `P16` | `decimal(18,4)` | NO | ((0)) |
  | `P17` | `decimal(18,4)` | NO | ((0)) |
  | `P18` | `decimal(18,4)` | NO | ((0)) |
  | `P19` | `decimal(18,4)` | NO | ((0)) |
  | `P20` | `decimal(18,4)` | NO | ((0)) |
  | `P21` | `decimal(18,4)` | NO | ((0)) |
  | `P22` | `decimal(18,4)` | NO | ((0)) |
  | `P23` | `decimal(18,4)` | NO | ((0)) |
  | `P24` | `decimal(18,4)` | NO | ((0)) |
  | `P25` | `decimal(18,4)` | NO | ((0)) |
  | `P26` | `decimal(18,4)` | NO | ((0)) |
  | `P27` | `decimal(18,4)` | NO | ((0)) |
  | `P28` | `decimal(18,4)` | NO | ((0)) |
  | `P29` | `decimal(18,4)` | NO | ((0)) |
  | `P30` | `decimal(18,4)` | NO | ((0)) |
  | `N11` | `decimal(18,4)` | NO | ((0)) |
  | `N12` | `decimal(18,4)` | NO | ((0)) |
  | `N13` | `decimal(18,4)` | NO | ((0)) |
  | `N14` | `decimal(18,4)` | NO | ((0)) |
  | `N15` | `decimal(18,4)` | NO | ((0)) |
  | `N16` | `decimal(18,4)` | NO | ((0)) |
  | `N17` | `decimal(18,4)` | NO | ((0)) |
  | `N18` | `decimal(18,4)` | NO | ((0)) |
  | `N19` | `decimal(18,4)` | NO | ((0)) |
  | `N20` | `decimal(18,4)` | NO | ((0)) |
  | `N21` | `decimal(18,4)` | NO | ((0)) |
  | `N22` | `decimal(18,4)` | NO | ((0)) |
  | `N23` | `decimal(18,4)` | NO | ((0)) |
  | `N24` | `decimal(18,4)` | NO | ((0)) |
  | `N25` | `decimal(18,4)` | NO | ((0)) |
  | `N26` | `decimal(18,4)` | NO | ((0)) |
  | `N27` | `decimal(18,4)` | NO | ((0)) |
  | `N28` | `decimal(18,4)` | NO | ((0)) |
  | `N29` | `decimal(18,4)` | NO | ((0)) |
  | `N30` | `decimal(18,4)` | NO | ((0)) |
  | `BillP11` | `decimal(18,4)` | NO | ((0)) |
  | `BillP12` | `decimal(18,4)` | NO | ((0)) |
  | `BillP13` | `decimal(18,4)` | NO | ((0)) |
  | `BillP14` | `decimal(18,4)` | NO | ((0)) |
  | `BillP15` | `decimal(18,4)` | NO | ((0)) |
  | `BillP16` | `decimal(18,4)` | NO | ((0)) |
  | `BillP17` | `decimal(18,4)` | NO | ((0)) |
  | `BillP18` | `decimal(18,4)` | NO | ((0)) |
  | `BillP19` | `decimal(18,4)` | NO | ((0)) |
  | `BillP20` | `decimal(18,4)` | NO | ((0)) |
  | `BillP21` | `decimal(18,4)` | NO | ((0)) |
  | `BillP22` | `decimal(18,4)` | NO | ((0)) |
  | `BillP23` | `decimal(18,4)` | NO | ((0)) |
  | `BillP24` | `decimal(18,4)` | NO | ((0)) |
  | `BillP25` | `decimal(18,4)` | NO | ((0)) |
  | `BillP26` | `decimal(18,4)` | NO | ((0)) |
  | `BillP27` | `decimal(18,4)` | NO | ((0)) |
  | `BillP28` | `decimal(18,4)` | NO | ((0)) |
  | `BillP29` | `decimal(18,4)` | NO | ((0)) |
  | `BillP30` | `decimal(18,4)` | NO | ((0)) |
  | `BillN11` | `decimal(18,4)` | NO | ((0)) |
  | `BillN12` | `decimal(18,4)` | NO | ((0)) |
  | `BillN13` | `decimal(18,4)` | NO | ((0)) |
  | `BillN14` | `decimal(18,4)` | NO | ((0)) |
  | `BillN15` | `decimal(18,4)` | NO | ((0)) |
  | `BillN16` | `decimal(18,4)` | NO | ((0)) |
  | `BillN17` | `decimal(18,4)` | NO | ((0)) |
  | `BillN18` | `decimal(18,4)` | NO | ((0)) |
  | `BillN19` | `decimal(18,4)` | NO | ((0)) |
  | `BillN20` | `decimal(18,4)` | NO | ((0)) |
  | `BillN21` | `decimal(18,4)` | NO | ((0)) |
  | `BillN22` | `decimal(18,4)` | NO | ((0)) |
  | `BillN23` | `decimal(18,4)` | NO | ((0)) |
  | `BillN24` | `decimal(18,4)` | NO | ((0)) |
  | `BillN25` | `decimal(18,4)` | NO | ((0)) |
  | `BillN26` | `decimal(18,4)` | NO | ((0)) |
  | `BillN27` | `decimal(18,4)` | NO | ((0)) |
  | `BillN28` | `decimal(18,4)` | NO | ((0)) |
  | `BillN29` | `decimal(18,4)` | NO | ((0)) |
  | `BillN30` | `decimal(18,4)` | NO | ((0)) |
  | `IDCardIssuedDate` | `smalldatetime` | YES |  |
  | `IDCardExpiredDate` | `smalldatetime` | YES |  |
  | `SourceTaxCalMethod` | `smallint` | NO | ((1)) |
  | `FIX_SSOACC_ID` | `uniqueidentifier` | YES |  |
  | `nVacationCarryExpire` | `decimal(9,4)` | NO | ((0)) |
  | `FirstName_EN` | `varchar(50)` | YES |  |
  | `LastName_EN` | `varchar(50)` | YES |  |
  | `AppMenu` | `varchar(255)` | YES |  |
  | `SystemUser` | `varchar(255)` | YES |  |
  | `BankOption` | `varchar(2)` | YES |  |
  | `BankOption_EmpId` | `varchar(50)` | YES |  |
  | `nCompensateLeaveYearQuota` | `decimal(18,4)` | NO | ((0)) |
  | `nCompensateLeaveYearCarry` | `decimal(18,4)` | NO | ((0)) |
  | `nCompensateLeaveInitQuota` | `decimal(9,4)` | NO | ((0)) |
  | `nCompensateUsedCarry` | `decimal(9,4)` | NO | ((0)) |
  | `nCompensateUsedClaim` | `decimal(9,4)` | NO | ((0)) |
  | `nCompensateLeaveCarry` | `decimal(9,2)` | YES |  |
  | `nCompensateCarryExpire` | `decimal(18,4)` | NO | ((0)) |
  | `ESavingCode` | `varchar(20)` | YES | ('') |
  | `WelfareFund_Emp_Rate` | `decimal(9,2)` | NO | ((0)) |
  | `WelfareFund_Comp_Rate` | `decimal(9,2)` | NO | ((0)) |
  | `IsCalWelfare_Fund` | `smallint` | NO | ((1)) |
  | `nMaternityLeaveYearQuota` | `decimal(18,4)` | NO | ((0)) |
  | `nParentalLeaveMomYearQuota` | `decimal(18,4)` | NO | ((0)) |
  | `nParentalLeaveDadYearQuota` | `decimal(18,4)` | NO | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeePhoto</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `PhotoType` | `varchar(10)` | YES |  |
  | `Photo` | `image` | YES |  |
  | `UID` | `uniqueidentifier` | YES |  |
  | `SystemUser` | `varchar(255)` | YES |  |
  | `AppMenu` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeBank</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `BN_ID` | `varchar(5)` | NO |  |
  | `EmpCode` | `varchar(50)` | NO |  |
  | `Flag1` | `varchar(255)` | NO | ('') |
  | `Flag2` | `varchar(255)` | NO | ('') |
  | `Flag3` | `varchar(255)` | NO | ('') |
  | `Flag4` | `varchar(255)` | NO | ('') |
  | `Flag5` | `varchar(255)` | NO | ('') |
  | `Flag6` | `varchar(255)` | NO | ('') |
  | `Flag7` | `varchar(255)` | NO | ('') |
  | `Flag8` | `varchar(255)` | NO | ('') |
  | `Flag9` | `varchar(255)` | NO | ('') |
  | `Flag10` | `varchar(255)` | NO | ('') |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployee_Children</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `ID` | `int` | NO |  |
  | `EmployeeCode` | `nvarchar(50)` | NO |  |
  | `PrefixID` | `int` | NO |  |
  | `FirstName` | `nvarchar(255)` | NO | ('') |
  | `LastName` | `nvarchar(255)` | NO | ('') |
  | `FirstName_En` | `nvarchar(255)` | YES | ('') |
  | `LastName_En` | `nvarchar(255)` | YES | ('') |
  | `PID` | `varchar(50)` | NO | ('') |
  | `BirthDate` | `datetime` | YES |  |
  | `IsStudy` | `bit` | NO | ((0)) |
  | `IsDeduction` | `bit` | NO | ((0)) |
  | `IsDeductionProtege` | `bit` | NO | ((0)) |
  | `DeductionType` | `int` | NO | ((1)) |
  | `CreateDate` | `datetime` | NO | (getdate()) |
  | `UserName` | `varchar(100)` | YES | ('') |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeStatus</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EMPST_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EMPStatus` | `varchar(255)` | NO |  |
  | `EMPSTG_ID` | `varchar(10)` | NO |  |
  | `TextColor` | `int` | NO | (0) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeStatusGroup</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EMPSTG_ID` | `varchar(10)` | NO |  |
  | `EMPStatusGroup` | `varchar(255)` | NO |  |
  | `IsDefault` | `smallint` | NO |  |
  | `SEQ` | `smallint` | NO | (0) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeLevel</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmpLevel_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EmpLevel_Desc` | `varchar(255)` | YES |  |
  | `EmpLevel_Desc_EN` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeTitle</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EMPTT_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EmployeeTitle` | `varchar(255)` | YES |  |
  | `EmployeeTitle_EN` | `varchar(255)` | YES |  |
  | `EmployeeTitle2_Desc` | `varchar(255)` | YES |  |
  | `EmployeeTitle_Type` | `varchar(5)` | YES | ((1)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeType1</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EMPTP1_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EMPTP1Desc` | `varchar(255)` | NO |  |
  | `IsDefault` | `smallint` | NO | (0) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeType2</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EMPTP2_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EMPTP2DESC` | `varchar(255)` | NO |  |
  | `IsDefault` | `smallint` | NO | (0) |
  | `EMPTP1_ID` | `uniqueidentifier` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tEmployeeType3</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EMPTP3_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EMPTP3DESC` | `varchar(255)` | NO |  |
  | `IsDefault` | `smallint` | NO | (0) |
  | `EMPTP2_ID` | `uniqueidentifier` | YES |  |

</details>

---

## 5. 📅 Time Attendance & Work Logs (การลงเวลาทำงานจริงรายวัน)

**คำอธิบาย:** เก็บบันทึกการสแกนนิ้วมือในแต่ละวัน และผลลัพธ์เวลาทำงานหลังประมวลผลเทียบกับกะการทำงานแล้ว

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** โมดูลการเข้าทำงานและตารางประมวลผลเวลาเข้าออกของพนักงาน ในระบบใหม่จะอยู่ในส่วนงานคำนวณเวลาปฏิบัติการของโมดูล Attendance

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tTimeStamp</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `CardID` | `varchar(50)` | NO |  |
  | `Machine_ID` | `varchar(255)` | NO |  |
  | `DateInput` | `varchar(8)` | NO |  |
  | `nHour` | `smallint` | NO |  |
  | `nMinute` | `smallint` | NO |  |
  | `Duty` | `varchar(10)` | NO |  |
  | `DateStamp` | `varchar(8)` | NO |  |
  | `JobType` | `smallint` | NO | (1) |
  | `ShiftTime_Type` | `uniqueidentifier` | YES |  |
  | `CalculatedResult` | `smallint` | YES |  |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |
  | `UID` | `int` | YES |  |
  | `EmployeeCode` | `varchar(255)` | YES |  |
  | `ScanNumber` | `varchar(50)` | YES |  |
  | `CalculatedResult_Mode20` | `smallint` | YES |  |
  | `DateStamp_Mode20` | `varchar(20)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tTimeInOut</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `DateStamp` | `char(8)` | NO |  |
  | `InTime_Hour` | `smallint` | YES |  |
  | `InTime_Minute` | `smallint` | YES |  |
  | `OutTime_Hour` | `smallint` | YES |  |
  | `OutTime_Minute` | `smallint` | YES |  |
  | `SHF_ID` | `uniqueidentifier` | NO |  |
  | `JobType` | `int` | NO | (0) |
  | `nWorkUnit` | `decimal(9,2)` | NO | (0) |
  | `nOT1` | `decimal(9,2)` | NO | (0) |
  | `nOT1_5` | `decimal(9,2)` | NO | (0) |
  | `nOT2` | `decimal(9,2)` | NO | (0) |
  | `nOT3` | `decimal(9,2)` | NO | (0) |
  | `naOT1` | `decimal(9,2)` | NO | (0) |
  | `naOT1_5` | `decimal(9,2)` | NO | (0) |
  | `naOT2` | `decimal(9,2)` | NO | (0) |
  | `naOT3` | `decimal(9,2)` | NO | (0) |
  | `nbOT1` | `decimal(9,2)` | NO | (0) |
  | `nbOT1_5` | `decimal(9,2)` | NO | (0) |
  | `nbOT2` | `decimal(9,2)` | NO | (0) |
  | `nbOT3` | `decimal(9,2)` | NO | (0) |
  | `ncOT1` | `decimal(9,2)` | NO | (0) |
  | `ncOT1_5` | `decimal(9,2)` | NO | (0) |
  | `ncOT2` | `decimal(9,2)` | NO | (0) |
  | `ncOT3` | `decimal(9,2)` | NO | (0) |
  | `nShift` | `decimal(9,2)` | NO | (0) |
  | `nIncentive` | `decimal(9,2)` | NO | (0) |
  | `nSickLeave` | `decimal(9,2)` | NO | (0) |
  | `nPersonalLeave` | `decimal(9,2)` | NO | (0) |
  | `nVacation` | `decimal(9,2)` | NO | (0) |
  | `FlagWork` | `varchar(1)` | NO |  |
  | `FlagLocked` | `smallint` | NO | (0) |
  | `P01` | `decimal(18,4)` | NO | (0) |
  | `P02` | `decimal(18,4)` | NO | (0) |
  | `P03` | `decimal(18,4)` | NO | (0) |
  | `P04` | `decimal(18,4)` | NO | (0) |
  | `P05` | `decimal(18,4)` | NO | (0) |
  | `P06` | `decimal(18,4)` | NO | (0) |
  | `P07` | `decimal(18,4)` | NO | (0) |
  | `P08` | `decimal(18,4)` | NO | (0) |
  | `P09` | `decimal(18,4)` | NO | (0) |
  | `P10` | `decimal(18,4)` | NO | (0) |
  | `P11` | `decimal(18,4)` | NO | (0) |
  | `P12` | `decimal(18,4)` | NO | (0) |
  | `P13` | `decimal(18,4)` | NO | (0) |
  | `P14` | `decimal(18,4)` | NO | (0) |
  | `P15` | `decimal(18,4)` | NO | (0) |
  | `P16` | `decimal(18,4)` | NO | (0) |
  | `P17` | `decimal(18,4)` | NO | (0) |
  | `P18` | `decimal(18,4)` | NO | (0) |
  | `P19` | `decimal(18,4)` | NO | (0) |
  | `P20` | `decimal(18,4)` | NO | (0) |
  | `BillWageRate` | `decimal(9,2)` | NO | (1) |
  | `BillOT1Rate` | `decimal(9,2)` | NO | (1) |
  | `BillOT1_5Rate` | `decimal(9,2)` | NO | (1) |
  | `BillOT2Rate` | `decimal(9,2)` | NO | (1) |
  | `BillOT3Rate` | `decimal(9,2)` | NO | (1) |
  | `BillLateRate` | `decimal(9,2)` | NO | (1) |
  | `BillShiftRate` | `decimal(9,2)` | NO | (1) |
  | `BillIncentiveRate` | `decimal(9,2)` | NO | (1) |
  | `BillP01Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP02Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP03Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP04Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP05Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP06Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP07Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP08Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP09Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP10Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP11Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP12Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP13Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP14Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP15Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP16Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP17Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP18Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP19Rate` | `decimal(9,2)` | NO | (0) |
  | `BillP20Rate` | `decimal(9,2)` | NO | (0) |
  | `nLateIn` | `decimal(9,2)` | NO | (0) |
  | `nLateOut` | `decimal(9,2)` | NO | (0) |
  | `nHoliday` | `decimal(9,2)` | NO | (0) |
  | `tSickLeaveReason` | `varchar(255)` | NO | ('') |
  | `tPersonalLeaveReason` | `varchar(255)` | NO | ('') |
  | `tVacationReason` | `varchar(255)` | NO | ('') |
  | `IsEdited` | `smallint` | NO | (0) |
  | `T01` | `varchar(150)` | YES |  |
  | `T02` | `varchar(150)` | YES |  |
  | `T03` | `varchar(150)` | YES |  |
  | `T04` | `varchar(150)` | YES |  |
  | `T05` | `varchar(150)` | YES |  |
  | `L01` | `decimal(9,2)` | NO | (0) |
  | `L02` | `decimal(9,2)` | NO | (0) |
  | `L03` | `decimal(9,2)` | NO | (0) |
  | `L04` | `decimal(9,2)` | NO | (0) |
  | `L05` | `decimal(9,2)` | NO | (0) |
  | `L06` | `decimal(9,2)` | NO | (0) |
  | `tL01Reason` | `varchar(255)` | NO | ('') |
  | `tL02Reason` | `varchar(255)` | YES | ('') |
  | `tL03Reason` | `varchar(255)` | YES | ('') |
  | `tL04Reason` | `varchar(255)` | YES | ('') |
  | `tL05Reason` | `varchar(255)` | YES | ('') |
  | `tL06Reason` | `varchar(255)` | YES | ('') |
  | `TIOStatus` | `smallint` | NO | (0) |
  | `nSickLeave_StartTime` | `varchar(5)` | YES |  |
  | `nSickLeave_EndTime` | `varchar(5)` | YES |  |
  | `nPersonalLeave_StartTime` | `varchar(5)` | YES |  |
  | `nPersonalLeave_EndTime` | `varchar(5)` | YES |  |
  | `nVacation_StartTime` | `varchar(5)` | YES |  |
  | `nVacation_EndTime` | `varchar(5)` | YES |  |
  | `L01_StartTime` | `varchar(5)` | YES |  |
  | `L01_EndTime` | `varchar(5)` | YES |  |
  | `L02_StartTime` | `varchar(5)` | YES |  |
  | `L02_EndTime` | `varchar(5)` | YES |  |
  | `L03_StartTime` | `varchar(5)` | YES |  |
  | `L03_EndTime` | `varchar(5)` | YES |  |
  | `L04_StartTime` | `varchar(5)` | YES |  |
  | `L04_EndTime` | `varchar(5)` | YES |  |
  | `L05_StartTime` | `varchar(5)` | YES |  |
  | `L05_EndTime` | `varchar(5)` | YES |  |
  | `L06_StartTime` | `varchar(5)` | YES |  |
  | `L06_EndTime` | `varchar(5)` | YES |  |
  | `nLateInCount` | `decimal(9,2)` | NO | (0) |
  | `nLateOutCount` | `decimal(9,2)` | NO | (0) |
  | `BU1_ID` | `uniqueidentifier` | YES |  |
  | `BU2_ID` | `uniqueidentifier` | YES |  |
  | `BU3_ID` | `uniqueidentifier` | YES |  |
  | `BU4_ID` | `uniqueidentifier` | YES |  |
  | `InTime2_Hour` | `smallint` | YES |  |
  | `InTime2_Minute` | `smallint` | YES |  |
  | `OutTime2_Hour` | `smallint` | YES |  |
  | `OutTime2_Minute` | `smallint` | YES |  |
  | `InTimeOT_Hour` | `smallint` | YES |  |
  | `InTimeOT_Minute` | `smallint` | YES |  |
  | `OutTimeOT_Hour` | `smallint` | YES |  |
  | `OutTimeOT_Minute` | `smallint` | YES |  |
  | `MinLeaveStartTime` | `varchar(255)` | YES |  |
  | `MaxLeaveEndTime` | `varchar(255)` | YES |  |
  | `Wagerate` | `decimal(18,4)` | YES |  |
  | `Site_No` | `varchar(255)` | YES |  |
  | `CAL_nOT1` | `decimal(18,4)` | YES |  |
  | `CAL_nOT1_5` | `decimal(18,4)` | YES |  |
  | `CAL_nOT2` | `decimal(18,4)` | YES |  |
  | `CAL_nOT3` | `decimal(18,4)` | YES |  |
  | `CAL_nOT4` | `decimal(18,4)` | YES |  |
  | `IsPayLeave` | `smallint` | YES | (0) |
  | `IsPaySickLeave` | `smallint` | NO | (1) |
  | `IsPayPersonalLeave` | `smallint` | NO | (1) |
  | `IsPayVacation` | `smallint` | NO | (1) |
  | `IsPayL01` | `smallint` | NO | (1) |
  | `IsPayL02` | `smallint` | NO | (1) |
  | `IsPayL03` | `smallint` | NO | (1) |
  | `IsPayL04` | `smallint` | NO | (1) |
  | `IsPayL05` | `smallint` | NO | (1) |
  | `IsPayL06` | `smallint` | NO | (1) |
  | `Site_ID` | `uniqueidentifier` | YES |  |
  | `Note` | `varchar(255)` | YES |  |
  | `OTApproveStatus` | `smallint` | NO | (0) |
  | `ReplaceTo` | `varchar(255)` | YES |  |
  | `ReplaceType` | `smallint` | NO | (0) |
  | `DatePostpone` | `char(8)` | YES |  |
  | `ReplaceToName` | `varchar(255)` | YES |  |
  | `FlagApp` | `int` | NO | (0) |
  | `FlagEdit` | `int` | NO | (0) |
  | `ShiftcodeID` | `varchar(255)` | NO | ('') |
  | `Isnshift` | `int` | YES |  |
  | `ReplaceBUDESC` | `varchar(2000)` | YES |  |
  | `ReplaceBU1` | `uniqueidentifier` | YES |  |
  | `ReplaceBU2` | `uniqueidentifier` | YES |  |
  | `ReplaceBU3` | `uniqueidentifier` | YES |  |
  | `ReplaceBU4` | `uniqueidentifier` | YES |  |
  | `ReplaceInTime_Hour` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceInTime_Minute` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceOutTime_Hour` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceOutTime_Minute` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceShift` | `uniqueidentifier` | YES |  |
  | `ReplaceShiftBU` | `uniqueidentifier` | YES |  |
  | `ReplacenWorkUnit` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceOT1` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceOT2` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceOT1_5` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceOT3` | `decimal(9,2)` | YES | ((0)) |
  | `ReplaceMemo` | `varchar(2000)` | YES |  |
  | `Replacenshift` | `decimal(9,2)` | YES |  |
  | `IsFilter` | `int` | NO | ((0)) |
  | `UID` | `uniqueidentifier` | YES |  |
  | `nOT1_H` | `decimal(9,2)` | NO | ((0)) |
  | `nOT1_M` | `decimal(9,2)` | NO | ((0)) |
  | `nOT1_5_H` | `decimal(9,2)` | NO | ((0)) |
  | `nOT1_5_M` | `decimal(9,2)` | NO | ((0)) |
  | `nOT2_H` | `decimal(9,2)` | NO | ((0)) |
  | `nOT2_M` | `decimal(9,2)` | NO | ((0)) |
  | `nOT3_H` | `decimal(9,2)` | NO | ((0)) |
  | `nOT3_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT1_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT1_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT1_5_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT1_5_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT2_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT2_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT3_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_nOT3_M` | `decimal(9,2)` | NO | ((0)) |
  | `L07` | `decimal(9,2)` | NO | ((0)) |
  | `L08` | `decimal(9,2)` | NO | ((0)) |
  | `L09` | `decimal(9,2)` | NO | ((0)) |
  | `L10` | `decimal(9,2)` | NO | ((0)) |
  | `L11` | `decimal(9,2)` | NO | ((0)) |
  | `L12` | `decimal(9,2)` | NO | ((0)) |
  | `L13` | `decimal(9,2)` | NO | ((0)) |
  | `L14` | `decimal(9,2)` | NO | ((0)) |
  | `L15` | `decimal(9,2)` | NO | ((0)) |
  | `L07_StartTime` | `varchar(5)` | YES |  |
  | `L07_EndTime` | `varchar(5)` | YES |  |
  | `L08_StartTime` | `varchar(5)` | YES |  |
  | `L08_EndTime` | `varchar(5)` | YES |  |
  | `L09_StartTime` | `varchar(5)` | YES |  |
  | `L09_EndTime` | `varchar(5)` | YES |  |
  | `L10_StartTime` | `varchar(5)` | YES |  |
  | `L10_EndTime` | `varchar(5)` | YES |  |
  | `L11_StartTime` | `varchar(5)` | YES |  |
  | `L11_EndTime` | `varchar(5)` | YES |  |
  | `L12_StartTime` | `varchar(5)` | YES |  |
  | `L12_EndTime` | `varchar(5)` | YES |  |
  | `L13_StartTime` | `varchar(5)` | YES |  |
  | `L13_EndTime` | `varchar(5)` | YES |  |
  | `L14_StartTime` | `varchar(5)` | YES |  |
  | `L14_EndTime` | `varchar(5)` | YES |  |
  | `L15_StartTime` | `varchar(5)` | YES |  |
  | `L15_EndTime` | `varchar(5)` | YES |  |
  | `IsPayL07` | `smallint` | NO | ((1)) |
  | `IsPayL08` | `smallint` | NO | ((1)) |
  | `IsPayL09` | `smallint` | NO | ((1)) |
  | `IsPayL10` | `smallint` | NO | ((1)) |
  | `IsPayL11` | `smallint` | NO | ((1)) |
  | `IsPayL12` | `smallint` | NO | ((1)) |
  | `IsPayL13` | `smallint` | NO | ((1)) |
  | `IsPayL14` | `smallint` | NO | ((1)) |
  | `IsPayL15` | `smallint` | NO | ((1)) |
  | `tL07Reason` | `varchar(255)` | YES |  |
  | `tL08Reason` | `varchar(255)` | YES |  |
  | `tL09Reason` | `varchar(255)` | YES |  |
  | `tL10Reason` | `varchar(255)` | YES |  |
  | `tL11Reason` | `varchar(255)` | YES |  |
  | `tL12Reason` | `varchar(255)` | YES |  |
  | `tL13Reason` | `varchar(255)` | YES |  |
  | `tL14Reason` | `varchar(255)` | YES |  |
  | `tL15Reason` | `varchar(255)` | YES |  |
  | `naOT1_H` | `decimal(9,2)` | NO | ((0)) |
  | `naOT1_M` | `decimal(9,2)` | NO | ((0)) |
  | `naOT1_5_H` | `decimal(9,2)` | NO | ((0)) |
  | `naOT1_5_M` | `decimal(9,2)` | NO | ((0)) |
  | `naOT2_H` | `decimal(9,2)` | NO | ((0)) |
  | `naOT3_H` | `decimal(9,2)` | NO | ((0)) |
  | `naOT3_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT1_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT1_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT1_5_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT1_5_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT2_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT2_M` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT3_H` | `decimal(9,2)` | NO | ((0)) |
  | `Cal_naOT3_M` | `decimal(9,2)` | NO | ((0)) |
  | `IsForwardUsed` | `smallint` | NO | ((0)) |
  | `Cal_naOT1` | `decimal(18,4)` | YES |  |
  | `Cal_naOT1_5` | `decimal(18,4)` | YES |  |
  | `Cal_naOT2` | `decimal(18,4)` | YES |  |
  | `Cal_naOT3` | `decimal(18,4)` | YES |  |
  | `naOT2_M` | `decimal(9,2)` | NO | ((0)) |
  | `SetFixShift` | `uniqueidentifier` | YES |  |
  | `SetShiftGroup` | `uniqueidentifier` | YES |  |
  | `SetFixCalendar` | `uniqueidentifier` | YES |  |
  | `SickLeaveMedCert` | `smallint` | NO | ((0)) |
  | `Cal_ShiftWorkUnit` | `decimal(9,2)` | NO | ((8)) |
  | `Used_nSickLeave_Year` | `varchar(4)` | YES |  |
  | `Used_nPersonalLeave_Year` | `varchar(4)` | YES |  |
  | `Used_nVacation_Year` | `varchar(4)` | YES |  |
  | `Used_L01_Year` | `varchar(4)` | YES |  |
  | `Used_L02_Year` | `varchar(4)` | YES |  |
  | `Used_L03_Year` | `varchar(4)` | YES |  |
  | `Used_L04_Year` | `varchar(4)` | YES |  |
  | `Used_L05_Year` | `varchar(4)` | YES |  |
  | `Used_L06_Year` | `varchar(4)` | YES |  |
  | `Used_L07_Year` | `varchar(4)` | YES |  |
  | `Used_L08_Year` | `varchar(4)` | YES |  |
  | `Used_L09_Year` | `varchar(4)` | YES |  |
  | `Used_L10_Year` | `varchar(4)` | YES |  |
  | `Used_L11_Year` | `varchar(4)` | YES |  |
  | `Used_L12_Year` | `varchar(4)` | YES |  |
  | `Used_L13_Year` | `varchar(4)` | YES |  |
  | `Used_L14_Year` | `varchar(4)` | YES |  |
  | `Used_L15_Year` | `varchar(4)` | YES |  |
  | `nSickLeaveCarry` | `decimal(9,2)` | NO | ((0)) |
  | `nPersonalLeaveCarry` | `decimal(9,2)` | NO | ((0)) |
  | `nVacationCarry` | `decimal(9,2)` | NO | ((0)) |
  | `L01Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L02Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L03Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L04Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L05Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L06Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L07Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L08Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L09Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L10Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L11Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L12Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L13Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L14Carry` | `decimal(9,2)` | NO | ((0)) |
  | `L15Carry` | `decimal(9,2)` | NO | ((0)) |
  | `FlagPlanLocked` | `smallint` | NO | ((0)) |
  | `FlagLeave` | `varchar(50)` | YES |  |
  | `nCompensateLeave` | `decimal(9,2)` | NO | ((0)) |
  | `nCompensateLeaveCarry` | `decimal(9,2)` | NO | ((0)) |
  | `nCompensateLeave_StartTime` | `varchar(5)` | YES |  |
  | `nCompensateLeave_EndTime` | `varchar(5)` | YES |  |
  | `IsPayCompensateLeave` | `smallint` | NO | ((1)) |
  | `tCompensateLeaveReason` | `varchar(255)` | YES |  |
  | `Used_CompensateLeave_Year` | `varchar(4)` | YES |  |
  | `EmpCode1` | `varchar(50)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tTimeInOut_Data</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `Time_EmployeeCode` | `varchar(50)` | NO |  |
  | `Time_DateStamp` | `varchar(8)` | NO |  |
  | `Time_Site_ID` | `uniqueidentifier` | YES |  |
  | `Time_PRJ_ID` | `uniqueidentifier` | YES |  |
  | `Time_EMPTT_ID` | `uniqueidentifier` | YES |  |
  | `Time_EmpLevel_ID` | `uniqueidentifier` | YES |  |
  | `Time_CostCenter_ID` | `uniqueidentifier` | YES |  |
  | `Time_EMPTP1_ID` | `uniqueidentifier` | YES |  |
  | `Time_EMPTP2_ID` | `uniqueidentifier` | YES |  |
  | `Time_EMPTP3_ID` | `uniqueidentifier` | YES |  |
  | `Time_BU1_ID` | `uniqueidentifier` | YES |  |
  | `Time_BU2_ID` | `uniqueidentifier` | YES |  |
  | `Time_BU3_ID` | `uniqueidentifier` | YES |  |
  | `Time_BU4_ID` | `uniqueidentifier` | YES |  |
  | `Time_Site_No` | `varchar(255)` | YES |  |
  | `Time_Site_Name` | `varchar(255)` | YES |  |
  | `Time_Site_Area` | `varchar(255)` | YES |  |
  | `Time_Other_Country` | `smallint` | YES |  |
  | `Time_Site_Status` | `smallint` | YES |  |
  | `Time_Project_Name` | `varchar(255)` | YES |  |
  | `Time_EmployeeTitle` | `varchar(255)` | YES |  |
  | `Time_EmployeeTitle_EN` | `varchar(255)` | YES |  |
  | `Time_EmployeeTitle2_Desc` | `varchar(255)` | YES |  |
  | `Time_EmployeeTitle_Type` | `varchar(5)` | YES |  |
  | `Time_EmpLevel_Desc` | `varchar(255)` | YES |  |
  | `Time_EmpLevel_Desc_EN` | `varchar(255)` | YES |  |
  | `Time_CostCenterCode` | `varchar(255)` | YES |  |
  | `Time_CostCenterName` | `varchar(255)` | YES |  |
  | `Time_CostCenterName_EN` | `varchar(255)` | YES |  |
  | `Time_EMPTP1Desc` | `varchar(255)` | YES |  |
  | `Time_EMPTP2Desc` | `varchar(255)` | YES |  |
  | `Time_EMPTP3Desc` | `varchar(255)` | YES |  |
  | `Time_BU1DESC` | `varchar(255)` | YES |  |
  | `Time_BU2DESC` | `varchar(255)` | YES |  |
  | `Time_BU3DESC` | `varchar(255)` | YES |  |
  | `Time_BU4DESC` | `varchar(255)` | YES |  |
  | `Time_BU1DESC2` | `varchar(255)` | YES |  |
  | `Time_BU2DESC2` | `varchar(255)` | YES |  |
  | `Time_BU3DESC2` | `varchar(255)` | YES |  |
  | `Time_BU4DESC2` | `varchar(255)` | YES |  |
  | `Time_BU1DESC_EN` | `varchar(255)` | YES |  |
  | `Time_BU2DESC_EN` | `varchar(255)` | YES |  |
  | `Time_BU3DESC_EN` | `varchar(255)` | YES |  |
  | `Time_BU4DESC_EN` | `varchar(255)` | YES |  |
  | `Time_BU1DESC2_EN` | `varchar(255)` | YES |  |
  | `Time_BU2DESC2_EN` | `varchar(255)` | YES |  |
  | `Time_BU3DESC2_EN` | `varchar(255)` | YES |  |
  | `Time_BU4DESC2_EN` | `varchar(255)` | YES |  |
  | `TimeScanInTime` | `varchar(10)` | YES |  |
  | `TimeScanOutTime` | `varchar(10)` | YES |  |
  | `ScanNoIntime` | `varchar(50)` | YES |  |
  | `ScanNoOuttime` | `varchar(50)` | YES |  |

</details>

---

## 6. 🕒 Shift, Overtime & Work Calendar (การเข้ากะ ล่วงเวลา และปฏิทินงาน)

**คำอธิบาย:** โครงสร้างกฎเกณฑ์การเข้ากะทำงานของแต่ละไซต์ ปฏิทินวันหยุดบริษัท และการกำหนดกะรายวัน/สัปดาห์

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** เป็นส่วนการเข้ากะและการคิดชั่วโมงล่วงเวลา (OT) ในส่วนของการวางระบบ Attendance และการคำนวณเงินในงวดนั้น ๆ สำหรับตัว `staffo-field-api` (Field Context) จะอยู่ในสถานะ Compatibility-hold (ADR 0012) ดังนั้นตารางประมวลผลกะรายวันจะไม่ได้ใช้โครงสร้างของ field api อีกต่อไป แต่จะเปลี่ยนผ่านไปใช้ engine คำนวณแบบสถิติเวลาแทน

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tShift</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `SHF_ID` | `uniqueidentifier` | NO | (newid()) |
  | `ShiftGroup` | `int` | YES |  |
  | `ShiftName` | `varchar(100)` | YES |  |
  | `ShiftStart_Hour` | `smallint` | YES |  |
  | `ShiftStart_Minute` | `smallint` | YES |  |
  | `ShiftStart_Onday` | `smallint` | YES |  |
  | `ShiftEnd_Hour` | `smallint` | YES |  |
  | `ShiftEnd_Minute` | `smallint` | YES |  |
  | `ShiftEnd_OnDay` | `smallint` | YES |  |
  | `InShiftTimeStart_Hour` | `smallint` | YES |  |
  | `InShiftTimeStart_Minute` | `smallint` | YES |  |
  | `InShiftTimeStart_OnDay` | `smallint` | YES |  |
  | `InShiftTimeEnd_Hour` | `smallint` | YES |  |
  | `InShiftTimeEnd_Minute` | `smallint` | YES |  |
  | `InShiftTimeEnd_OnDay` | `smallint` | YES |  |
  | `InShiftTime_Duty` | `varchar(50)` | YES |  |
  | `OutShiftTimeStart_Hour` | `smallint` | YES |  |
  | `OutShiftTimeStart_Minute` | `smallint` | YES |  |
  | `OutShiftTimeStart_OnDay` | `smallint` | YES |  |
  | `OutShiftTimeEnd_Hour` | `smallint` | YES |  |
  | `OutShiftTimeEnd_Minute` | `smallint` | YES |  |
  | `OutShiftTimeEnd_OnDay` | `smallint` | YES |  |
  | `OutShiftTime_Duty` | `varchar(50)` | YES |  |
  | `Status` | `smallint` | YES |  |
  | `ShiftIncentive` | `int` | NO | (0) |
  | `IsDefault` | `smallint` | NO | (0) |
  | `ColorSymbol` | `int` | NO | (16777215) |
  | `ShiftWorkUnit` | `decimal(9,2)` | NO | (8) |
  | `DateOfShiftOnDay` | `smallint` | NO | (0) |
  | `InTimeSaveShiftOnDay` | `smallint` | NO | (0) |
  | `OutTimeSaveShiftOnDay` | `smallint` | NO | (0) |
  | `Priority` | `smallint` | NO | (1) |
  | `LateMode` | `smallint` | NO | (3) |
  | `LateRounding` | `smallint` | NO | (1) |
  | `LateRoundingValue` | `decimal(9,2)` | NO | (1) |
  | `LateInLeadTime` | `smallint` | YES | (0) |
  | `LateOutLeadtime` | `smallint` | YES | (0) |
  | `OTMode` | `smallint` | NO | (3) |
  | `OTRounding` | `smallint` | NO | (60) |
  | `OTRoundingValue` | `decimal(9,2)` | NO | (1) |
  | `PayOnNonWorkingDay` | `decimal(9,2)` | NO | (0) |
  | `PayOnHoliday` | `decimal(9,2)` | NO | (0) |
  | `LateCountRounding` | `smallint` | NO | (1) |
  | `LateCountRoundingValue` | `decimal(9,2)` | NO | (1) |
  | `LateInCountLeadTime` | `smallint` | NO | (0) |
  | `LateOutCountLeadtime` | `smallint` | NO | (0) |
  | `IsLateDeductToWorkunit` | `smallint` | NO | (0) |
  | `PayWorkUnitOnHoliday` | `varchar(50)` | NO | ('OT2') |
  | `PayOTOnHoliday` | `varchar(50)` | NO | ('OT3') |
  | `PayWorkUnitOnNonWorkingDay` | `varchar(50)` | NO | ('OT2') |
  | `PayOTOnNonWorkingDay` | `varchar(50)` | NO | ('OT3') |
  | `InShiftTime2Start_Hour` | `smallint` | YES |  |
  | `InShiftTime2Start_Minute` | `smallint` | YES |  |
  | `InShiftTime2Start_OnDay` | `smallint` | YES |  |
  | `InShiftTime2End_Hour` | `smallint` | YES |  |
  | `InShiftTime2End_Minute` | `smallint` | YES |  |
  | `InShiftTime2End_OnDay` | `smallint` | YES |  |
  | `OutShiftTime2Start_Hour` | `smallint` | YES |  |
  | `OutShiftTime2Start_Minute` | `smallint` | YES |  |
  | `OutShiftTime2Start_OnDay` | `smallint` | YES |  |
  | `OutShiftTime2End_Hour` | `smallint` | YES |  |
  | `OutShiftTime2End_Minute` | `smallint` | YES |  |
  | `OutShiftTime2End_OnDay` | `smallint` | YES |  |
  | `IsEnabled` | `smallint` | NO | ((-1)) |
  | `OTRoundingValueMax` | `decimal(9,2)` | NO | (0) |
  | `BreakStart_Hour` | `smallint` | YES |  |
  | `BreakStart_minute` | `smallint` | YES |  |
  | `BreakStart_Onday` | `smallint` | NO | (0) |
  | `BreakEnd_Hour` | `smallint` | YES |  |
  | `BreakEnd_Minute` | `smallint` | YES |  |
  | `BreakEnd_Onday` | `smallint` | NO | (0) |
  | `BreakLateRounding` | `smallint` | NO | (1) |
  | `BreakLateRoundingValue` | `decimal(9,2)` | NO | (1) |
  | `BreakLateInLeadTime` | `smallint` | NO | (0) |
  | `BreakLateOutLeadTime` | `smallint` | NO | (0) |
  | `BreakLateCountRounding` | `smallint` | NO | (1) |
  | `BreakLateCountRoundingValue` | `smallint` | NO | (1) |
  | `BreakLateInCountLeadTime` | `smallint` | NO | (0) |
  | `BreakLateOutCountLeadTime` | `smallint` | NO | (0) |
  | `StampInTime` | `smallint` | NO | (0) |
  | `StampInTime2` | `smallint` | NO | (0) |
  | `StampOutTime2` | `smallint` | NO | (0) |
  | `StampOutTime` | `smallint` | NO | (0) |
  | `StampInTimeOT` | `smallint` | NO | (0) |
  | `StampOutTimeOT` | `smallint` | NO | (0) |
  | `PayOnHolidayOption` | `smallint` | NO | (0) |
  | `ShiftWorkUnitMode` | `smallint` | NO | (0) |
  | `ShiftWorkUnitRounding` | `smallint` | NO | (60) |
  | `ShiftWorkUnitRoundingValue` | `decimal(9,2)` | NO | (1) |
  | `ShiftWorkUnitRoundingMax` | `decimal(9,2)` | NO | (8) |
  | `IsCalOtAfterShiftWorkUnitFlying` | `smallint` | NO | ((-1)) |
  | `LateRoundingHoliday` | `smallint` | NO | (60) |
  | `LateRoundingValueHoliday` | `decimal(9,2)` | NO | (60) |
  | `LateInLeadTimeHoliday` | `smallint` | NO | (0) |
  | `LateOutLeadtimeHoliday` | `smallint` | NO | (0) |
  | `BreakLateRoundingHoliday` | `smallint` | NO | (1) |
  | `BreakLateRoundingValueHoliday` | `decimal(9,2)` | NO | (1) |
  | `BreakLateInLeadTimeHoliday` | `smallint` | NO | (0) |
  | `BreakLateOutLeadtimeHoliday` | `smallint` | NO | (0) |
  | `LateCountRoundingHoliday` | `smallint` | NO | (0) |
  | `LateCountRoundingValueHoliday` | `decimal(9,2)` | NO | (0) |
  | `LateInCountLeadTimeHoliday` | `smallint` | NO | (0) |
  | `LateOutCountLeadtimeHoliday` | `smallint` | NO | (0) |
  | `BreakLateCountRoundingHoliday` | `smallint` | NO | (0) |
  | `BreakLateCountRoundingValueHoliday` | `decimal(9,2)` | NO | (0) |
  | `BreakLateInCountLeadTimeHoliday` | `smallint` | NO | (0) |
  | `BreakLateOutCountLeadtimeHoliday` | `smallint` | NO | (0) |
  | `IsLateDeductToWorkunitHoliday` | `smallint` | NO | ((-1)) |
  | `LateCountMode` | `smallint` | NO | (3) |
  | `ShiftCode` | `varchar(5)` | YES |  |
  | `OTRoundingValueMax_Holiday` | `decimal(9,2)` | YES |  |
  | `OTRoundingValueMax_Time` | `smallint` | YES |  |
  | `OTRoundingValueMax_Time_Holiday` | `smallint` | YES |  |
  | `OTTimeOnDay` | `smallint` | YES |  |
  | `OTTime_HolidayOnDay` | `smallint` | YES |  |
  | `OTShift_Time` | `smallint` | YES | (3) |
  | `OTRoundingValueMax_Time_Minute` | `smallint` | YES |  |
  | `OTRoundingValueMax_Time_Holiday_Minute` | `smallint` | YES |  |
  | `noPayOnHoliday` | `smallint` | NO | (1) |
  | `NoPayOnHoliday1` | `smallint` | NO | (0) |
  | `TimeOT` | `smallint` | NO | (2) |
  | `Cut_OT_Time` | `smallint` | NO | (0) |
  | `Cut_OT_Minute` | `smallint` | NO | (0) |
  | `Cut_OT_TimeOnDay` | `smallint` | NO | (0) |
  | `Give_OT` | `varchar(255)` | NO | ('nOT1_5') |
  | `OT_Midday` | `smallint` | NO | (0) |
  | `OT_Evening` | `smallint` | NO | (0) |
  | `OT_Midday_Hour` | `decimal(9,2)` | NO | (0) |
  | `OT_Evening_Hour` | `decimal(9,2)` | NO | (0) |
  | `InShiftTime3Start_Hour` | `smallint` | YES |  |
  | `InShiftTime3Start_Minute` | `smallint` | YES |  |
  | `InShiftTime3Start_OnDay` | `smallint` | YES |  |
  | `InShiftTime3End_Hour` | `smallint` | YES |  |
  | `InShiftTime3End_Minute` | `smallint` | YES |  |
  | `InShiftTime3End_OnDay` | `smallint` | YES |  |
  | `OutShiftTime3Start_Hour` | `smallint` | YES |  |
  | `OutShiftTime3Start_Minute` | `smallint` | YES |  |
  | `OutShiftTime3Start_OnDay` | `smallint` | YES |  |
  | `OutShiftTime3End_Hour` | `smallint` | YES |  |
  | `OutShiftTime3End_Minute` | `smallint` | YES |  |
  | `OutShiftTime3End_OnDay` | `smallint` | YES |  |
  | `ShiftStartMiss_Hour` | `smallint` | YES |  |
  | `ShiftStartMiss_Minute` | `smallint` | YES |  |
  | `ShiftEndMiss_Hour` | `smallint` | YES |  |
  | `ShiftEndMiss_Minute` | `smallint` | YES |  |
  | `ShiftStartMiss_Onday` | `smallint` | YES |  |
  | `ShiftEndMiss_Onday` | `smallint` | YES |  |
  | `IsShiftPayExtra` | `smallint` | YES | ((0)) |
  | `ShiftPayExtra` | `decimal(9,4)` | YES |  |
  | `Site_ID` | `uniqueidentifier` | YES |  |
  | `CloseDate` | `date` | YES |  |
  | `ShiftBreakStartTask_Hour` | `smallint` | YES |  |
  | `ShiftBreakStartTask_Minute` | `smallint` | YES |  |
  | `ShiftBreakStartTask_Onday` | `smallint` | YES |  |
  | `ShiftBreakEndTask_Hour` | `smallint` | YES |  |
  | `ShiftBreakEndTask_Minute` | `smallint` | YES |  |
  | `ShiftBreakEndTask_Onday` | `smallint` | YES |  |
  | `ShiftBreakTask_Unit` | `smallint` | YES | ((1)) |
  | `ShiftStartTask_Hour` | `smallint` | YES |  |
  | `ShiftStartTask_Minute` | `smallint` | YES |  |
  | `ShiftStartTask_Onday` | `smallint` | YES |  |
  | `ShiftEndTask_Hour` | `smallint` | YES |  |
  | `ShiftEndTask_Minute` | `smallint` | YES |  |
  | `ShiftEndTask_Onday` | `smallint` | YES |  |
  | `ShiftTask_Unit` | `smallint` | YES | ((1)) |
  | `ShiftTask_OTRounding` | `decimal(9,2)` | YES | ((0)) |
  | `ShiftTask_OTRoundingValue` | `decimal(9,2)` | YES | ((0)) |
  | `ShiftCalOTType` | `smallint` | YES | ((1)) |
  | `ShiftTask_UnitRounding` | `decimal(9,2)` | YES | ((1)) |
  | `ShiftTask_UnitRoundingValue` | `decimal(9,6)` | YES | ((0.016667)) |
  | `ShiftTask_UnitRoundingMax` | `decimal(9,2)` | YES | ((1)) |
  | `ShiftTask_IsCalOtAfterShiftWorkUnitFlying` | `smallint` | YES | ((-1)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tShiftBreak</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `SHFBREAK_ID` | `uniqueidentifier` | NO |  |
  | `SHF_ID` | `uniqueidentifier` | NO |  |
  | `SeqNO` | `int` | NO | (1) |
  | `BreakStartTime` | `smalldatetime` | YES |  |
  | `BreakStartTime_OnDay` | `smallint` | YES |  |
  | `BreakEndTime` | `smalldatetime` | YES |  |
  | `BreakEndTime_OnDay` | `smallint` | YES |  |
  | `BreakValue` | `decimal(9,2)` | NO | (0) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tShiftOT</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `SHFOT_ID` | `uniqueidentifier` | NO |  |
  | `SHF_ID` | `uniqueidentifier` | NO |  |
  | `SeqNO` | `int` | NO | (1) |
  | `OTInStartTime` | `smalldatetime` | YES |  |
  | `OTInStartTime_OnDay` | `smallint` | YES |  |
  | `OTInEndTime` | `smalldatetime` | YES |  |
  | `OTInEndTime_OnDay` | `smallint` | YES |  |
  | `OTOutStartTime` | `smalldatetime` | YES |  |
  | `OTOutStartTime_OnDay` | `smallint` | YES |  |
  | `OTOutEndTime` | `smalldatetime` | YES |  |
  | `OTOutEndTime_OnDay` | `smallint` | YES |  |
  | `OTValue` | `decimal(9,2)` | NO | (0) |
  | `aOTValue` | `decimal(9,2)` | NO | (0) |
  | `bOTValue` | `decimal(9,2)` | NO | (0) |
  | `cOTValue` | `decimal(9,2)` | NO | (0) |
  | `CodeShiftOT` | `varchar(255)` | NO | ('') |

</details>

<details>
  <summary><b>📋 ตาราง <code>tShiftPattern</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `ShiftPattern_ID` | `uniqueidentifier` | NO | (newid()) |
  | `ShiftPatternCode` | `varchar(255)` | YES |  |
  | `ShiftPatternName` | `varchar(255)` | YES |  |
  | `ColorSymbol` | `int` | YES |  |
  | `CreateDateTime` | `datetime` | YES | (getdate()) |
  | `UpdateDateTime` | `datetime` | YES | (getdate()) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tWorkCalendar</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `WCD_ID` | `uniqueidentifier` | NO | (newid()) |
  | `WCDName` | `varchar(255)` | NO | ('') |
  | `CreateDateTime` | `smalldatetime` | NO | (getdate()) |
  | `ColorSymbol` | `int` | NO | (16777215) |
  | `WCDCode` | `varchar(5)` | YES | ('') |

</details>

<details>
  <summary><b>📋 ตาราง <code>tWorkCalendarDetail</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `WCD_ID` | `uniqueidentifier` | NO | (newid()) |
  | `WCDDate` | `varchar(50)` | NO |  |
  | `WCDDesc` | `varchar(50)` | YES |  |
  | `WCDType` | `varchar(10)` | NO | ('H') |

</details>

<details>
  <summary><b>📋 ตาราง <code>tAssignShift</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `DateAssign` | `varchar(8)` | NO |  |
  | `SHF_ID` | `char(50)` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `UID` | `uniqueidentifier` | YES |  |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |
  | `AppMenu` | `varchar(255)` | YES |  |
  | `UpdateDateTime` | `datetime` | YES | (getdate()) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tAssignShiftByWeekDay</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `nWeekDay` | `smallint` | NO |  |
  | `SHF_ID` | `char(50)` | YES | ('{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}') |
  | `CreateDateTime` | `datetime` | YES | (getdate()) |

</details>

---

## 7. 🌴 Leave Management (การลาและการควบคุมโควตาวันลา)

**คำอธิบาย:** ใช้เก็บบันทึกประวัติการลาพักร้อน ลาป่วย ลากิจ และโควตาคงเหลือของพนักงาน

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** สอดคล้องกับตาราง **`hr.leave_requests`** ในดีไซน์ใหม่ ที่ใช้ตรวจสอบสถานะการอนุมัติและหักยอดวันลาจากโควตาของพนักงาน

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tLeaveRequest</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `LRQ_ID` | `uniqueidentifier` | NO | (newid()) |
  | `UID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(255)` | NO |  |
  | `BeginDateLeave` | `varchar(8)` | NO |  |
  | `EndDateLeave` | `varchar(8)` | NO |  |
  | `LeaveType` | `varchar(255)` | NO |  |
  | `LeaveUnit` | `decimal(9,2)` | NO | (0) |
  | `LRQStatus` | `smallint` | NO | (0) |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |
  | `LeaveReason` | `varchar(255)` | YES |  |
  | `BeginHourLeave` | `smallint` | YES |  |
  | `BeginMinuteLeave` | `smallint` | YES |  |
  | `EndHourLeave` | `smallint` | YES |  |
  | `EndMinuteLeave` | `smallint` | YES |  |
  | `ISReqAllApprove` | `smallint` | NO |  |
  | `ReplaceFrom` | `varchar(255)` | YES |  |
  | `AckReason` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tLeaveGroup</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `LG_ID` | `uniqueidentifier` | NO | (newid()) |
  | `LeaveYear` | `varchar(4)` | NO |  |
  | `BeginDateLeave` | `varchar(8)` | NO |  |
  | `EndDateLeave` | `varchar(8)` | NO |  |
  | `LeaveType` | `varchar(50)` | NO |  |
  | `IsAllEmployee` | `int` | NO | ((0)) |
  | `PayLeave` | `int` | NO | ((0)) |
  | `CountSH` | `int` | NO | ((0)) |
  | `LeaveReason` | `nvarchar(255)` | YES |  |
  | `LeaveUnit` | `decimal(9,2)` | NO | ((0)) |
  | `BeginHourLeave` | `smallint` | YES |  |
  | `BeginMinuteLeave` | `smallint` | YES |  |
  | `EndHourLeave` | `smallint` | YES |  |
  | `EndMinuteLeave` | `smallint` | YES |  |
  | `LGStatus` | `smallint` | NO | ((0)) |
  | `StatusMsg` | `varchar(255)` | YES |  |
  | `CreatedAt` | `datetime` | NO | (getdate()) |
  | `CreatedBy` | `varchar(50)` | NO |  |
  | `UpdatedAt` | `datetime` | YES |  |
  | `UpdatedBy` | `varchar(50)` | YES |  |
  | `CancelledAt` | `datetime` | YES |  |
  | `CancelledBy` | `varchar(50)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tLeaveGroupDetail</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `ID` | `uniqueidentifier` | NO | (newid()) |
  | `LG_ID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `Status` | `smallint` | NO | ((0)) |
  | `StatusMsg` | `varchar(255)` | YES |  |
  | `CreatedAt` | `datetime` | NO | (getdate()) |
  | `CreatedBy` | `varchar(50)` | NO |  |
  | `UpdatedAt` | `datetime` | YES |  |
  | `UpdatedBy` | `varchar(50)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tAddLeaveManagement</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `DateStamp` | `varchar(8)` | NO |  |
  | `SHF_ID` | `uniqueidentifier` | YES |  |
  | `PMPeriod_ID` | `uniqueidentifier` | YES |  |
  | `PRJ_ID` | `uniqueidentifier` | YES |  |
  | `CountPay` | `varchar(50)` | YES |  |
  | `FlagWork` | `varchar(1)` | YES |  |
  | `FlagLocked` | `smallint` | YES |  |
  | `nWorkUnit` | `decimal(9,6)` | NO |  |
  | `Cal_ShiftWorkUnit` | `decimal(9,6)` | NO |  |
  | `MinLeaveStartTime` | `varchar(255)` | YES |  |
  | `MaxLeaveEndTime` | `varchar(255)` | YES |  |
  | `FlagCountSH` | `smallint` | YES |  |
  | `nSickLeave` | `decimal(9,6)` | NO |  |
  | `nPersonalLeave` | `decimal(9,6)` | NO |  |
  | `nVacation` | `decimal(9,6)` | NO |  |
  | `L01` | `decimal(9,6)` | NO |  |
  | `L02` | `decimal(9,6)` | NO |  |
  | `L03` | `decimal(9,6)` | NO |  |
  | `L04` | `decimal(9,6)` | NO |  |
  | `L05` | `decimal(9,6)` | NO |  |
  | `L06` | `decimal(9,6)` | NO |  |
  | `L07` | `decimal(9,6)` | NO |  |
  | `L08` | `decimal(9,6)` | NO |  |
  | `L09` | `decimal(9,6)` | NO |  |
  | `L10` | `decimal(9,6)` | NO |  |
  | `L11` | `decimal(9,6)` | NO |  |
  | `L12` | `decimal(9,6)` | NO |  |
  | `L13` | `decimal(9,6)` | NO |  |
  | `L14` | `decimal(9,6)` | NO |  |
  | `L15` | `decimal(9,6)` | NO |  |
  | `nSickLeave_Mins` | `int` | NO |  |
  | `nPersonalLeave_Mins` | `int` | NO |  |
  | `nVacation_Mins` | `int` | NO |  |
  | `L01_Mins` | `int` | NO |  |
  | `L02_Mins` | `int` | NO |  |
  | `L03_Mins` | `int` | NO |  |
  | `L04_Mins` | `int` | NO |  |
  | `L05_Mins` | `int` | NO |  |
  | `L06_Mins` | `int` | NO |  |
  | `L07_Mins` | `int` | NO |  |
  | `L08_Mins` | `int` | NO |  |
  | `L09_Mins` | `int` | NO |  |
  | `L10_Mins` | `int` | NO |  |
  | `L11_Mins` | `int` | NO |  |
  | `L12_Mins` | `int` | NO |  |
  | `L13_Mins` | `int` | NO |  |
  | `L14_Mins` | `int` | NO |  |
  | `L15_Mins` | `int` | NO |  |
  | `Used_nSickLeave_Year` | `varchar(4)` | YES |  |
  | `Used_nPersonalLeave_Year` | `varchar(4)` | YES |  |
  | `Used_nVacation_Year` | `varchar(4)` | YES |  |
  | `Used_L01_Year` | `varchar(4)` | YES |  |
  | `Used_L02_Year` | `varchar(4)` | YES |  |
  | `Used_L03_Year` | `varchar(4)` | YES |  |
  | `Used_L04_Year` | `varchar(4)` | YES |  |
  | `Used_L05_Year` | `varchar(4)` | YES |  |
  | `Used_L06_Year` | `varchar(4)` | YES |  |
  | `Used_L07_Year` | `varchar(4)` | YES |  |
  | `Used_L08_Year` | `varchar(4)` | YES |  |
  | `Used_L09_Year` | `varchar(4)` | YES |  |
  | `Used_L10_Year` | `varchar(4)` | YES |  |
  | `Used_L11_Year` | `varchar(4)` | YES |  |
  | `Used_L12_Year` | `varchar(4)` | YES |  |
  | `Used_L13_Year` | `varchar(4)` | YES |  |
  | `Used_L14_Year` | `varchar(4)` | YES |  |
  | `Used_L15_Year` | `varchar(4)` | YES |  |
  | `nSickLeaveCarry` | `decimal(9,6)` | NO |  |
  | `nPersonalLeaveCarry` | `decimal(9,6)` | NO |  |
  | `nVacationCarry` | `decimal(9,6)` | NO |  |
  | `L01Carry` | `decimal(9,6)` | NO |  |
  | `L02Carry` | `decimal(9,6)` | NO |  |
  | `L03Carry` | `decimal(9,6)` | NO |  |
  | `L04Carry` | `decimal(9,6)` | NO |  |
  | `L05Carry` | `decimal(9,6)` | NO |  |
  | `L06Carry` | `decimal(9,6)` | NO |  |
  | `L07Carry` | `decimal(9,6)` | NO |  |
  | `L08Carry` | `decimal(9,6)` | NO |  |
  | `L09Carry` | `decimal(9,6)` | NO |  |
  | `L10Carry` | `decimal(9,6)` | NO |  |
  | `L11Carry` | `decimal(9,6)` | NO |  |
  | `L12Carry` | `decimal(9,6)` | NO |  |
  | `L13Carry` | `decimal(9,6)` | NO |  |
  | `L14Carry` | `decimal(9,6)` | NO |  |
  | `L15Carry` | `decimal(9,6)` | NO |  |
  | `nSickLeaveCarry_Mins` | `int` | NO |  |
  | `nPersonalLeaveCarry_Mins` | `int` | NO |  |
  | `nVacationCarry_Mins` | `int` | NO |  |
  | `L01Carry_Mins` | `int` | NO |  |
  | `L02Carry_Mins` | `int` | NO |  |
  | `L03Carry_Mins` | `int` | NO |  |
  | `L04Carry_Mins` | `int` | NO |  |
  | `L05Carry_Mins` | `int` | NO |  |
  | `L06Carry_Mins` | `int` | NO |  |
  | `L07Carry_Mins` | `int` | NO |  |
  | `L08Carry_Mins` | `int` | NO |  |
  | `L09Carry_Mins` | `int` | NO |  |
  | `L10Carry_Mins` | `int` | NO |  |
  | `L11Carry_Mins` | `int` | NO |  |
  | `L12Carry_Mins` | `int` | NO |  |
  | `L13Carry_Mins` | `int` | NO |  |
  | `L14Carry_Mins` | `int` | NO |  |
  | `L15Carry_Mins` | `int` | NO |  |
  | `FlagLeave` | `varchar(50)` | YES |  |
  | `nCompensateLeave` | `decimal(9,2)` | NO |  |
  | `nCompensateLeave_Mins` | `int` | NO |  |
  | `nCompensateLeaveCarry` | `decimal(9,2)` | NO |  |
  | `nCompensateLeaveCarry_Mins` | `int` | NO |  |
  | `Used_CompensateLeave_Year` | `varchar(4)` | YES |  |
  | `JobType` | `varchar(5)` | YES |  |
  | `IsPayLeave` | `smallint` | YES |  |
  | `IsPaySickLeave` | `smallint` | NO |  |
  | `IsPayPersonalLeave` | `smallint` | NO |  |
  | `IsPayVacation` | `smallint` | NO |  |
  | `IsPayL01` | `smallint` | NO |  |
  | `IsPayL02` | `smallint` | NO |  |
  | `IsPayL03` | `smallint` | NO |  |
  | `IsPayL04` | `smallint` | NO |  |
  | `IsPayL05` | `smallint` | NO |  |
  | `IsPayL06` | `smallint` | NO |  |
  | `IsPayL07` | `smallint` | NO |  |
  | `IsPayL08` | `smallint` | NO |  |
  | `IsPayL09` | `smallint` | NO |  |
  | `IsPayL10` | `smallint` | NO |  |
  | `IsPayL11` | `smallint` | NO |  |
  | `IsPayL12` | `smallint` | NO |  |
  | `IsPayL13` | `smallint` | NO |  |
  | `IsPayL14` | `smallint` | NO |  |
  | `IsPayL15` | `smallint` | NO |  |
  | `CreateDate` | `datetime` | YES | (getdate()) |
  | `LastDate` | `datetime` | YES |  |
  | `PayrollLeave` | `smallint` | YES |  |
  | `bSickLeave` | `decimal(9,6)` | YES |  |
  | `bPersonalLeave` | `decimal(9,6)` | YES |  |
  | `bVacation` | `decimal(9,6)` | YES |  |
  | `bL01` | `decimal(9,6)` | YES |  |
  | `bL02` | `decimal(9,6)` | YES |  |
  | `bL03` | `decimal(9,6)` | YES |  |
  | `bL04` | `decimal(9,6)` | YES |  |
  | `bL05` | `decimal(9,6)` | YES |  |
  | `bL06` | `decimal(9,6)` | YES |  |
  | `bL07` | `decimal(9,6)` | YES |  |
  | `bL08` | `decimal(9,6)` | YES |  |
  | `bL09` | `decimal(9,6)` | YES |  |
  | `bL10` | `decimal(9,6)` | YES |  |
  | `bL11` | `decimal(9,6)` | YES |  |
  | `bL12` | `decimal(9,6)` | YES |  |
  | `bL13` | `decimal(9,6)` | YES |  |
  | `bL14` | `decimal(9,6)` | YES |  |
  | `bL15` | `decimal(9,6)` | YES |  |
  | `bIsPaySickLeave` | `smallint` | YES |  |
  | `bIsPayPersonalLeave` | `smallint` | YES |  |
  | `bIsPayVacation` | `smallint` | YES |  |
  | `bIsPayL01` | `smallint` | YES |  |
  | `bIsPayL02` | `smallint` | YES |  |
  | `bIsPayL03` | `smallint` | YES |  |
  | `bIsPayL04` | `smallint` | YES |  |
  | `bIsPayL05` | `smallint` | YES |  |
  | `bIsPayL06` | `smallint` | YES |  |
  | `bIsPayL07` | `smallint` | YES |  |
  | `bIsPayL08` | `smallint` | YES |  |
  | `bIsPayL09` | `smallint` | YES |  |
  | `bIsPayL10` | `smallint` | YES |  |
  | `bIsPayL11` | `smallint` | YES |  |
  | `bIsPayL12` | `smallint` | YES |  |
  | `bIsPayL13` | `smallint` | YES |  |
  | `bIsPayL14` | `smallint` | YES |  |
  | `bIsPayL15` | `smallint` | YES |  |
  | `bCountpay` | `varchar(50)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tPreset_Leave</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `LPS_ID` | `uniqueidentifier` | NO | (newid()) |
  | `LPSName` | `varchar(255)` | NO | ('<แบบลา>') |
  | `SickQuota` | `int` | NO | (0) |
  | `PersonalQuota` | `int` | NO | (0) |
  | `VacationQuota` | `int` | NO | (0) |
  | `L01Quota` | `int` | NO | (0) |
  | `L02Quota` | `int` | NO | (0) |
  | `L03Quota` | `int` | NO | (0) |
  | `L04Quota` | `int` | NO | (0) |
  | `L05Quota` | `int` | NO | (0) |
  | `L06Quota` | `int` | NO | (0) |
  | `SickPay` | `int` | NO | (0) |
  | `PersonalPay` | `int` | NO | (0) |
  | `VacationPay` | `int` | NO | (0) |
  | `L01Pay` | `int` | NO | (0) |
  | `L02Pay` | `int` | NO | (0) |
  | `L03Pay` | `int` | NO | (0) |
  | `L04Pay` | `int` | NO | (0) |
  | `L05Pay` | `int` | NO | (0) |
  | `L06Pay` | `int` | NO | (0) |
  | `SickAllowExceed` | `int` | NO | (0) |
  | `PersonalAllowExceed` | `int` | NO | (0) |
  | `VacationAllowExceed` | `int` | NO | (0) |
  | `L01AllowExceed` | `int` | NO | (0) |
  | `L02AllowExceed` | `int` | NO | (0) |
  | `L03AllowExceed` | `int` | NO | (0) |
  | `L04AllowExceed` | `int` | NO | (0) |
  | `L05AllowExceed` | `int` | NO | (0) |
  | `L06AllowExceed` | `int` | NO | (0) |

</details>

---

## 8. 💰 Payroll, Allowances & Tax (คำนวณเงินเดือน รายได้ รายหัก และภาษี)

**คำอธิบาย:** ศูนย์กลางด้านการเงินของพนักงานรายบุคคล เก็บรายละเอียดฐานเงินเดือน ค่าล่วงเวลาสะสม เบี้ยขยัน ประกันสังคม กองทุนสำรองเลี้ยงชีพ และการคำนวณภาษีสะสม

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** สอดคล้องกับตาราง **`hr.payrolls`** (สำหรับควบคุมงวดคำนวณเงินเดือนรายเดือน) และตาราง **`hr.pay_slips`** ที่ใช้เป็นรายละเอียดเก็บแจกแจงรายการเงินได้เงินหักของพนักงานแต่ละคนตามงวดจ่าย

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tPayroll</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `PMPERIOD_ID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `PRLStatus` | `smallint` | NO | (0) |
  | `nWorkUnit` | `decimal(18,4)` | NO | (0) |
  | `nLateIn` | `decimal(18,4)` | NO | (0) |
  | `nLateOut` | `decimal(18,4)` | NO | (0) |
  | `nOT1` | `decimal(18,4)` | NO | (0) |
  | `nOT1_5` | `decimal(18,4)` | NO | (0) |
  | `nOT2` | `decimal(18,4)` | NO | (0) |
  | `nOT3` | `decimal(18,4)` | NO | (0) |
  | `nHoliday` | `decimal(18,4)` | NO | (0) |
  | `nShift` | `decimal(18,4)` | NO | (0) |
  | `nIncentive` | `decimal(18,4)` | NO | (0) |
  | `P01` | `decimal(18,4)` | NO | (0) |
  | `P02` | `decimal(18,4)` | NO | (0) |
  | `P03` | `decimal(18,4)` | NO | (0) |
  | `P04` | `decimal(18,4)` | NO | (0) |
  | `P05` | `decimal(18,4)` | NO | (0) |
  | `P06` | `decimal(18,4)` | NO | (0) |
  | `P07` | `decimal(18,4)` | NO | (0) |
  | `P08` | `decimal(18,4)` | NO | (0) |
  | `P09` | `decimal(18,4)` | NO | (0) |
  | `P10` | `decimal(18,4)` | NO | (0) |
  | `CWU` | `decimal(18,4)` | NO | (0) |
  | `CLateIn` | `decimal(18,4)` | NO | (0) |
  | `CLateOut` | `decimal(18,4)` | NO | (0) |
  | `COT1` | `decimal(18,4)` | NO | (0) |
  | `COT1_5` | `decimal(18,4)` | NO | (0) |
  | `COT2` | `decimal(18,4)` | NO | (0) |
  | `COT3` | `decimal(18,4)` | NO | (0) |
  | `CHoliday` | `decimal(18,4)` | NO | (0) |
  | `CShift` | `decimal(18,4)` | NO | (0) |
  | `CIncentive` | `decimal(18,4)` | NO | (0) |
  | `CP01` | `decimal(18,4)` | NO | (0) |
  | `CP02` | `decimal(18,4)` | NO | (0) |
  | `CP03` | `decimal(18,4)` | NO | (0) |
  | `CP04` | `decimal(18,4)` | NO | (0) |
  | `CP05` | `decimal(18,4)` | NO | (0) |
  | `CP06` | `decimal(18,4)` | NO | (0) |
  | `CP07` | `decimal(18,4)` | NO | (0) |
  | `CP08` | `decimal(18,4)` | NO | (0) |
  | `CP09` | `decimal(18,4)` | NO | (0) |
  | `CP10` | `decimal(18,4)` | NO | (0) |
  | `N01` | `decimal(18,4)` | NO | (0) |
  | `N02` | `decimal(18,4)` | NO | (0) |
  | `N03` | `decimal(18,4)` | NO | (0) |
  | `N04` | `decimal(18,4)` | NO | (0) |
  | `N05` | `decimal(18,4)` | NO | (0) |
  | `N06` | `decimal(18,4)` | NO | (0) |
  | `N07` | `decimal(18,4)` | NO | (0) |
  | `N08` | `decimal(18,4)` | NO | (0) |
  | `N09` | `decimal(18,4)` | NO | (0) |
  | `N10` | `decimal(18,4)` | NO | (0) |
  | `CEXAdvance` | `decimal(18,4)` | NO | (0) |
  | `CSSOCT` | `decimal(18,4)` | NO | (0) |
  | `CSSOCT_EY` | `decimal(18,4)` | NO | (0) |
  | `CTAX` | `decimal(18,4)` | NO | (0) |
  | `CPVF` | `decimal(18,4)` | NO | (0) |
  | `CPVF_EY` | `decimal(18,4)` | NO | (0) |
  | `COutStandingBalance` | `decimal(18,4)` | NO | (0) |
  | `CPaymentCharge` | `smallint` | NO | (0) |
  | `CN01` | `decimal(18,4)` | NO | (0) |
  | `CN02` | `decimal(18,4)` | NO | (0) |
  | `CN03` | `decimal(18,4)` | NO | (0) |
  | `CN04` | `decimal(18,4)` | NO | (0) |
  | `CN05` | `decimal(18,4)` | NO | (0) |
  | `CN06` | `decimal(18,4)` | NO | (0) |
  | `CN07` | `decimal(18,4)` | NO | (0) |
  | `CN08` | `decimal(18,4)` | NO | (0) |
  | `CN09` | `decimal(18,4)` | NO | (0) |
  | `CN10` | `decimal(18,4)` | NO | (0) |
  | `TotalIncome` | `decimal(18,4)` | NO | (0) |
  | `TotalDeduction` | `decimal(18,4)` | NO | (0) |
  | `NetIncome` | `decimal(18,4)` | NO | (0) |
  | `TotalIncomeForSSOCT` | `decimal(18,4)` | NO | (0) |
  | `TotalIncomeForTAX` | `decimal(18,4)` | NO | (0) |
  | `TotalIncomeForPVF` | `decimal(18,4)` | NO | (0) |
  | `BU1` | `varchar(100)` | YES | ('') |
  | `BU2` | `varchar(100)` | YES | ('') |
  | `BU3` | `varchar(100)` | YES | ('') |
  | `BU4` | `varchar(100)` | YES |  |
  | `EmployeeType1` | `varchar(100)` | YES |  |
  | `EmployeeType2` | `varchar(100)` | YES |  |
  | `EmployeeType3` | `varchar(100)` | YES |  |
  | `WageRate` | `decimal(18,4)` | NO | (1) |
  | `LateInRate` | `decimal(18,4)` | NO | (1) |
  | `LateOutRate` | `decimal(18,4)` | NO | (1) |
  | `OT1Rate` | `decimal(18,4)` | NO | (1) |
  | `OT1_5Rate` | `decimal(18,4)` | NO | (1) |
  | `OT2Rate` | `decimal(18,4)` | NO | (1) |
  | `OT3Rate` | `decimal(18,4)` | NO | (1) |
  | `HolidayRate` | `decimal(18,4)` | NO | (0) |
  | `ShiftRate` | `decimal(18,4)` | NO | (1) |
  | `IncentiveRate` | `decimal(18,4)` | NO | (1) |
  | `P01Rate` | `decimal(18,4)` | NO | (1) |
  | `P02Rate` | `decimal(18,4)` | NO | (1) |
  | `P03Rate` | `decimal(18,4)` | NO | (1) |
  | `P04Rate` | `decimal(18,4)` | NO | (1) |
  | `P05Rate` | `decimal(18,4)` | NO | (1) |
  | `P06Rate` | `decimal(18,4)` | NO | (1) |
  | `P07Rate` | `decimal(18,4)` | NO | (1) |
  | `P08Rate` | `decimal(18,4)` | NO | (1) |
  | `P09Rate` | `decimal(18,4)` | NO | (1) |
  | `P10Rate` | `decimal(18,4)` | NO | (1) |
  | `N01Rate` | `decimal(18,4)` | NO | (1) |
  | `N02Rate` | `decimal(18,4)` | NO | (1) |
  | `N03Rate` | `decimal(18,4)` | NO | (1) |
  | `N04Rate` | `decimal(18,4)` | NO | (1) |
  | `N05Rate` | `decimal(18,4)` | NO | (1) |
  | `N06Rate` | `decimal(18,4)` | NO | (1) |
  | `N07Rate` | `decimal(18,4)` | NO | (1) |
  | `N08Rate` | `decimal(18,4)` | NO | (1) |
  | `N09Rate` | `decimal(18,4)` | NO | (1) |
  | `N10Rate` | `decimal(18,4)` | NO | (1) |
  | `BankTransferRate` | `decimal(18,4)` | NO | (0) |
  | `CashTransferRate` | `decimal(18,4)` | NO | (0) |
  | `BillWageRate` | `decimal(18,4)` | NO | (1) |
  | `BillLateInRate` | `decimal(18,4)` | NO | (0) |
  | `BillLateOutRate` | `decimal(18,4)` | NO | (0) |
  | `BillOT1Rate` | `decimal(18,4)` | NO | (1) |
  | `BillOT1_5Rate` | `decimal(18,4)` | NO | (1) |
  | `BillOT2Rate` | `decimal(18,4)` | NO | (1) |
  | `BillOT3Rate` | `decimal(18,4)` | NO | (1) |
  | `BillHolidayRate` | `decimal(18,4)` | NO | (0) |
  | `BillShiftRate` | `decimal(18,4)` | NO | (0) |
  | `BillIncentiveRate` | `decimal(18,4)` | NO | (0) |
  | `BillP01Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP02Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP03Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP04Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP05Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP06Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP07Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP08Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP09Rate` | `decimal(18,4)` | NO | (0) |
  | `BillP10Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN01Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN02Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN03Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN04Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN05Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN06Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN07Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN08Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN09Rate` | `decimal(18,4)` | NO | (0) |
  | `BillN10Rate` | `decimal(18,4)` | NO | (0) |
  | `prPaymentWay` | `smallint` | NO | (0) |
  | `PaymentWay` | `smallint` | NO | (0) |
  | `IsChangePaymentWay` | `char(1)` | NO | ('') |
  | `prAccountNO` | `varchar(20)` | YES |  |
  | `AccountNO` | `varchar(20)` | YES |  |
  | `BankName` | `varchar(100)` | YES |  |
  | `BankCode` | `varchar(100)` | YES |  |
  | `nSickLeave` | `decimal(18,4)` | NO | (0) |
  | `nPersonalLeave` | `decimal(18,4)` | NO | (0) |
  | `nVacation` | `decimal(18,4)` | NO | (0) |
  | `nAbsent` | `decimal(18,4)` | NO | (0) |
  | `T01` | `varchar(255)` | YES |  |
  | `T02` | `varchar(255)` | YES |  |
  | `T03` | `varchar(255)` | YES |  |
  | `T04` | `varchar(255)` | YES |  |
  | `T05` | `varchar(255)` | YES |  |
  | `L01` | `decimal(18,4)` | NO | (0) |
  | `L02` | `decimal(18,4)` | NO | (0) |
  | `L03` | `decimal(18,4)` | NO | (0) |
  | `L04` | `decimal(18,4)` | NO | (0) |
  | `L05` | `decimal(18,4)` | NO | (0) |
  | `L06` | `decimal(18,4)` | NO | (0) |
  | `FlagLocked` | `smallint` | NO | (0) |
  | `YTDTotalIncome` | `decimal(18,2)` | NO | (0) |
  | `YTDTotalDeduct` | `decimal(18,2)` | NO | (0) |
  | `YTDIncome` | `decimal(18,2)` | NO | (0) |
  | `YTDIncomeForSSOCT` | `decimal(18,2)` | NO | (0) |
  | `YTDIncomeForTAX` | `decimal(18,2)` | NO | (0) |
  | `YTDIncomeForPVF` | `decimal(18,2)` | NO | (0) |
  | `YTDTax` | `decimal(18,2)` | NO | (0) |
  | `YTDSSOCT` | `decimal(18,2)` | NO | (0) |
  | `YTDSSOCT_EY` | `decimal(18,4)` | NO | (0) |
  | `YTDPVF` | `decimal(18,2)` | NO | (0) |
  | `YTDPVF_EY` | `decimal(18,2)` | NO | (0) |
  | `YTDSickLeave` | `decimal(18,4)` | NO | (0) |
  | `YTDPersonalLeave` | `decimal(18,4)` | NO | (0) |
  | `YTDVacation` | `decimal(18,4)` | NO | (0) |
  | `YTDWorkUnit` | `decimal(18,4)` | NO | (0) |
  | `YTDLateIn` | `decimal(18,4)` | NO | (0) |
  | `YTDLateOut` | `decimal(18,4)` | NO | (0) |
  | `YTDAbsent` | `decimal(18,4)` | NO | (0) |
  | `YTDL01` | `decimal(18,4)` | NO | (0) |
  | `YTDL02` | `decimal(18,4)` | NO | (0) |
  | `YTDL03` | `decimal(18,4)` | NO | (0) |
  | `YTDL04` | `decimal(18,4)` | NO | (0) |
  | `YTDL05` | `decimal(18,4)` | NO | (0) |
  | `YTDL06` | `decimal(18,4)` | NO | (0) |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |
  | `TotalIncomeForPaymentWay` | `decimal(18,2)` | NO | (0) |
  | `IsEdited` | `smallint` | NO | (0) |
  | `IncomeSSOSum` | `decimal(18,4)` | YES | (0) |
  | `CSSOSum` | `decimal(18,4)` | YES | (0) |
  | `BU1_ID` | `uniqueidentifier` | YES |  |
  | `BU2_ID` | `uniqueidentifier` | YES |  |
  | `BU3_ID` | `uniqueidentifier` | YES |  |
  | `BU4_ID` | `uniqueidentifier` | YES |  |
  | `CSSOCT_MOD` | `decimal(18,4)` | NO | (0) |
  | `TotalIncomeForSSOCT_MOD` | `decimal(18,2)` | NO | (0) |
  | `YTDSSOCT_MOD` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CPVF` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CGPF` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CTSF` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CPersonalOver65` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CSpouseOver65` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CCompensate` | `decimal(18,2)` | NO | (0) |
  | `Tax91_StatusCoupleTax` | `smallint` | NO | (0) |
  | `Tax91_NUnEduChild` | `smallint` | NO | ((0)) |
  | `Tax91_NEduChild` | `smallint` | NO | ((0)) |
  | `Tax91_IDFPersonal` | `varchar(13)` | YES |  |
  | `Tax91_IDMPersonal` | `varchar(13)` | YES |  |
  | `Tax91_IDFSpouse` | `varchar(13)` | YES |  |
  | `Tax91_IDMSpouse` | `varchar(13)` | YES |  |
  | `Tax91_CHFPersonal` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CHMPersonal` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CHFSpouse` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CHMSpouse` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CLInsurance` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CRMF` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CLTE` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CInterestOnHL` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CSSF` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CPersonal` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CSpouse` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CFPersonal` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CMPersonal` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CFSpouse` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CMSpouse` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CMFEdu` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CMFSport` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CDonation` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CPVF_Over` | `decimal(18,2)` | NO | (0) |
  | `Tax91_Expense40` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CUnEduChild` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CEduChild` | `decimal(18,2)` | NO | (0) |
  | `Tax91_IncomeForTax_Forward` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CSSOCT_Forward` | `decimal(18,2)` | NO | (0) |
  | `Tax91_CTAX_Forward` | `decimal(18,2)` | NO | (0) |
  | `Tax91_Income_Forward` | `decimal(18,2)` | NO | (0) |
  | `Tax91_Deduct_Forward` | `decimal(18,2)` | NO | (0) |
  | `Tax91_NetIncome_Forward` | `decimal(18,2)` | NO | (0) |
  | `Flag_Unload` | `int` | NO | (0) |
  | `IsComputeIncentive` | `smallint` | YES | (0) |
  | `TaxYearEnd` | `decimal(18,2)` | NO | (0) |
  | `CTAX_Com` | `decimal(18,4)` | NO | (0) |
  | `nAbsentDeduct` | `decimal(18,4)` | NO | (0) |
  | `AbsentDeductRate` | `decimal(18,4)` | NO | (0) |
  | `CAbsentDeduct` | `decimal(18,4)` | NO | (0) |
  | `nLateInDeduct` | `decimal(18,4)` | NO | (0) |
  | `LateInDeductRate` | `decimal(18,4)` | NO | (0) |
  | `CLateInDeduct` | `decimal(18,4)` | NO | (0) |
  | `nLateOutDeduct` | `decimal(18,4)` | NO | (0) |
  | `LateOutDeductRate` | `decimal(18,4)` | NO | (0) |
  | `CLateOutDeduct` | `decimal(18,4)` | NO | (0) |
  | `nLeave` | `decimal(18,4)` | NO | (0) |
  | `LeaveRate` | `decimal(18,4)` | NO | (0) |
  | `CLeave` | `decimal(18,4)` | NO | (0) |
  | `YTDCP01` | `decimal(18,2)` | NO | (0) |
  | `YTDCP02` | `decimal(18,2)` | NO | (0) |
  | `YTDCP03` | `decimal(18,2)` | NO | (0) |
  | `YTDCP04` | `decimal(18,2)` | NO | (0) |
  | `YTDCP05` | `decimal(18,2)` | NO | (0) |
  | `YTDCP06` | `decimal(18,2)` | NO | (0) |
  | `YTDCP07` | `decimal(18,2)` | NO | (0) |
  | `YTDCP08` | `decimal(18,2)` | NO | (0) |
  | `YTDCP09` | `decimal(18,2)` | NO | (0) |
  | `YTDCP10` | `decimal(18,2)` | NO | (0) |
  | `YTDCN01` | `decimal(18,2)` | NO | (0) |
  | `YTDCN02` | `decimal(18,2)` | NO | (0) |
  | `YTDCN03` | `decimal(18,2)` | NO | (0) |
  | `YTDCN04` | `decimal(18,2)` | NO | (0) |
  | `YTDCN05` | `decimal(18,2)` | NO | (0) |
  | `YTDCN06` | `decimal(18,2)` | NO | (0) |
  | `YTDCN07` | `decimal(18,2)` | NO | (0) |
  | `YTDCN08` | `decimal(18,2)` | NO | (0) |
  | `YTDCN09` | `decimal(18,2)` | NO | (0) |
  | `YTDCN10` | `decimal(18,2)` | NO | (0) |
  | `Tax91_AllIncomeForTax` | `decimal(18,2)` | NO | (0) |
  | `Tax91_FixIncomeForTax` | `decimal(18,2)` | NO | (0) |
  | `Tax91_TypeCalTax` | `varchar(50)` | YES |  |
  | `Tax91_PeriodPerMonth` | `int` | NO | (0) |
  | `Tax91_AllTax` | `decimal(18,2)` | NO | (0) |
  | `Tax91_FixTaxOnly` | `decimal(18,2)` | NO | (0) |
  | `Tax91_TaxNow` | `decimal(18,2)` | NO | (0) |
  | `Tax91_YTDIncomeForTax` | `decimal(18,2)` | NO | (0) |
  | `Tax91_YTDTax` | `decimal(18,2)` | NO | (0) |
  | `Tax91_BeforeExpense` | `decimal(18,2)` | NO | (0) |
  | `Tax91_AfterExpense` | `decimal(18,2)` | NO | (0) |
  | `Tax91_NetIncomeForTax` | `decimal(18,2)` | NO | (0) |
  | `Tax91_AllIncomeForTaxPeriod` | `decimal(18,2)` | NO | (0) |
  | `Tax91_FixIncomeForTaxPeriod` | `decimal(18,2)` | NO | (0) |
  | `nLateInCount` | `decimal(18,4)` | NO | (0) |
  | `nLateOutCount` | `decimal(18,4)` | NO | (0) |
  | `CTAX_Resign` | `decimal(18,4)` | NO | (0) |
  | `TotalIncomeForTAX_Resign` | `decimal(18,2)` | NO | (0) |
  | `YTDCTAX_Resign` | `decimal(18,4)` | NO | (0) |
  | `YTDIncomeForTAX_Resign` | `decimal(18,2)` | NO | (0) |
  | `CPensionFund` | `decimal(18,4)` | NO | (0) |
  | `CCGPF` | `decimal(18,4)` | NO | (0) |
  | `CCompensate` | `decimal(18,4)` | NO | (0) |
  | `CSuperannuate` | `decimal(18,4)` | NO | (0) |
  | `CIncomePayOne` | `decimal(18,4)` | NO | (0) |
  | `Tax91_YearOnBoard` | `int` | NO | (0) |
  | `Tax91_TypeSalary` | `int` | NO | (1) |
  | `Tax91_SalaryBasic` | `decimal(18,2)` | NO | (0) |
  | `Tax91_BasicCost` | `decimal(18,2)` | NO | (0) |
  | `Tax91_TypeFirstCost` | `int` | NO | (1) |
  | `Tax91_Cr1` | `decimal(18,2)` | NO | (0) |
  | `Tax91_Cr2` | `decimal(18,2)` | NO | (0) |
  | `Tax91_TotalCr` | `decimal(18,2)` | NO | (0) |
  | `FlagCal` | `int` | NO | (0) |
  | `T06` | `varchar(255)` | YES |  |
  | `T07` | `varchar(255)` | YES |  |
  | `T08` | `varchar(255)` | YES |  |
  | `T09` | `varchar(255)` | YES |  |
  | `T10` | `varchar(255)` | YES |  |
  | `T11` | `varchar(255)` | YES |  |
  | `Tax91_CPVF_Forward` | `decimal(18,2)` | NO | ((0)) |
  | `CGPF` | `decimal(18,4)` | NO | ((0)) |
  | `TaxCalMethod` | `smallint` | NO | ((0)) |
  | `TotalIncomeForGPF` | `decimal(18,4)` | NO | ((0)) |
  | `YTDIncomeForGPF` | `decimal(18,2)` | NO | ((0)) |
  | `YTDGPF` | `decimal(18,2)` | NO | ((0)) |
  | `Tax91_CGPF_Forward` | `decimal(18,2)` | NO | ((0)) |
  | `EmployeeFlag` | `smallint` | NO | ((1)) |
  | `EMPTP1_ID` | `uniqueidentifier` | YES |  |
  | `EMPTP2_ID` | `uniqueidentifier` | YES |  |
  | `EMPTP3_ID` | `uniqueidentifier` | YES |  |
  | `YTDCWU` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCOT1` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCOT1_5` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCOT2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCOT3` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCShift` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCHoliday` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCIncentive` | `decimal(18,4)` | NO | ((0)) |
  | `PercentInPND1` | `int` | NO | ((0)) |
  | `IsFilter` | `int` | NO | ((0)) |
  | `Tax91_NDisabledCare` | `smallint` | NO | ((0)) |
  | `Tax91_CDisabledCare` | `decimal(18,2)` | NO | ((0)) |
  | `Tax91_CBuilding` | `decimal(18,2)` | NO | ((0)) |
  | `YTDTAX_com` | `decimal(18,2)` | NO | ((0)) |
  | `Tax91_CPensionInsurance` | `decimal(18,2)` | NO | ((0)) |
  | `TotalIncomeForTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `CTAX40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_IncomeForTax40_2_Forward` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_AllIncomeForTaxPeriod40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_FixIncomeForTaxPeriod40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_AllIncomeForTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_FixIncomeForTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_TypeCalTax40_2` | `varchar(50)` | YES |  |
  | `Tax91_PeriodPerMonth40_2` | `int` | NO | ((0)) |
  | `Tax91_YTDIncomeForTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_BeforeExpense40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_AfterExpense40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_NetIncomeForTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDIncomeForTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `TaxYearEnd40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_AllTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_FixTaxOnly40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CTax40_2_Forward` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_TaxNow40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_YTDTax40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CPVF_Over40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CGPF40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CPersonalOver6540_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CSpouseOver6540_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CTSF40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CCompensate40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_Expense4040_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CPersonal40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CSpouse40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CUnEduChild40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_NUnEduChild40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CEduChild40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_NEduChild40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CFPersonal40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CMPersonal40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CFSpouse40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CMSpouse40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CHFPersonal40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CHMPersonal40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CHFSpouse40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CHMSpouse40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CLInsurance40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CPVF40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CRMF40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CLTE40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CInterestOnHL40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CSSF40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CDisabledCare40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_NDisabledCare40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CBuilding40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CPensionInsurance40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CMFEdu40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CMFSport40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CDonation40_2` | `decimal(18,4)` | NO | ((0)) |
  | `L07` | `decimal(18,4)` | NO | ((0)) |
  | `L08` | `decimal(18,4)` | NO | ((0)) |
  | `L09` | `decimal(18,4)` | NO | ((0)) |
  | `L10` | `decimal(18,4)` | NO | ((0)) |
  | `L11` | `decimal(18,4)` | NO | ((0)) |
  | `L12` | `decimal(18,4)` | NO | ((0)) |
  | `L13` | `decimal(18,4)` | NO | ((0)) |
  | `L14` | `decimal(18,4)` | NO | ((0)) |
  | `L15` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL07` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL08` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL09` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL10` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL11` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL12` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL13` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL14` | `decimal(18,4)` | NO | ((0)) |
  | `YTDL15` | `decimal(18,4)` | NO | ((0)) |
  | `nPVFWorkUnit` | `decimal(18,4)` | NO | ((0)) |
  | `CWUForPVF` | `decimal(18,4)` | NO | ((0)) |
  | `EMPTT_ID` | `uniqueidentifier` | YES |  |
  | `REF01` | `varchar(255)` | YES |  |
  | `REF02` | `varchar(255)` | YES |  |
  | `REF03` | `varchar(255)` | YES |  |
  | `REF04` | `varchar(255)` | YES |  |
  | `REF05` | `varchar(255)` | YES |  |
  | `REF06` | `varchar(255)` | YES |  |
  | `REF07` | `varchar(255)` | YES |  |
  | `REF08` | `varchar(255)` | YES |  |
  | `REF09` | `varchar(255)` | YES |  |
  | `REF10` | `varchar(255)` | YES |  |
  | `EmpCode1` | `varchar(100)` | YES |  |
  | `EmpCode2` | `varchar(100)` | YES |  |
  | `EmpCode3` | `varchar(100)` | YES |  |
  | `EmpCode4` | `varchar(100)` | YES |  |
  | `OTCostCenter_ID` | `uniqueidentifier` | YES |  |
  | `EmpLevel_ID` | `uniqueidentifier` | YES |  |
  | `Site_ID` | `uniqueidentifier` | YES |  |
  | `P11` | `decimal(18,4)` | NO | ((0)) |
  | `CP11` | `decimal(18,4)` | NO | ((0)) |
  | `P11Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P12` | `decimal(18,4)` | NO | ((0)) |
  | `CP12` | `decimal(18,4)` | NO | ((0)) |
  | `P12Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P13` | `decimal(18,4)` | NO | ((0)) |
  | `CP13` | `decimal(18,4)` | NO | ((0)) |
  | `P13Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P14` | `decimal(18,4)` | NO | ((0)) |
  | `CP14` | `decimal(18,4)` | NO | ((0)) |
  | `P14Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P15` | `decimal(18,4)` | NO | ((0)) |
  | `CP15` | `decimal(18,4)` | NO | ((0)) |
  | `P15Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P16` | `decimal(18,4)` | NO | ((0)) |
  | `CP16` | `decimal(18,4)` | NO | ((0)) |
  | `P16Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P17` | `decimal(18,4)` | NO | ((0)) |
  | `CP17` | `decimal(18,4)` | NO | ((0)) |
  | `P17Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P18` | `decimal(18,4)` | NO | ((0)) |
  | `CP18` | `decimal(18,4)` | NO | ((0)) |
  | `P18Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P19` | `decimal(18,4)` | NO | ((0)) |
  | `CP19` | `decimal(18,4)` | NO | ((0)) |
  | `P19Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P20` | `decimal(18,4)` | NO | ((0)) |
  | `CP20` | `decimal(18,4)` | NO | ((0)) |
  | `P20Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P21` | `decimal(18,4)` | NO | ((0)) |
  | `CP21` | `decimal(18,4)` | NO | ((0)) |
  | `P21Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P22` | `decimal(18,4)` | NO | ((0)) |
  | `CP22` | `decimal(18,4)` | NO | ((0)) |
  | `P22Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P23` | `decimal(18,4)` | NO | ((0)) |
  | `CP23` | `decimal(18,4)` | NO | ((0)) |
  | `P23Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P24` | `decimal(18,4)` | NO | ((0)) |
  | `CP24` | `decimal(18,4)` | NO | ((0)) |
  | `P24Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P25` | `decimal(18,4)` | NO | ((0)) |
  | `CP25` | `decimal(18,4)` | NO | ((0)) |
  | `P25Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P26` | `decimal(18,4)` | NO | ((0)) |
  | `CP26` | `decimal(18,4)` | NO | ((0)) |
  | `P26Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P27` | `decimal(18,4)` | NO | ((0)) |
  | `CP27` | `decimal(18,4)` | NO | ((0)) |
  | `P27Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P28` | `decimal(18,4)` | NO | ((0)) |
  | `CP28` | `decimal(18,4)` | NO | ((0)) |
  | `P28Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P29` | `decimal(18,4)` | NO | ((0)) |
  | `CP29` | `decimal(18,4)` | NO | ((0)) |
  | `P29Rate` | `decimal(18,4)` | NO | ((1)) |
  | `P30` | `decimal(18,4)` | NO | ((0)) |
  | `CP30` | `decimal(18,4)` | NO | ((0)) |
  | `P30Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N11` | `decimal(18,4)` | NO | ((0)) |
  | `CN11` | `decimal(18,4)` | NO | ((0)) |
  | `N11Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N12` | `decimal(18,4)` | NO | ((0)) |
  | `CN12` | `decimal(18,4)` | NO | ((0)) |
  | `N12Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N13` | `decimal(18,4)` | NO | ((0)) |
  | `CN13` | `decimal(18,4)` | NO | ((0)) |
  | `N13Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N14` | `decimal(18,4)` | NO | ((0)) |
  | `CN14` | `decimal(18,4)` | NO | ((0)) |
  | `N14Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N15` | `decimal(18,4)` | NO | ((0)) |
  | `CN15` | `decimal(18,4)` | NO | ((0)) |
  | `N15Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N16` | `decimal(18,4)` | NO | ((0)) |
  | `CN16` | `decimal(18,4)` | NO | ((0)) |
  | `N16Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N17` | `decimal(18,4)` | NO | ((0)) |
  | `CN17` | `decimal(18,4)` | NO | ((0)) |
  | `N17Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N18` | `decimal(18,4)` | NO | ((0)) |
  | `CN18` | `decimal(18,4)` | NO | ((0)) |
  | `N18Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N19` | `decimal(18,4)` | NO | ((0)) |
  | `CN19` | `decimal(18,4)` | NO | ((0)) |
  | `N19Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N20` | `decimal(18,4)` | NO | ((0)) |
  | `CN20` | `decimal(18,4)` | NO | ((0)) |
  | `N20Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N21` | `decimal(18,4)` | NO | ((0)) |
  | `CN21` | `decimal(18,4)` | NO | ((0)) |
  | `N21Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N22` | `decimal(18,4)` | NO | ((0)) |
  | `CN22` | `decimal(18,4)` | NO | ((0)) |
  | `N22Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N23` | `decimal(18,4)` | NO | ((0)) |
  | `CN23` | `decimal(18,4)` | NO | ((0)) |
  | `N23Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N24` | `decimal(18,4)` | NO | ((0)) |
  | `CN24` | `decimal(18,4)` | NO | ((0)) |
  | `N24Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N25` | `decimal(18,4)` | NO | ((0)) |
  | `CN25` | `decimal(18,4)` | NO | ((0)) |
  | `N25Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N26` | `decimal(18,4)` | NO | ((0)) |
  | `CN26` | `decimal(18,4)` | NO | ((0)) |
  | `N26Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N27` | `decimal(18,4)` | NO | ((0)) |
  | `CN27` | `decimal(18,4)` | NO | ((0)) |
  | `N27Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N28` | `decimal(18,4)` | NO | ((0)) |
  | `CN28` | `decimal(18,4)` | NO | ((0)) |
  | `N28Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N29` | `decimal(18,4)` | NO | ((0)) |
  | `CN29` | `decimal(18,4)` | NO | ((0)) |
  | `N29Rate` | `decimal(18,4)` | NO | ((1)) |
  | `N30` | `decimal(18,4)` | NO | ((0)) |
  | `CN30` | `decimal(18,4)` | NO | ((0)) |
  | `N30Rate` | `decimal(18,4)` | NO | ((1)) |
  | `BillP11Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP12Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP13Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP14Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP15Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP16Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP17Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP18Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP19Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP20Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP21Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP22Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP23Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP24Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP25Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP26Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP27Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP28Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP29Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillP30Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN11Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN12Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN13Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN14Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN15Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN16Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN17Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN18Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN19Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN20Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN21Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN22Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN23Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN24Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN25Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN26Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN27Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN28Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN29Rate` | `decimal(18,4)` | NO | ((0)) |
  | `BillN30Rate` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP11` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP12` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP13` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP14` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP15` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP16` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP17` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP18` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP19` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP20` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP21` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP22` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP23` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP24` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP25` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP26` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP27` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP28` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP29` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCP30` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN11` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN12` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN13` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN14` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN15` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN16` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN17` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN18` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN19` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN20` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN21` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN22` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN23` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN24` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN25` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN26` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN27` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN28` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN29` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCN30` | `decimal(18,4)` | NO | ((0)) |
  | `SourceTaxCalMethod` | `smallint` | NO | ((1)) |
  | `TotalIncomeForTAX_WithHolding` | `decimal(18,2)` | NO | ((0)) |
  | `TotalIncomeForTAX_Com` | `decimal(18,2)` | NO | ((0)) |
  | `TotalIncomeForTAX_Percent` | `decimal(18,2)` | NO | ((0)) |
  | `CTAX_WithHolding` | `decimal(18,4)` | NO | ((0)) |
  | `CTAX_Percent` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCTAX_WithHolding` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCTAX_Com` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCTAX_Percent` | `decimal(18,4)` | NO | ((0)) |
  | `YTDIncomeForTAX_WithHolding` | `decimal(18,2)` | NO | ((0)) |
  | `YTDIncomeForTAX_Com` | `decimal(18,2)` | NO | ((0)) |
  | `YTDIncomeForTAX_Percent` | `decimal(18,2)` | NO | ((0)) |
  | `TotalIncomeForTAX_WithHolding40_2` | `decimal(18,2)` | NO | ((0)) |
  | `TotalIncomeForTAX_Com40_2` | `decimal(18,2)` | NO | ((0)) |
  | `TotalIncomeForTAX_Percent40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CTAX_WithHolding40_2` | `decimal(18,4)` | NO | ((0)) |
  | `CTAX_Com40_2` | `decimal(18,4)` | NO | ((0)) |
  | `CTAX_Percent40_2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCTAX_WithHolding40_2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCTAX_Com40_2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDCTAX_Percent40_2` | `decimal(18,4)` | NO | ((0)) |
  | `YTDIncomeForTAX_WithHolding40_2` | `decimal(18,2)` | NO | ((0)) |
  | `YTDIncomeForTAX_Com40_2` | `decimal(18,2)` | NO | ((0)) |
  | `YTDIncomeForTAX_Percent40_2` | `decimal(18,2)` | NO | ((0)) |
  | `SSOACC_ID` | `uniqueidentifier` | YES |  |
  | `CSSO_EY_Sum` | `decimal(18,4)` | YES | ((0)) |
  | `IsPeriodPayExtra` | `smallint` | YES |  |
  | `PayExtra_Rate` | `decimal(9,4)` | YES |  |
  | `CWU_BeforeExtra` | `decimal(18,4)` | YES |  |
  | `FlagExtra_Rate` | `varchar(20)` | YES |  |
  | `PayCash_MOD` | `decimal(18,4)` | YES |  |
  | `NetIncomeViaBank_MOD` | `decimal(18,4)` | YES |  |
  | `Tax91_SalaryAvg` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CCompensateOver` | `decimal(18,4)` | NO | ((0)) |
  | `IsEdit_Workunit` | `smallint` | YES | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tPayroll_Detail</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `PMPERIOD_ID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `RowID` | `uniqueidentifier` | NO | (newid()) |
  | `nWorkUnit` | `decimal(18,4)` | YES | (0) |
  | `nOT1` | `decimal(18,4)` | YES | (0) |
  | `nOT1_5` | `decimal(18,4)` | YES | (0) |
  | `nOT2` | `decimal(18,4)` | YES | (0) |
  | `nOT3` | `decimal(18,4)` | YES | (0) |
  | `WageRate` | `decimal(18,4)` | YES |  |
  | `OT1Rate` | `decimal(18,4)` | YES |  |
  | `OT1_5Rate` | `decimal(18,4)` | YES |  |
  | `OT2Rate` | `decimal(18,4)` | YES |  |
  | `OT3Rate` | `decimal(18,4)` | YES |  |
  | `CWU` | `decimal(18,4)` | YES | (0) |
  | `COT1` | `decimal(18,4)` | YES | (0) |
  | `COT1_5` | `decimal(18,4)` | YES | (0) |
  | `COT2` | `decimal(18,4)` | YES | (0) |
  | `COT3` | `decimal(18,4)` | YES | (0) |
  | `CreateDateTime` | `datetime` | YES | (getdate()) |
  | `Flag_Unload` | `int` | NO | (0) |
  | `nLeave` | `decimal(18,4)` | NO | (0) |
  | `LeaveRate` | `decimal(18,4)` | YES | (0) |
  | `CLeave` | `decimal(18,4)` | NO | (0) |
  | `nAbsentDeduct` | `decimal(18,4)` | NO | (0) |
  | `AbsentDeductRate` | `decimal(18,4)` | YES | (0) |
  | `CAbsentDeduct` | `decimal(18,4)` | NO | (0) |
  | `nLateInDeduct` | `decimal(18,4)` | NO | (0) |
  | `LateInDeductRate` | `decimal(18,4)` | YES | (0) |
  | `CLateInDeduct` | `decimal(18,4)` | NO | (0) |
  | `nLateOutDeduct` | `decimal(18,4)` | NO | (0) |
  | `LateOutDeductRate` | `decimal(18,4)` | YES | (0) |
  | `CLateOutDeduct` | `decimal(18,4)` | NO | (0) |
  | `nHoliday` | `decimal(18,4)` | NO | (0) |
  | `HolidayRate` | `decimal(18,4)` | YES | (0) |
  | `CHoliday` | `decimal(18,4)` | NO | (0) |
  | `SeqID` | `int` | NO | (0) |
  | `nP01` | `decimal(18,4)` | NO | ((0)) |
  | `P01Rate` | `decimal(18,4)` | NO | ((0)) |
  | `CP01` | `decimal(18,4)` | NO | ((0)) |
  | `nP02` | `decimal(18,4)` | NO | ((0)) |
  | `P02Rate` | `decimal(18,4)` | NO | ((0)) |
  | `CP02` | `decimal(18,4)` | NO | ((0)) |
  | `IsFilter` | `int` | NO | ((0)) |
  | `nPVFWorkUnit` | `decimal(18,4)` | NO | ((0)) |
  | `CWUForPVF` | `decimal(18,4)` | NO | ((0)) |
  | `IsPeriodPayExtra` | `smallint` | YES |  |
  | `PayExtra_Rate` | `decimal(9,4)` | YES |  |
  | `CWU_BeforeExtra` | `decimal(18,4)` | YES |  |
  | `FlagExtra_Rate` | `varchar(20)` | YES |  |
  | `IsEdit_Workunit` | `smallint` | YES | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tPayroll_Allowance</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `PMPERIOD_ID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `P01_M` | `decimal(18,4)` | NO | (0) |
  | `P02_M` | `decimal(18,4)` | NO | (0) |
  | `P03_M` | `decimal(18,4)` | NO | (0) |
  | `P04_M` | `decimal(18,4)` | NO | (0) |
  | `P05_M` | `decimal(18,4)` | NO | (0) |
  | `P06_M` | `decimal(18,4)` | NO | (0) |
  | `P07_M` | `decimal(18,4)` | NO | (0) |
  | `P08_M` | `decimal(18,4)` | NO | (0) |
  | `P09_M` | `decimal(18,4)` | NO | (0) |
  | `P10_M` | `decimal(18,4)` | NO | (0) |
  | `N01_M` | `decimal(18,4)` | NO | (0) |
  | `N02_M` | `decimal(18,4)` | NO | (0) |
  | `N03_M` | `decimal(18,4)` | NO | (0) |
  | `N04_M` | `decimal(18,4)` | NO | (0) |
  | `N05_M` | `decimal(18,4)` | NO | (0) |
  | `N06_M` | `decimal(18,4)` | NO | (0) |
  | `N07_M` | `decimal(18,4)` | NO | (0) |
  | `N08_M` | `decimal(18,4)` | NO | (0) |
  | `N09_M` | `decimal(18,4)` | NO | (0) |
  | `N10_M` | `decimal(18,4)` | NO | (0) |
  | `P01_E` | `decimal(18,4)` | NO | (0) |
  | `P02_E` | `decimal(18,4)` | NO | (0) |
  | `P03_E` | `decimal(18,4)` | NO | (0) |
  | `P04_E` | `decimal(18,4)` | NO | (0) |
  | `P05_E` | `decimal(18,4)` | NO | (0) |
  | `P06_E` | `decimal(18,4)` | NO | (0) |
  | `P07_E` | `decimal(18,4)` | NO | (0) |
  | `P08_E` | `decimal(18,4)` | NO | (0) |
  | `P09_E` | `decimal(18,4)` | NO | (0) |
  | `P10_E` | `decimal(18,4)` | NO | (0) |
  | `N01_E` | `decimal(18,4)` | NO | (0) |
  | `N02_E` | `decimal(18,4)` | NO | (0) |
  | `N03_E` | `decimal(18,4)` | NO | (0) |
  | `N04_E` | `decimal(18,4)` | NO | (0) |
  | `N05_E` | `decimal(18,4)` | NO | (0) |
  | `N06_E` | `decimal(18,4)` | NO | (0) |
  | `N07_E` | `decimal(18,4)` | NO | (0) |
  | `N08_E` | `decimal(18,4)` | NO | (0) |
  | `N09_E` | `decimal(18,4)` | NO | (0) |
  | `N10_E` | `decimal(18,4)` | NO | (0) |
  | `P01_A` | `decimal(18,4)` | NO | (0) |
  | `P02_A` | `decimal(18,4)` | NO | (0) |
  | `P03_A` | `decimal(18,4)` | NO | (0) |
  | `P04_A` | `decimal(18,4)` | NO | (0) |
  | `P05_A` | `decimal(18,4)` | NO | (0) |
  | `P06_A` | `decimal(18,4)` | NO | (0) |
  | `P07_A` | `decimal(18,4)` | NO | (0) |
  | `P08_A` | `decimal(18,4)` | NO | (0) |
  | `P09_A` | `decimal(18,4)` | NO | (0) |
  | `P10_A` | `decimal(18,4)` | NO | (0) |
  | `N01_A` | `decimal(18,4)` | NO | (0) |
  | `N02_A` | `decimal(18,4)` | NO | (0) |
  | `N03_A` | `decimal(18,4)` | NO | (0) |
  | `N04_A` | `decimal(18,4)` | NO | (0) |
  | `N05_A` | `decimal(18,4)` | NO | (0) |
  | `N06_A` | `decimal(18,4)` | NO | (0) |
  | `N07_A` | `decimal(18,4)` | NO | (0) |
  | `N08_A` | `decimal(18,4)` | NO | (0) |
  | `N09_A` | `decimal(18,4)` | NO | (0) |
  | `N10_A` | `decimal(18,4)` | NO | (0) |
  | `Flag_Unload` | `int` | NO | (0) |
  | `IsFilter` | `int` | NO | ((0)) |
  | `P11_M` | `decimal(18,4)` | NO | ((0)) |
  | `P12_M` | `decimal(18,4)` | NO | ((0)) |
  | `P13_M` | `decimal(18,4)` | NO | ((0)) |
  | `P14_M` | `decimal(18,4)` | NO | ((0)) |
  | `P15_M` | `decimal(18,4)` | NO | ((0)) |
  | `P16_M` | `decimal(18,4)` | NO | ((0)) |
  | `P17_M` | `decimal(18,4)` | NO | ((0)) |
  | `P18_M` | `decimal(18,4)` | NO | ((0)) |
  | `P19_M` | `decimal(18,4)` | NO | ((0)) |
  | `P20_M` | `decimal(18,4)` | NO | ((0)) |
  | `P21_M` | `decimal(18,4)` | NO | ((0)) |
  | `P22_M` | `decimal(18,4)` | NO | ((0)) |
  | `P23_M` | `decimal(18,4)` | NO | ((0)) |
  | `P24_M` | `decimal(18,4)` | NO | ((0)) |
  | `P25_M` | `decimal(18,4)` | NO | ((0)) |
  | `P26_M` | `decimal(18,4)` | NO | ((0)) |
  | `P27_M` | `decimal(18,4)` | NO | ((0)) |
  | `P28_M` | `decimal(18,4)` | NO | ((0)) |
  | `P29_M` | `decimal(18,4)` | NO | ((0)) |
  | `P30_M` | `decimal(18,4)` | NO | ((0)) |
  | `N11_M` | `decimal(18,4)` | NO | ((0)) |
  | `N12_M` | `decimal(18,4)` | NO | ((0)) |
  | `N13_M` | `decimal(18,4)` | NO | ((0)) |
  | `N14_M` | `decimal(18,4)` | NO | ((0)) |
  | `N15_M` | `decimal(18,4)` | NO | ((0)) |
  | `N16_M` | `decimal(18,4)` | NO | ((0)) |
  | `N17_M` | `decimal(18,4)` | NO | ((0)) |
  | `N18_M` | `decimal(18,4)` | NO | ((0)) |
  | `N19_M` | `decimal(18,4)` | NO | ((0)) |
  | `N20_M` | `decimal(18,4)` | NO | ((0)) |
  | `N21_M` | `decimal(18,4)` | NO | ((0)) |
  | `N22_M` | `decimal(18,4)` | NO | ((0)) |
  | `N23_M` | `decimal(18,4)` | NO | ((0)) |
  | `N24_M` | `decimal(18,4)` | NO | ((0)) |
  | `N25_M` | `decimal(18,4)` | NO | ((0)) |
  | `N26_M` | `decimal(18,4)` | NO | ((0)) |
  | `N27_M` | `decimal(18,4)` | NO | ((0)) |
  | `N28_M` | `decimal(18,4)` | NO | ((0)) |
  | `N29_M` | `decimal(18,4)` | NO | ((0)) |
  | `N30_M` | `decimal(18,4)` | NO | ((0)) |
  | `P11_E` | `decimal(18,4)` | NO | ((0)) |
  | `P12_E` | `decimal(18,4)` | NO | ((0)) |
  | `P13_E` | `decimal(18,4)` | NO | ((0)) |
  | `P14_E` | `decimal(18,4)` | NO | ((0)) |
  | `P15_E` | `decimal(18,4)` | NO | ((0)) |
  | `P16_E` | `decimal(18,4)` | NO | ((0)) |
  | `P17_E` | `decimal(18,4)` | NO | ((0)) |
  | `P18_E` | `decimal(18,4)` | NO | ((0)) |
  | `P19_E` | `decimal(18,4)` | NO | ((0)) |
  | `P20_E` | `decimal(18,4)` | NO | ((0)) |
  | `P21_E` | `decimal(18,4)` | NO | ((0)) |
  | `P22_E` | `decimal(18,4)` | NO | ((0)) |
  | `P23_E` | `decimal(18,4)` | NO | ((0)) |
  | `P24_E` | `decimal(18,4)` | NO | ((0)) |
  | `P25_E` | `decimal(18,4)` | NO | ((0)) |
  | `P26_E` | `decimal(18,4)` | NO | ((0)) |
  | `P27_E` | `decimal(18,4)` | NO | ((0)) |
  | `P28_E` | `decimal(18,4)` | NO | ((0)) |
  | `P29_E` | `decimal(18,4)` | NO | ((0)) |
  | `P30_E` | `decimal(18,4)` | NO | ((0)) |
  | `N11_E` | `decimal(18,4)` | NO | ((0)) |
  | `N12_E` | `decimal(18,4)` | NO | ((0)) |
  | `N13_E` | `decimal(18,4)` | NO | ((0)) |
  | `N14_E` | `decimal(18,4)` | NO | ((0)) |
  | `N15_E` | `decimal(18,4)` | NO | ((0)) |
  | `N16_E` | `decimal(18,4)` | NO | ((0)) |
  | `N17_E` | `decimal(18,4)` | NO | ((0)) |
  | `N18_E` | `decimal(18,4)` | NO | ((0)) |
  | `N19_E` | `decimal(18,4)` | NO | ((0)) |
  | `N20_E` | `decimal(18,4)` | NO | ((0)) |
  | `N21_E` | `decimal(18,4)` | NO | ((0)) |
  | `N22_E` | `decimal(18,4)` | NO | ((0)) |
  | `N23_E` | `decimal(18,4)` | NO | ((0)) |
  | `N24_E` | `decimal(18,4)` | NO | ((0)) |
  | `N25_E` | `decimal(18,4)` | NO | ((0)) |
  | `N26_E` | `decimal(18,4)` | NO | ((0)) |
  | `N27_E` | `decimal(18,4)` | NO | ((0)) |
  | `N28_E` | `decimal(18,4)` | NO | ((0)) |
  | `N29_E` | `decimal(18,4)` | NO | ((0)) |
  | `N30_E` | `decimal(18,4)` | NO | ((0)) |
  | `P11_A` | `decimal(18,4)` | NO | ((0)) |
  | `P12_A` | `decimal(18,4)` | NO | ((0)) |
  | `P13_A` | `decimal(18,4)` | NO | ((0)) |
  | `P14_A` | `decimal(18,4)` | NO | ((0)) |
  | `P15_A` | `decimal(18,4)` | NO | ((0)) |
  | `P16_A` | `decimal(18,4)` | NO | ((0)) |
  | `P17_A` | `decimal(18,4)` | NO | ((0)) |
  | `P18_A` | `decimal(18,4)` | NO | ((0)) |
  | `P19_A` | `decimal(18,4)` | NO | ((0)) |
  | `P20_A` | `decimal(18,4)` | NO | ((0)) |
  | `P21_A` | `decimal(18,4)` | NO | ((0)) |
  | `P22_A` | `decimal(18,4)` | NO | ((0)) |
  | `P23_A` | `decimal(18,4)` | NO | ((0)) |
  | `P24_A` | `decimal(18,4)` | NO | ((0)) |
  | `P25_A` | `decimal(18,4)` | NO | ((0)) |
  | `P26_A` | `decimal(18,4)` | NO | ((0)) |
  | `P27_A` | `decimal(18,4)` | NO | ((0)) |
  | `P28_A` | `decimal(18,4)` | NO | ((0)) |
  | `P29_A` | `decimal(18,4)` | NO | ((0)) |
  | `P30_A` | `decimal(18,4)` | NO | ((0)) |
  | `N11_A` | `decimal(18,4)` | NO | ((0)) |
  | `N12_A` | `decimal(18,4)` | NO | ((0)) |
  | `N13_A` | `decimal(18,4)` | NO | ((0)) |
  | `N14_A` | `decimal(18,4)` | NO | ((0)) |
  | `N15_A` | `decimal(18,4)` | NO | ((0)) |
  | `N16_A` | `decimal(18,4)` | NO | ((0)) |
  | `N17_A` | `decimal(18,4)` | NO | ((0)) |
  | `N18_A` | `decimal(18,4)` | NO | ((0)) |
  | `N19_A` | `decimal(18,4)` | NO | ((0)) |
  | `N20_A` | `decimal(18,4)` | NO | ((0)) |
  | `N21_A` | `decimal(18,4)` | NO | ((0)) |
  | `N22_A` | `decimal(18,4)` | NO | ((0)) |
  | `N23_A` | `decimal(18,4)` | NO | ((0)) |
  | `N24_A` | `decimal(18,4)` | NO | ((0)) |
  | `N25_A` | `decimal(18,4)` | NO | ((0)) |
  | `N26_A` | `decimal(18,4)` | NO | ((0)) |
  | `N27_A` | `decimal(18,4)` | NO | ((0)) |
  | `N28_A` | `decimal(18,4)` | NO | ((0)) |
  | `N29_A` | `decimal(18,4)` | NO | ((0)) |
  | `N30_A` | `decimal(18,4)` | NO | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tPayroll_Welfare</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `PMPeriod_ID` | `uniqueidentifier` | NO |  |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `TotalIncomeForWelfare` | `decimal(18,4)` | YES | ((0)) |
  | `CWelfare` | `decimal(18,4)` | YES | ((0)) |
  | `CWelfare_EY` | `decimal(18,4)` | NO | ((0)) |
  | `WelfareFund_Emp_Rate` | `decimal(9,2)` | NO | ((0)) |
  | `WelfareFund_Comp_Rate` | `decimal(9,2)` | NO | ((0)) |
  | `IsCalWelfare_Fund` | `smallint` | NO | ((1)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tPayroll_Tax</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `PMPeriod_ID` | `uniqueidentifier` | NO |  |
  | `NTotalChild` | `int` | NO |  |
  | `CTotalChild` | `decimal(12,4)` | NO |  |
  | `NTotalChild2` | `smallint` | YES |  |
  | `CTotalChild2` | `decimal(12,4)` | YES |  |
  | `NTotalChild1` | `smallint` | YES |  |
  | `CTotalChild1` | `decimal(12,4)` | YES |  |
  | `CSuperSaveingsFund` | `decimal(18,2)` | NO | ((0)) |
  | `CNationalSavingsFund` | `decimal(18,2)` | NO | ((0)) |
  | `CSelfHealthInsurance` | `decimal(18,2)` | NO | ((0)) |
  | `CPersonalDisabled` | `decimal(18,2)` | NO | ((0)) |
  | `CChildbirthExpenses` | `decimal(18,2)` | NO | ((0)) |
  | `CChargeDebit` | `decimal(18,2)` | NO | ((0)) |
  | `CDonationPolitical` | `decimal(18,2)` | NO | ((0)) |
  | `COtherDeduction` | `decimal(18,2)` | NO | ((0)) |
  | `CSuperSaveingsFund40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CNationalSavingsFund40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CSelfHealthInsurance40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CPersonalDisabled40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CChildbirthExpenses40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CChargeDebit40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CDonationPolitical40_2` | `decimal(18,2)` | NO | ((0)) |
  | `COtherDeduction40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CCompensate_ForTax` | `decimal(18,4)` | YES |  |
  | `CCompensate_CalTax` | `decimal(18,4)` | YES |  |
  | `CTotalIncomeResign_ForTax` | `decimal(18,4)` | YES |  |
  | `CTesg` | `decimal(18,2)` | NO | ((0)) |
  | `CTesg40_2` | `decimal(18,2)` | NO | ((0)) |
  | `Tax91_FixIncomeForTaxSpecialPeriod` | `decimal(18,2)` | NO | ((0)) |
  | `Tax91_FixIncomeForTaxSpecialPeriod40_2` | `decimal(18,2)` | NO | ((0)) |
  | `CPersonalDeduct40_2` | `decimal(18,4)` | NO | ((0)) |
  | `Tax91_CCompensateOver40_2` | `decimal(18,4)` | NO | ((0)) |
  | `CPVF40_2` | `decimal(18,4)` | NO | ((0)) |
  | `CPVF402_EY` | `decimal(18,4)` | NO | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tLoan</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `LOAN_ID` | `uniqueidentifier` | NO | (newid()) |
  | `LoanDocNo` | `varchar(50)` | YES |  |
  | `LoanDate` | `smalldatetime` | NO | (getdate()) |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `PrincipalAmount` | `decimal(9,2)` | NO | (0) |
  | `InterestType` | `smallint` | NO | (0) |
  | `InterestRate` | `decimal(9,2)` | NO | (0) |
  | `InterestFixAmount` | `decimal(9,2)` | NO | (0) |
  | `NoOfPeriod` | `smallint` | NO | (1) |
  | `InstallmentAmount` | `decimal(9,2)` | NO | (0) |
  | `ReceiveType` | `smallint` | NO |  |
  | `ReceiveFromPMPeriod` | `uniqueidentifier` | YES |  |
  | `PaymentType` | `smallint` | NO | (0) |
  | `PaymenToFirstPeriod` | `uniqueidentifier` | YES |  |
  | `LoanStatus` | `smallint` | NO | (0) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tCashAdvance</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `CashAdv_ID` | `uniqueidentifier` | NO | (newid()) |
  | `PMPeriod_ID` | `uniqueidentifier` | YES |  |
  | `EmployeeCode` | `varchar(50)` | YES |  |
  | `Amount` | `decimal(18,2)` | NO | (0) |
  | `FlagCashType` | `smallint` | NO | ((0)) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tReim</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `REIM_ID` | `uniqueidentifier` | NO | (newid()) |
  | `REIM_TYPE_ID` | `uniqueidentifier` | NO |  |
  | `ReimDocNo` | `varchar(50)` | YES |  |
  | `ReimDate` | `smalldatetime` | NO | (getdate()) |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `ReimAmount` | `decimal(9,2)` | NO | (0) |
  | `PaymentType` | `smallint` | NO | (0) |
  | `PaymentDate` | `smalldatetime` | YES |  |
  | `PaymentPMPeriod_ID` | `uniqueidentifier` | YES |  |
  | `PostToField` | `varchar(50)` | NO |  |
  | `ReimStatus` | `smallint` | NO | (0) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tTax</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `ID` | `smallint` | NO |  |
  | `MinSalary` | `money` | YES |  |
  | `MaxSalary` | `money` | YES |  |
  | `Salary` | `money` | YES |  |
  | `Tax` | `decimal(18,2)` | YES |  |
  | `MinSalary_Other` | `money` | YES | (0) |
  | `MaxSalary_Other` | `money` | YES | (0) |
  | `Salary_Other` | `money` | YES | (0) |
  | `TaxOther` | `decimal(18,2)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tTaxRate</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `id` | `smallint` | NO |  |
  | `info` | `varchar(255)` | NO |  |
  | `Rate1` | `decimal(18,2)` | YES | (0) |
  | `Rate2` | `decimal(18,2)` | YES | (0) |
  | `Rate3` | `decimal(18,2)` | YES | (0) |
  | `Rate4` | `decimal(18,2)` | YES |  |
  | `RateMin` | `decimal(18,2)` | YES |  |
  | `RateMax` | `decimal(18,2)` | YES |  |
  | `RateSeq` | `smallint` | YES |  |
  | `FieldActive` | `smallint` | YES |  |
  | `FieldColor` | `varchar(20)` | YES |  |
  | `RateGroup1` | `varchar(20)` | YES |  |
  | `RateGroup2` | `varchar(20)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSSO_Account</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `CPN_ID` | `uniqueidentifier` | NO |  |
  | `SSOACC_ID` | `uniqueidentifier` | NO | (newid()) |
  | `BranchName` | `varchar(255)` | NO | ('') |
  | `SSOBranchNo` | `varchar(6)` | NO |  |
  | `TAXBranchNo` | `varchar(20)` | NO | ('') |
  | `SendName` | `varchar(255)` | NO | ('') |
  | `SendTitle` | `varchar(255)` | NO | ('') |
  | `BranchAddress` | `varchar(255)` | NO | ('') |

</details>

---

## 9. ✅ Workflow & Approval Engine (ระบบอนุมัติและเดินเอกสาร)

**คำอธิบาย:** ระบบควบคุมเส้นทางการอนุมัติเอกสารคำขอต่าง ๆ ในองค์กรตามระดับสายบังคับบัญชา

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** โครงสร้างคำร้องขอ OT และวันลาจะถูกยื่นตรงเข้าสู่ **`hr.leave_requests`** และ **`hr.ot_requests`** โดยกระบวนการเดินสเตปการอนุมัติในระบบใหม่จะใช้โมดูล Approver/Manager ที่มีอยู่ใน `hr.employments.organization_unit_id` หรือ `identity.user_role_assignments` เป็นสายอ้างอิง

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tRequest</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `RequestID` | `uniqueidentifier` | NO |  |
  | `RuleID` | `uniqueidentifier` | YES |  |
  | `EmpRequestID` | `varchar(50)` | YES |  |
  | `ReqStatus` | `smallint` | YES |  |
  | `StartDate` | `datetime` | YES |  |
  | `CC` | `varchar(2000)` | YES |  |
  | `VC01` | `varchar(255)` | YES |  |
  | `VC02` | `varchar(255)` | YES |  |
  | `VC03` | `varchar(2000)` | YES |  |
  | `VC04` | `varchar(255)` | YES |  |
  | `VC05` | `varchar(255)` | YES |  |
  | `VC06` | `varchar(255)` | YES |  |
  | `VC07` | `varchar(255)` | YES |  |
  | `VC08` | `varchar(255)` | YES |  |
  | `VC09` | `varchar(255)` | YES |  |
  | `VC10` | `varchar(255)` | YES |  |
  | `D01` | `decimal(10,2)` | YES |  |
  | `D02` | `decimal(10,2)` | YES |  |
  | `D03` | `decimal(10,2)` | YES |  |
  | `D04` | `decimal(10,2)` | YES |  |
  | `D05` | `decimal(10,2)` | YES |  |
  | `D06` | `decimal(10,2)` | YES |  |
  | `D07` | `decimal(10,2)` | YES |  |
  | `D08` | `decimal(10,2)` | YES |  |
  | `D09` | `decimal(10,2)` | YES |  |
  | `D10` | `decimal(10,2)` | YES |  |
  | `RequestTypeID` | `uniqueidentifier` | YES |  |
  | `CurrentLV` | `smallint` | YES |  |
  | `SystemType` | `varchar(50)` | YES |  |
  | `D11` | `decimal(10,2)` | YES |  |
  | `D12` | `decimal(10,2)` | YES |  |
  | `D13` | `decimal(10,2)` | YES |  |
  | `D14` | `decimal(10,2)` | YES |  |
  | `D15` | `decimal(10,2)` | YES |  |
  | `D16` | `decimal(10,2)` | YES |  |
  | `RequestNo` | `varchar(30)` | YES |  |
  | `CreateDateTime` | `datetime` | YES | (getdate()) |
  | `VC11` | `varchar(2000)` | YES | ('') |
  | `VC12` | `varchar(255)` | NO | ('') |
  | `VC13` | `varchar(255)` | NO | ('') |
  | `VC14` | `varchar(255)` | NO | ('') |
  | `VC15` | `varchar(255)` | NO | ('') |
  | `VC16` | `varchar(255)` | NO | ('') |
  | `Comment` | `varchar(2000)` | YES |  |
  | `UID` | `varchar(255)` | YES |  |
  | `FinishBy` | `varchar(255)` | YES |  |
  | `GroupReq` | `varchar(2000)` | NO | ('') |
  | `GroupNo` | `varchar(30)` | NO | ('') |
  | `ManRequestID` | `varchar(50)` | YES |  |
  | `Other1_ID` | `uniqueidentifier` | YES |  |
  | `Other2_ID` | `uniqueidentifier` | YES |  |
  | `Other3_ID` | `uniqueidentifier` | YES |  |
  | `Other4_ID` | `uniqueidentifier` | YES |  |
  | `Other5_ID` | `uniqueidentifier` | YES |  |
  | `CostCenter_ID` | `uniqueidentifier` | YES |  |
  | `StatusRetro` | `int` | NO | ((0)) |
  | `IsRetro1` | `int` | NO | ((0)) |
  | `IsRetro2` | `int` | NO | ((0)) |
  | `IsRetro3` | `int` | NO | ((0)) |
  | `SHF_ID` | `uniqueidentifier` | YES |  |
  | `Quota_LeaveYear` | `varchar(4)` | YES |  |
  | `IsApproveClaim` | `smallint` | NO | ((0)) |
  | `DeductionType` | `int` | YES | ((0)) |
  | `sHM_Define` | `varchar(50)` | YES | ('00:00') |
  | `sHM_Deduct` | `varchar(50)` | YES | ('00:00') |

</details>

<details>
  <summary><b>📋 ตาราง <code>tRequestType</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `RequestTypeID` | `uniqueidentifier` | NO |  |
  | `RequestSystemID` | `uniqueidentifier` | YES |  |
  | `Title` | `varchar(255)` | YES |  |
  | `Caption` | `varchar(255)` | NO |  |
  | `SEQ` | `int` | YES |  |
  | `Color` | `varchar(6)` | YES |  |
  | `Including` | `int` | NO | ((0)) |
  | `PaymentType` | `int` | NO | ((1)) |
  | `MaxPay` | `varchar(10)` | NO | ('') |
  | `LeaveDesc` | `varchar(255)` | YES |  |
  | `ExpireCarry` | `varchar(255)` | NO | ('') |
  | `MaxCarry` | `int` | NO | ((0)) |
  | `YTDCarry` | `int` | NO | ((0)) |
  | `IsFixQuota` | `int` | NO | ((0)) |
  | `DefaultQuota` | `decimal(18,4)` | NO | ((0)) |
  | `ReasonOption` | `varchar(2)` | YES |  |
  | `AttachFile` | `varchar(2)` | YES | ((0)) |
  | `DayRequest` | `int` | NO | ((0)) |
  | `DateExpireCarry` | `smallint` | NO | ((0)) |
  | `MonthExpireCarry` | `smallint` | NO | ((0)) |
  | `IsGender` | `int` | YES | ((0)) |
  | `MinHourLeave` | `int` | YES | ((0)) |
  | `MinMinuteLeave` | `int` | YES | ((0)) |
  | `RequireAttachDate` | `int` | NO | ((0)) |
  | `PayRate` | `decimal(9,2)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tFlow</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `FlowID` | `uniqueidentifier` | NO |  |
  | `Title` | `varchar(50)` | NO |  |
  | `RequestSystemID` | `uniqueidentifier` | YES |  |
  | `Description` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tFlowPath</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `FlowPathID` | `uniqueidentifier` | NO |  |
  | `RuleID` | `uniqueidentifier` | NO |  |
  | `TimeOut` | `smallint` | YES |  |
  | `IsAnd` | `smallint` | YES |  |
  | `TimeOutType` | `smallint` | YES |  |
  | `LV` | `smallint` | YES |  |
  | `IsFinishPath` | `smallint` | YES |  |
  | `VC01` | `varchar(255)` | YES |  |
  | `VC02` | `varchar(255)` | YES |  |
  | `VC03` | `varchar(255)` | YES |  |
  | `VC04` | `varchar(255)` | YES |  |
  | `VC05` | `varchar(255)` | YES |  |
  | `D01` | `decimal(10,2)` | YES |  |
  | `D02` | `decimal(10,2)` | YES |  |
  | `D03` | `decimal(10,2)` | YES |  |
  | `D04` | `decimal(10,2)` | YES |  |
  | `D05` | `decimal(10,2)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSystemFlow</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `SysID` | `varchar(50)` | NO |  |
  | `RequestType` | `varchar(255)` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tApproverGroup</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `APPGID` | `uniqueidentifier` | NO |  |
  | `APPGTitle` | `varchar(255)` | NO |  |
  | `RequestSystemID` | `uniqueidentifier` | YES |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tApproverList</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `APPLID` | `uniqueidentifier` | NO |  |
  | `EmployeeID` | `varchar(50)` | YES |  |
  | `RequestSystemID` | `uniqueidentifier` | YES |  |
  | `IsEnable` | `smallint` | NO | ((1)) |
  | `IsDailyMail` | `int` | NO | ((0)) |
  | `DelegateApprovedStatus` | `int` | NO | ((0)) |
  | `EmpDelegateApp` | `varchar(50)` | YES |  |
  | `EmployeeCode_Before` | `varchar(50)` | YES |  |
  | `UpdateDateTime` | `datetime` | YES | (getdate()) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tSelectApprover</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `FlowPathID` | `uniqueidentifier` | YES |  |
  | `APPLID` | `uniqueidentifier` | YES |  |
  | `GetMail` | `smallint` | NO | ((1)) |
  | `SelectApproverID` | `int` | NO |  |

</details>

<details>
  <summary><b>📋 ตาราง <code>tWF_Record</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `Record_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EmployeeCode` | `varchar(50)` | YES |  |
  | `WF_Date` | `varchar(50)` | YES |  |
  | `WF_Type` | `varchar(50)` | YES |  |
  | `WF_TypeName` | `varchar(255)` | YES |  |
  | `Unit` | `decimal(18,2)` | YES |  |
  | `Note` | `varchar(255)` | YES |  |

</details>

---

## 10. 🗂️ System Audit Logs (บันทึกประวัติการเปลี่ยนแปลงข้อมูล)

**คำอธิบาย:** ใช้เก็บบันทึกประวัติเพื่อการตรวจสอบความปลอดภัยย้อนหลังในทุกส่วนของข้อมูลพนักงานและเงินเดือน

> 📌 **เปรียบเทียบระบบใหม่ (Staffo mapping):** ระบบใหม่จะรวมศูนย์บันทึกประวัติทุกอย่างเก็บในตารางเดียวคือ **`identity.audit_logs`** ซึ่งเก็บข้อมูลในลักษณะโครงสร้าง JSONB (`before_data` และ `after_data`) เพื่อความยืดหยุ่นในการจัดเก็บโครงสร้างข้อมูลต่างชนิดกัน

### ตารางในหมวดนี้:

<details>
  <summary><b>📋 ตาราง <code>tLOG_Employee</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | *ไม่พบข้อมูลคอลัมน์ในไฟล์ metadata* | | | |

</details>

<details>
  <summary><b>📋 ตาราง <code>tLOG_Payroll</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | `LOG_ID` | `uniqueidentifier` | NO | (newid()) |
  | `EmployeeCode` | `varchar(50)` | NO |  |
  | `PMPeriod_ID` | `uniqueidentifier` | NO |  |
  | `FieldName` | `varchar(50)` | YES |  |
  | `PreviousValue` | `varchar(255)` | YES |  |
  | `NewValue` | `varchar(255)` | YES |  |
  | `UID` | `uniqueidentifier` | YES |  |
  | `CreateDateTime` | `datetime` | NO | (getdate()) |

</details>

<details>
  <summary><b>📋 ตาราง <code>tLOG_TimeInout</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | *ไม่พบข้อมูลคอลัมน์ในไฟล์ metadata* | | | |

</details>

<details>
  <summary><b>📋 ตาราง <code>tLOG_Delete_Employee</code> (คลิกเพื่อแสดงคอลัมน์ทั้งหมด)</b></summary>

  | Column Name | Data Type | Nullable | Default Value |
  |---|---|---|---|
  | *ไม่พบข้อมูลคอลัมน์ในไฟล์ metadata* | | | |

</details>

---

