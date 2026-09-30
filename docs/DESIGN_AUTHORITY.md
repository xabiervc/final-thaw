# FINAL THAW — Design Authority

## Purpose

This document declares:
1. **Which documents are NORMATIVE** (must be followed for implementation).
2. **Which documents are ARCHIVED** (historical reference only, do not use).
3. **How to resolve conflicts** when two documents disagree.
4. **Who can approve changes** to normative documents.
5. **How to update traceability** when documents change.
6. **Which version is frozen** for implementation start.
7. **Which decisions are deliberately open** for prototyping (not structural).

---

## 1. Normative Documents (Must Follow)

These documents are **NORMATIVE**. They define the design. Implementation MUST follow these documents. If implementation deviates, it must be justified and approved.

### Category 1: Vision & Identity

| Document | Version | Frozen? | Owner |
|----------|---------|---------|-------|
| [`docs/VISION.md`](VISION.md) | 1.0 | ✅ Yes (frozen for implementation) | Lead Designer |
| [`docs/non_negotiable_pillars.md`](non_negotiable_pillars.md) | 1.0 | ✅ Yes | Lead Designer |

### Category 2: Core Gameplay

| Document | Version | Frozen? | Owner |
|----------|---------|---------|-------|
| [`docs/CORE_LOOP.md`](CORE_LOOP.md) | 1.0 | ✅ Yes | Lead Designer |
| [`docs/SYSTEMS_SPEC.md`](SYSTEMS_SPEC.md) | 1.0 | ✅ Yes | Lead Programmer |
| [`docs/LEVEL_STRUCTURE.md`](LEVEL_STRUCTURE.md) | 1.0 | ✅ Yes | Level Designer |
| [`docs/PROGRESSION_SPEC.md`](PROGRESSION_SPEC.md) | 1.0 | ✅ Yes | Lead Designer |

### Category 3: Narrative

| Document | Version | Frozen? | Owner |
|----------|---------|---------|-------|
| [`docs/narrative_complete.md`](narrative_complete.md) | 1.0 | ✅ Yes | Lead Writer |
| [`docs/NARRATIVE_STATE_MAP.md`](NARRATIVE_STATE_MAP.md) | 1.0 | ✅ Yes | Lead Writer |
| [`docs/SURVIVAL_SYSTEMS.md`](SURVIVAL_SYSTEMS.md) | 1.0 | ✅ Yes | Lead Designer |

### Category 4: Accessibility

| Document | Version | Frozen? | Owner |
|----------|---------|---------|-------|
| [`docs/ACCESSIBILITY_SPEC.md`](ACCESSIBILITY_SPEC.md) | 1.0 | ✅ Yes | Accessibility Lead |
| [`docs/accessibility_requirements.md`](accessibility_requirements.md) | 1.0 | ✅ Yes | Accessibility Lead |

### Category 5: Technical

| Document | Version | Frozen? | Owner |
|----------|---------|---------|-------|
| [`docs/technical_quality.md`](technical_quality.md) | 1.0 | ✅ Yes | Lead Programmer |
| [`docs/TECHNICAL_RISK_REGISTER.md`](TECHNICAL_RISK_REGISTER.md) | 1.0 | ✅ Yes | Lead Programmer |

### Category 6: Production

| Document | Version | Frozen? | Owner |
|----------|---------|---------|-------|
| [`docs/VERTICAL_SLICE_PLAN.md`](VERTICAL_SLICE_PLAN.md) | 1.0 | ✅ Yes | Producer |
| [`docs/TRACEABILITY_MATRIX.md`](TRACEABILITY_MATRIX.md) | 1.0 | ✅ Yes | QA Lead |

---

## 2. Archived Documents (Do Not Use)

These documents are **ARCHIVED**. They are historical reference only. DO NOT use them for implementation. If a document is not listed as "Normative" above, it is archived by default.

### Archived Quality Enhancement Documents

