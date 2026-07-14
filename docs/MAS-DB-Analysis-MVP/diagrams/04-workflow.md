# Workflow

Request, rule, flow, stage, approver, and manager metadata.

```mermaid
erDiagram
    dbo_tRequestSystem ||--o{ dbo_tRequestType : "RequestSystemID"
    dbo_tRequestSystem ||--o{ dbo_tFlow : "RequestSystemID"
    dbo_tRequestType ||--o{ dbo_tEmployeeLevel_LeaveType : "RequestTypeID"
    dbo_tRule ||--o{ dbo_tRequest : "RuleID"
    dbo_tRule ||--o{ dbo_tFlowPath : "RuleID"
    dbo_tRule ||--o{ dbo_tCCList : "RuleID"
    dbo_tRule ||--o{ dbo_tCondition : "RuleID"
    dbo_tRequest ||--o{ dbo_tStage : "ReqID -> RequestID"
    dbo_tEmployee ||--o{ dbo_tApproverList : "EmployeeID -> EmployeeCode"
    dbo_tApproverList ||--o{ dbo_tSelectApprover : "APPLID"
    dbo_tFlowPath ||--o{ dbo_tSelectApprover : "FlowPathID"
    dbo_tApproverGroup ||--o{ dbo_tUseList : "APPGID"
    dbo_tGroup ||--o{ dbo_tUse_Flow : "GroupID"
    dbo_tGroup ||--o{ dbo_tManager : "GroupID"
    dbo_tEmployee ||--o{ dbo_tManager_Delegated : "EmployeeCode"

    dbo_tRequest {
      uniqueidentifier RequestID PK
      uniqueidentifier RuleID FK
    }
    dbo_tStage {
      uniqueidentifier StageID PK
      uniqueidentifier ReqID FK
    }
    dbo_tRule {
      uniqueidentifier RuleID PK
    }
```

## Purpose

Document the declared workflow and approval graph.

## Main Tables

- `dbo.tRequestSystem`
- `dbo.tRequestType`
- `dbo.tRule`
- `dbo.tRequest`
- `dbo.tStage`
- `dbo.tFlow`
- `dbo.tFlowPath`
- `dbo.tApproverList`
- `dbo.tSelectApprover`

## Key Relationships

- `tRequest.RuleID -> tRule.RuleID`
- `tStage.ReqID -> tRequest.RequestID`
- `tFlowPath.RuleID -> tRule.RuleID`
- `tSelectApprover.APPLID -> tApproverList.APPLID`
- `tSelectApprover.FlowPathID -> tFlowPath.FlowPathID`

## Business Flow

```text
Request system/type
  -> rule
  -> request
  -> stage
  -> approver selection
```

## Known Issues

- Workflow has better FK coverage than most domains, but requester/approver employee columns need column-level validation.
- Manager and delegated-manager relationships are present but should be checked against active request data.
- Some delete/update rules differ across workflow FKs.
