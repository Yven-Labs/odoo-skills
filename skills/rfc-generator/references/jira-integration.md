# Atlassian MCP Integration Guide — rfc-generator

Technical reference for creating Jira artifacts from the rfc-generator using the Atlassian MCP. Behavioral instructions (confirmation flow, idempotency, step order) are defined in `SKILL.md`.

---

## Prerequisites

Verify that the Atlassian MCP is available before initiating any write operation:

```
mcp__atlassian__atlassianUserInfo
  → Responds with user data: MCP configured ✅
  → Authentication error or tool not found: MCP not available ❌
```

If MCP is not available, inform the user and deliver the RFC as Markdown:

> *"The Atlassian MCP is not configured in this environment. The RFC is available as a Markdown document for manual upload to Jira."*

---

## RFC → Jira Field Mapping

### Epic

| RFC Field | Jira Field | Type | Notes |
|---|---|---|---|
| Epic Title | `summary` | String | e.g. `"Maintenance Contract Management Module"` |
| Epic technical description | `description` | String | Text from the **Description** section of the Epic in the RFC |
| — | `issuetype.name` | String | Always `"Epic"` |
| — | `project.key` | String | PROJECT_KEY resolved in SKILL.md Step 2 |

### Story (Technical RFC)

| RFC Field | Jira Field | Type | Notes |
|---|---|---|---|
| Story Title | `summary` | String | e.g. `"T001: Data Architecture and Base Security"` |
| Acceptance Criteria + Sub-tasks | `description` | String (Markdown) | Include Gherkin text and the sub-task list |
| Complexity Low/Medium/High | `priority.name` | String | `"Low"` / `"Medium"` / `"High"` |
| — | `issuetype.name` | String | Always `"Story"` |
| — | `project.key` | String | Same PROJECT_KEY as Epic |
| Epic ID | `parent.id` | String | Numeric ID returned when creating the Epic (see § Creation Order) |

> **Note on Epic Link**: In standard Jira Cloud, Stories are linked to the Epic via the `parent` field. In legacy Jira Server or Data Center instances, `customfield_10014` (the "Epic Link" field) may be used instead. Verify the exact field ID of your instance using the tool described in § Verify Field IDs.

---

## Creation Order (Mandatory)

```
1. Create the Epic
   └─ mcp__atlassian__createJiraIssue (issuetype: "Epic")
   └─ Save the "id" field from the returned object → epic_id

2. Create Stories in order T001 → T002 → T003 → T004
   └─ mcp__atlassian__createJiraIssue (issuetype: "Story")
   └─ Include parent.id = epic_id to link each Story to the Epic

3. (Optional) Create Sub-tasks if the user requests it
   └─ mcp__atlassian__createJiraIssue (issuetype: "Sub-task")
   └─ Include parent.id = story_id of the corresponding Story
```

---

## Example Payload — Create Epic

```json
{
  "projectKey": "OSK",
  "summary": "Maintenance Contract Management Module",
  "description": "Technical epic to implement the maintenance_contract module in Odoo 17.0 Enterprise. Covers data architecture, role-based security, Odoo views, business logic (state lifecycle, automatic alerts), and TransactionCase test suite.",
  "issuetype": {
    "name": "Epic"
  }
}
```

Call: `mcp__atlassian__createJiraIssue` with the above fields.
Expected result: object with field `"id"` (e.g. `"10042"`) — this is the `epic_id` for the next step.

---

## Example Payload — Create Story Linked to Epic

```json
{
  "projectKey": "OSK",
  "summary": "T001: Data Architecture and Base Security",
  "description": "**PRD Requirement:** RF-01, RF-02\n**Dependencies:** None (mandatory starting point)\n**Complexity:** Medium\n\n**Acceptance Criteria:**\n- *Given* I am the administrator, *When* I install the module with `odoo-bin -i maintenance_contract`, *Then* the `maintenance_contract` table is created in the DB without errors.\n- *Given* I am a Service Technician, *When* I access the module, *Then* I only see contracts assigned to my user.\n\n**Sub-tasks:**\n- [ ] `models/maintenance_contract.py` — Main model with states and fields\n- [ ] `security/groups.xml` — Technician and Manager groups\n- [ ] `security/ir.model.access.csv` — CRUD permissions per group\n- [ ] `security/ir_rule.xml` — Record rule by responsible technician",
  "issuetype": {
    "name": "Story"
  },
  "parent": {
    "id": "10042"
  },
  "priority": {
    "name": "High"
  }
}
```

---

## Verify Field IDs for Your Instance

If the `parent` field does not work to link Epic → Story in your Jira instance, run:

```
mcp__atlassian__getJiraIssueTypeMetaWithFields
  projectKey: "[PROJECT_KEY]"
  issueType: "Story"
```

Search the result for the `Epic Link` or `Parent` field to obtain the correct `fieldId` (`customfield_XXXXX`). Replace `parent.id` with `customfield_XXXXX: "[epic_id]"` in the payloads.

---

## JQL Search for Idempotency

Before creating an Epic, verify whether one with the same name already exists in the project:

```
mcp__atlassian__searchJiraIssuesUsingJql
  jql: "project = \"OSK\" AND issuetype = Epic AND summary ~ \"Maintenance Contract Management\""
  maxResults: 5
```

If the result has `total > 0`, present the found Epics to the user with their key (e.g. `OSK-12`) and ask how to proceed before continuing.