| Document | Reason for Archival | Superseded By |
|----------|---------------------|---------------|
| `docs/quality_enhancements.md` | Working draft, content merged | `docs/CORE_LOOP.md` |
| `docs/premium_quality_enhancements.md` | Working draft, content merged | `docs/CORE_LOOP.md` |
| `docs/gameplay_technical_enhancements.md` | Working draft, content merged | `docs/CORE_LOOP.md` + `docs/SYSTEMS_SPEC.md` |
| `docs/quality_vision.md` | Working draft, content merged | `docs/VISION.md` |
| `docs/award_vision.md` | Working draft, content merged | `docs/VISION.md` |
| `docs/quality_integration_summary.md` | Working draft, content merged | `docs/TRACEABILITY_MATRIX.md` |
| `docs/narrative_enhancements.md` | Working draft, content merged | `docs/narrative_complete.md` |
| `docs/narrative_design_complete.md` | Working draft, content merged | `docs/narrative_complete.md` |
| `docs/narrative_documentation.md` | Working draft, content merged | `docs/narrative_complete.md` |
| `docs/technical_excellence.md` | Working draft, content merged | `docs/technical_quality.md` |
| `docs/accessibility_implementation.md` | Working draft, content merged | `docs/ACCESSIBILITY_SPEC.md` |

### Archived Summary Documents

| Document | Reason for Archival | Superseded By |
|----------|---------------------|---------------|
| `docs/phase_prompts_update_guide.md` | Working draft, content merged | `prompts/AWARD_LEVEL_README.md` |
| `docs/ALL_PHASES_AWARD_LEVEL_SUMMARY.md` | Working draft, content merged | `prompts/AWARD_LEVEL_README.md` |
| `docs/critic_response_executive_summary.md` | Working draft, content merged | `docs/COMPLETION_VERIFICATION.md` |
| `docs/award_checklist.md` | Working draft, content merged | `docs/COMPLETION_VERIFICATION.md` |

### Redundant Versions

| Document | Reason for Archival | Superseded By |
|----------|---------------------|---------------|
| `docs/SOURCE_OF_TRUTH.md` | Redundant with `DESIGN_AUTHORITY.md` | `docs/DESIGN_AUTHORITY.md` (this document) |
| `docs/COMPLETION_VERIFICATION.md` | Historical snapshot | `docs/COMPLETION_VERIFICATION.md` (kept for reference, not normative) |
| `docs/PREPRODUCTION_INDEX.md` | Historical snapshot | `docs/CRITICAL_DOCS_INDEX.md` (active index) |

---

## 3. Conflict Resolution

### When Two Documents Disagree

**Priority Order** (highest to lowest):

1. **DESIGN_AUTHORITY.md** (this document) — Defines which documents are normative
2. **VISION.md** — Core identity, pillars, anti-pillars
3. **non_negotiable_pillars.md** — 4 pillars with design tests
4. **CORE_LOOP.md** — Core gameplay loop
5. **SYSTEMS_SPEC.md** — 9 survival systems
6. **LEVEL_STRUCTURE.md** — Zone structure
7. **PROGRESSION_SPEC.md** — Campaign progression
8. **narrative_complete.md** — Full narrative
9. **ACCESSIBILITY_SPEC.md** — 38 requirements
10. **technical_quality.md** — Technical standards
11. **VERTICAL_SLICE_PLAN.md** — Vertical slice spec
12. **TRACEABILITY_MATRIX.md** — Pillar → test traceability

**Rule**: If a lower-priority document conflicts with a higher-priority document, the HIGHER-PRIORITY document wins.

**Example**: If `LEVEL_STRUCTURE.md` says "Phase 6 has 5 zones" but `VERTICAL_SLICE_PLAN.md` says "Phase 6 has 8 zones", `LEVEL_STRUCTURE.md` wins (priority 6 > priority 11).

### How to Report a Conflict

1. **Open GitHub Issue** with title: `[CONFLICT] Document A vs. Document B: [brief description]`
2. **Tag**: Lead Designer, Owner of Document A, Owner of Document B
3. **Describe**: What is the conflict? Which documents disagree? What is the impact?
4. **Wait for Resolution**: Lead Designer will review, consult owners, and update documents within 48 hours
5. **Update Traceability**: If conflict resolution changes design, update `TRACEABILITY_MATRIX.md` accordingly

