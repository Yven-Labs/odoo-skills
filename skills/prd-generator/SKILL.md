---
name: prd-generator
description: >
  Converts raw meeting notes or client briefs into a professional,
  complete Product Requirements Document (PRD) 100% oriented to the
  Odoo ERP ecosystem. Acts as a Senior Business Analyst specialized in
  Odoo implementations and customizations.
license: MIT
metadata:
  author: Geraldow
  version: "2.0.0"
  scope: [root]
  skill_id: ODSK-SKL-PRD
---

# PRD Generator Skill

## Context

This skill transforms unstructured notes, meeting transcripts, or loose ideas — typically gathered by Project Managers or Functional Consultants — into a formal, structured PRD ready for client approval before moving to the Technical Architecture phase (RFC).

The generated PRD is **100% Odoo-native**: every section uses terminology, conventions, and structure native to the Odoo ERP ecosystem. It is not a generic software PRD adapted to Odoo; it is a document designed from the ground up for Odoo implementation, customization, or extension projects.

---

## Instructions for the AI

1. **Role**: Act as a Senior Business Analyst with extensive experience in Odoo ERP implementation projects (Community and Enterprise).
2. **Input Analysis**: Read the user's notes carefully. Identify: business objectives, actors (roles), affected Odoo modules, functional requirements, and constraints.
3. **Required Format**: Structure your response EXACTLY according to the template `references/prd-template-output.md`. Do not omit or reorder sections.
4. **Required Odoo Vocabulary**: Transform generic requirements into native Odoo terminology:
   - "Customer screen" → "Form View of the `res.partner` model"
   - "Contracts table" → "Model `maintenance.contract` with fields `partner_id`, `date_start`, `state`"
   - "Access profile" → "Group `res.groups` — `module.group_role_name`"
   - "Approval button" → "Button action `<button>` with method `action_approve()`"
   - "Change history" → "`mail.thread` Chatter on the model"
5. **Completeness**: If notes omit critical data, document it as an "Open Question" in §7. Do not invent data; document what is assumed.

---

## Odoo Corporate Rules

**REQUIRED — Vocabulary:**
- Every functional requirement MUST reference the affected Odoo module (`sale`, `maintenance`, `account`, etc.)
- Actors MUST be mapped to Odoo `res.groups`, never to "generic system roles"
- Data models MUST be named using the `module.model_name` convention (snake_case with dot)
- Permissions MUST be described in terms of `ir.model.access.csv` (CRUD per group and model)

**FORBIDDEN:**
- Using generic terms without Odoo mapping: "screen", "database table", "user profile", "button", "generic record"
- Referencing technologies, frameworks, or tools external to the Odoo ecosystem without a justified integration rationale
- Mentioning third-party public repositories or external projects as implementation references
- Using informal, ambiguous, or imprecise language in requirements

**TONE**: Formal and professional. This is a business deliverable the client signs. Every requirement must be precise, verifiable, and unambiguous.

---

## PRD Quality Checklist

Before declaring the PRD complete, verify these 7 points. If any is not covered, document it as an "Open Question" in §7:

1. **Stakeholders → `res.groups`**: Is every business role mapped to a specific Odoo group (existing or to be created)?
2. **RFs → Odoo Module**: Does every functional requirement (RF-XX) reference at least one affected Odoo base module?
3. **Data Model**: Is it specified whether new models (`_name`) or only inheritance/configuration (`_inherit`) of existing modules are required?
4. **CRUD Permissions**: Are access permissions defined per role in the `ir.model.access.csv` table in §5.1?
5. **Out of Scope**: Does §6 list at least one explicit item that will NOT be implemented in this phase?
6. **Measurable KPIs**: Do the success criteria in §8 include quantifiable metrics (percentages, times, counts)?
7. **Odoo Technical Risks**: Are data migration risks, module conflicts, and version compatibility documented?

---

## Mermaid Diagram Guide

Generated PRDs MUST include Mermaid diagrams in §3 and §4. This guide ensures professional, readable diagrams suitable for client presentation.

### Required Palette — Enterprise Grayscale