---

## 4. Change Approval Process

### Who Can Approve Changes?

| Document Type | Approver | Backup Approver |
|---------------|----------|-----------------|
| Vision & Identity (VISION.md, pillars) | Lead Designer | Producer |
| Core Gameplay (CORE_LOOP, SYSTEMS, LEVEL_STRUCTURE, PROGRESSION) | Lead Designer | Lead Programmer |
| Narrative (narrative_complete, NARRATIVE_STATE_MAP, SURVIVAL_SYSTEMS) | Lead Writer | Lead Designer |
| Accessibility (ACCESSIBILITY_SPEC, accessibility_requirements) | Accessibility Lead | Producer |
| Technical (technical_quality, TECHNICAL_RISK_REGISTER) | Lead Programmer | Producer |
| Production (VERTICAL_SLICE_PLAN, TRACEABILITY_MATRIX) | Producer | Lead Designer |

### Change Process

1. **Propose Change**: Open GitHub Issue with title: `[CHANGE] Document X: [brief description]`
2. **Describe**: What is changing? Why? What is the impact on other documents, traceability, implementation?
3. **Review**: Approver reviews change within 48 hours
4. **Approve/Reject**: Approver approves (merge) or rejects (close with explanation)
5. **Update Traceability**: If change affects traceability, update `TRACEABILITY_MATRIX.md` BEFORE merging
6. **Announce**: Post change summary in team chat (Discord, Slack, etc.)

### Frozen Documents (Cannot Change Without Producer Approval)

**Frozen for Implementation**:
- `VISION.md` (core identity cannot change mid-implementation)
- `CORE_LOOP.md` (core gameplay cannot change mid-implementation)
- `SYSTEMS_SPEC.md` (systems cannot change mid-implementation)
- `LEVEL_STRUCTURE.md` (level structure cannot change mid-implementation)
- `VERTICAL_SLICE_PLAN.md` (vertical slice scope cannot change mid-implementation)

**To Unfreeze**: Producer must approve, Lead Designer must update all affected documents, QA Lead must update traceability.

---

## 5. Traceability Updates

### When to Update Traceability

**Update `TRACEABILITY_MATRIX.md` when**:
- A pillar changes (VISION.md, non_negotiable_pillars.md)
- A mechanic changes (CORE_LOOP.md, SYSTEMS_SPEC.md)
- A scene changes (LEVEL_STRUCTURE.md, narrative_complete.md)
- A variable changes (SURVIVAL_SYSTEMS.md, NARRATIVE_STATE_MAP.md)
- A UI element changes (ACCESSIBILITY_SPEC.md)
- A test changes (TRACEABILITY_MATRIX.md itself)
- An acceptance criterion changes (TRACEABILITY_MATRIX.md itself)

**Do NOT update traceability when**:
- Fixing typos, grammar, formatting (no design impact)
- Adding examples, clarifications (no design change)
- Reorganizing sections (no content change)

### How to Update Traceability

1. **Open `TRACEABILITY_MATRIX.md`**
2. **Find affected row** (pillar, mechanic, scene, variable, UI, test, acceptance)
3. **Update row** to reflect change
4. **Add changelog entry** at bottom of file: `YYYY-MM-DD: Updated [row] due to [change]`
5. **Sign off**: QA Lead approves traceability update

---

## 6. Frozen Version for Implementation

### Implementation Start Version

**Frozen Version**: All normative documents at **v1.0** (as of September 30, 2026).

**Frozen Documents** (cannot change without Producer approval):
- `VISION.md` v1.0
- `CORE_LOOP.md` v1.0
- `SYSTEMS_SPEC.md` v1.0
- `LEVEL_STRUCTURE.md` v1.0
- `PROGRESSION_SPEC.md` v1.0
- `narrative_complete.md` v1.0
- `ACCESSIBILITY_SPEC.md` v1.0
- `technical_quality.md` v1.0
- `VERTICAL_SLICE_PLAN.md` v1.0
- `TRACEABILITY_MATRIX.md` v1.0

**Unfrozen Documents** (can change with Owner approval):
- `TECHNICAL_RISK_REGISTER.md` (risks may evolve during implementation)
- `SURVIVAL_SYSTEMS.md` (may add details as implementation progresses)
- `NARRATIVE_STATE_MAP.md` (may add flags as implementation progresses)
- `accessibility_requirements.md` (may add tests as implementation progresses)

---

## 7. Deliberately Open Decisions (For Prototyping)

### What Is NOT Frozen (Can Be Validated via Prototype)

**Gameplay Feel**:
- Exact movement speed (300 px/s vs. 320 px/s) — validate via prototype
- Exact combo timing (5-frame startup vs. 8-frame) — validate via prototype
- Exact hazard damage (10 vs. 15) — validate via prototype
- Exact health pack heal (+25 vs. +30) — validate via prototype

**Balance**:
- Enemy health values (50 vs. 75 for Scavenger) — validate via playtest
- Timer durations (60s vs. 90s for oxygen) — validate via playtest
- Checkpoint spacing (3 min vs. 5 min) — validate via playtest

**Visual/Audio**:
- Exact color values (hazard telegraph color) — validate via artist
- Exact sound volumes (telegraph sound ramp-up) — validate via audio engineer
- Exact camera shake amplitude (2px vs. 3px) — validate via playtest

**Performance**:
- Exact FPS target (60 vs. 58 in complex scenes) — validate via profiling
- Exact memory budget (5 GB vs. 6 GB peak) — validate via profiling
- Exact load time (2s vs. 2.5s) — validate via profiling

### What IS Frozen (Cannot Change via Prototyping)

**Core Identity**:
- Player fantasy (scientist + protector, not superhero)
- Core emotion (weighted hope, not power fantasy)
- Pillars (Choices Matter, Environment Masterable, Dual-Protagonist, Failure Teaches)
- Anti-pillars (no randomness, no illusion of choice, no interchangeable protagonists)

**Systems**:
- 9 survival systems (Temperature, Resources, Shelter, Displacement, Threats, Health, Inventory, Time, Consequences)
- Consequence variables (Elena Safety, Prototype Integrity, Civilian Aid)
- Ending eligibility thresholds (≤1 Safety/Integrity → Fragile, ≥4 Aid + preserve → Public)

**Structure**:
- 3 acts, 16 phases
- 13-15 hours (novice), 8-10 hours (competent), 5-6 hours (expert)
- 32 zones, 30 checkpoints, 6 shortcuts, 30 decision points

---

## Sign-Off

**Lead Designer**: [ ] I approve this Design Authority document. I will enforce normative documents, archive redundant versions, and approve/reject changes per this process.

**Lead Programmer**: [ ] I approve this Design Authority document. I will implement per normative documents, report conflicts, and update traceability when systems change.

**Lead Writer**: [ ] I approve this Design Authority document. I will write narrative per normative documents, report conflicts, and update traceability when narrative changes.

**Accessibility Lead**: [ ] I approve this Design Authority document. I will test accessibility per normative documents, report conflicts, and update traceability when accessibility changes.

**QA Lead**: [ ] I approve this Design Authority document. I will test per normative documents, update traceability when tests change, and verify all changes are traced.

**Producer**: [ ] I approve this Design Authority document. I will enforce frozen documents, approve unfreezing only when necessary, and ensure change process is followed.

**Date**: September 30, 2026

**Status**: ✅ DESIGN AUTHORITY COMPLETE. NORMATIVE DOCUMENTS DECLARED. ARCHIVED DOCUMENTS MARKED. CONFLICT RESOLUTION DEFINED. CHANGE APPROVAL PROCESS DEFINED. TRACEABILITY UPDATE PROCESS DEFINED. FROZEN VERSION DECLARED. DELIBERATELY OPEN DECISIONS DECLARED.