| `classDef` Class | Fill | Text Color | Use |
|---|---|---|---|
| `critico` | `#1A1A1A` black | `#FFFFFF` white | Decisions, approval points, key nodes |
| `importante` | `#424242` dark gray | `#FFFFFF` white | Main business process steps |
| `normal` | `#F5F5F5` very light gray | `#1A1A1A` black | Standard processes and regular steps |
| `secundario` | `#EEEEEE` light gray | `#616161` medium gray | Support data, alternative paths |
| `borde` | `#FFFFFF` white | `#1A1A1A` black | Start and end nodes |

```text
classDef critico    fill:#1A1A1A,color:#FFFFFF,stroke:#1A1A1A,font-weight:bold
classDef importante fill:#424242,color:#FFFFFF,stroke:#424242
classDef normal     fill:#F5F5F5,color:#1A1A1A,stroke:#9E9E9E
classDef secundario fill:#EEEEEE,color:#616161,stroke:#BDBDBD
classDef borde      fill:#FFFFFF,color:#1A1A1A,stroke:#1A1A1A,stroke-width:2px
```

### 7 Diagram Design Rules

1. **Semantic shapes**: `([...])` start/end · `{...}` decision · `["line1\nline2"]` multiline process node
2. **Emojis as visual indicators**: 🚀 start · 📋 process · ✅ approval · ❌ rejection · 🔄 cycle · 🏁 end
3. **Multiline labels**: Use `["text\nsecond line"]` to keep nodes compact and readable
4. **Business language**: Labels use client-facing terms, not Odoo technical terms
5. **Maximum 12 nodes per diagram**: More than 12 nodes should be split or the flow simplified
6. **Labels on decision arrows**: Always label `-->|"✅ Approved"|` and `-->|"❌ Rejected"|`
7. **White background**: Start/end node always uses `classDef borde` (white fill, black border)

### Required Diagrams by Section

- **§3 Functional Requirements**: `flowchart TD` — As-Is → To-Be business process with grayscale palette
- **§4 Odoo Ecosystem Impact**: `graph LR` — Dependencies between existing Odoo modules and the new module

---

## Guided Question Flow

If the user's input is insufficient to complete the PRD, formulate grouped questions. **Maximum 5 questions per round.** Prioritize the Business category first.

### Category 1: Business (High Priority)
- What is the current business process (manual or system) being replaced or improved?
- What specific problem does the current process generate? (time, errors, lack of visibility, costs)
- How many users will use this module and in which departments?
- Is there a deadline or business milestone that conditions the delivery?

### Category 2: Odoo Technical (Medium Priority)
- What version of Odoo does the client have installed? (17.0, 18.0 — Community or Enterprise?)
- Which Odoo modules are already active in the client's environment?
- Are completely new data models required, or is it possible to extend existing models?
- Are there integrations with external systems (APIs, e-invoicing, legacy ERP)?

### Category 3: Permissions (Medium Priority)
- What are the user roles that will interact with the new module?
- What actions can each role perform? (read-only, create, approve, configure)
- Is data isolation required per user or per company (multi-company)?

---

## Workflow

1. **Receive input**: The user provides meeting notes, minutes, an email, or an informal description of the requirement.
2. **Assess completeness**: Check if the input covers the 7 Quality Checklist points. If critical business data is missing → Guided Question Flow (max. 5 questions per round).
3. **Generate PRD**: Structure the content EXACTLY according to `references/prd-template-output.md`. Include Mermaid diagrams in §3 and §4 with the grayscale palette.
4. **Run Checklist**: Verify the 7 points. Missing data is documented as "Open Question" in §7.
5. **Present and refine**: Deliver the PRD to the user. Ask: *"Would you like to review or adjust any section before proceeding to approval?"*
6. **Approval Note**: The PRD includes a formal approval note at the bottom. The client reviews and confirms before moving to the RFC phase.

---

## Assets

| File | When to use |
|---|---|
| [`assets/prd-example.md`](assets/prd-example.md) | Complete enterprise example — "Maintenance Contract Management System" case. Use as reference for structure, level of detail, Odoo vocabulary, and diagram style. |

---

## References

| File | Content |
|---|---|
| [`references/prd-template-output.md`](references/prd-template-output.md) | Official template with the 8 sections of the Odoo-oriented PRD. The AI MUST follow this template exactly when generating any PRD. |
