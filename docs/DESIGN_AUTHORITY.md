# FINAL THAW — Design Authority

## Purpose

This document declares **WHICH DOCUMENT IS NORMATIVE** for each area, which documents are historical/informative, what happens if two documents disagree, who can approve changes, how to update traceability, and what decisions are closed vs. open for prototype validation.

This eliminates ambiguity and prevents "document conflict" during implementation.

---

## Normative Documents (Source of Truth)

| Area | Normative Document | Version | Status |
|------|-------------------|---------|--------|
| **Vision & Identity** | `docs/VISION.md` | 1.0 | ✅ NORMATIVE (player fantasy, core emotion, pillars, ANTI-PILLARS, audience, differentiation, scope, duration) |
| **Core Gameplay Loop** | `docs/CORE_LOOP.md` | 1.0 | ✅ NORMATIVE (minute-by-minute gameplay, decision frequency, metrics) |
| **Systems Specification** | `docs/SYSTEMS_SPEC.md` | 1.0 | ✅ NORMATIVE (9 systems: temperature, resources, shelter, displacement, threats, health, inventory, time, consequences—with inputs, outputs, limits, priorities, interactions) |
| **Level Structure** | `docs/LEVEL_STRUCTURE.md` | 1.0 | ✅ NORMATIVE (16 phases, 3 acts, zones, shortcuts, decision points, encounters, resources, checkpoints, rhythm) |
| **Survival Systems** | `docs/SURVIVAL_SYSTEMS.md` | 1.0 | ✅ NORMATIVE (3 variables: elena_safety, prototype_integrity, civilian_aid—with thresholds for endings) |
| **Exploration Flow** | `docs/EXPLORATION_FLOW.md` | 1.0 | ✅ NORMATIVE (phase structure, exploration metrics, rewards) |
| **Narrative States** | `docs/NARRATIVE_STATE_MAP.md` | 1.0 | ✅ NORMATIVE (global states, story flags, state transitions) |
| **Progression** | `docs/PROGRESSION_SPEC.md` | 1.0 | ✅ NORMATIVE (campaign order, skill progression, NG+ unlocks) |
| **Accessibility** | `docs/ACCESSIBILITY_SPEC.md` | 1.0 | ✅ NORMATIVE (38 testable requirements, 12 categories—ALL must PASS for shippable) |
| **Vertical Slice** | `docs/VERTICAL_SLICE_PLAN.md` | 1.0 | ✅ NORMATIVE (25-minute Phase 6 spec, success criteria, metrics) |
| **Technical Risks** | `docs/TECHNICAL_RISK_REGISTER.md` | 1.0 | ✅ NORMATIVE (8 risks with probability, impact, mitigation, owner, triggers) |
| **Traceability** | `docs/TRACEABILITY_MATRIX.md` | 1.0 | ✅ NORMATIVE (pillar → mechanic → scene → variable → UI → test → acceptance) |
| **Narrative (Full)** | `docs/narrative_complete.md` | 1.0 | ✅ NORMATIVE (full arc, characters, states, consequences) |
| **Technical Quality** | `docs/technical_quality.md` | 1.0 | ✅ NORMATIVE (platforms, performance, memory, save, telemetry) |
| **Accessibility (Full)** | `docs/accessibility_requirements.md` | 1.0 | ✅ NORMATIVE (35 KB, 38 requirements with tests) |

---

## Historical/Informative Documents

| Document | Purpose | Status |
|----------|---------|--------|
| `docs/award_vision.md` | Early vision document (superseded by `VISION.md`) | ℹ️ INFORMATIVE (use `VISION.md` for normative vision) |
| `docs/core_gameplay_loop.md` | Extended core loop spec (complements `CORE_LOOP.md`) | ℹ️ INFORMATIVE (use `CORE_LOOP.md` for normative loop) |
| `docs/PREPRODUCTION_INDEX.md` | Full documentation index (superseded by `CRITICAL_DOCS_INDEX.md`) | ℹ️ INFORMATIVE (use `CRITICAL_DOCS_INDEX.md` for current index) |
| `docs/SOURCE_OF_TRUTH.md` | Declares definitive versions (superseded by `DESIGN_AUTHORITY.md`) | ℹ️ INFORMATIVE (use `DESIGN_AUTHORITY.md` for normative authority) |
| `GDD.md` | High-level game design (superseded by normative docs above) | ℹ️ INFORMATIVE (use specific normative docs for each area) |

---

## Conflict Resolution

### What Happens If Two Documents Disagree?

**Rule 1**: Normative documents ALWAYS override historical/informative documents.

**Example**: If `award_vision.md` says "duration: 10-12 hours" but `VISION.md` says "duration: 13-15 hours", use `VISION.md` (normative).

**Rule 2**: If two normative documents disagree, the MORE SPECIFIC document wins.

**Example**: If `SYSTEMS_SPEC.md` says "health pack: +25 health" but `SURVIVAL_SYSTEMS.md` says "health pack: +30 health", use `SYSTEMS_SPEC.md` (more specific to systems).

**Rule 3**: If two normative documents of equal specificity disagree, escalate to Lead Designer.

**Example**: If `CORE_LOOP.md` and `LEVEL_STRUCTURE.md` both make conflicting claims about phase duration, Lead Designer decides.

---

## Change Approval Process

### Who Can Approve Changes?

| Change Type | Approver | Process |
|-------------|----------|---------|
| **Minor edit** (typo, clarification, no mechanical change) | Author of document | Edit directly, commit with message: `docs: [document] minor edit (typo/clarification)` |
| **Mechanical change** (alters gameplay, systems, narrative, accessibility) | Lead Designer + affected discipline lead | 1. Create PR, 2. Tag Lead Designer + affected lead, 3. Wait for approval, 4. Merge, 5. Update traceability if needed |
| **Normative change** (alters normative document: VISION, CORE_LOOP, SYSTEMS_SPEC, LEVEL_STRUCTURE, etc.) | Lead Designer + Producer | 1. Create PR, 2. Tag Lead Designer + Producer, 3. Wait for approval, 4. Merge, 5. Update traceability, 6. Update this document if normative list changes |
| **Anti-pillar change** (adds/removes ANTI-PILLAR) | Lead Designer + Producer + entire team | 1. Create PR, 2. Tag Lead Designer + Producer, 3. Team discussion (48h minimum), 4. Unanimous approval required, 5. Merge, 6. Update traceability, 7. Update this document |

### How to Request a Change

1. **Create issue**: `docs: [document] change request (brief description)`
2. **Describe change**: What, why, impact on other documents, impact on traceability
3. **Tag approvers**: Lead Designer + affected discipline lead
4. **Wait for approval**: Do NOT merge until approved
5. **Update traceability**: If change affects pillar → mechanic → scene → variable → UI → test → acceptance, update `TRACEABILITY_MATRIX.md`
6. **Update this document**: If change adds/removes normative document, update `DESIGN_AUTHORITY.md`

---

## Traceability Updates

### When to Update Traceability?

Update `TRACEABILITY_MATRIX.md` when:
- A pillar changes (VISION.md)
- A mechanic changes (CORE_LOOP.md, SYSTEMS_SPEC.md)
- A scene changes (LEVEL_STRUCTURE.md, narrative_complete.md)
- A variable changes (SURVIVAL_SYSTEMS.md, SYSTEMS_SPEC.md)
- A UI element changes (ACCESSIBILITY_SPEC.md, technical_quality.md)
- A test changes (test files, accessibility_requirements.md)
- An acceptance criterion changes (VERTICAL_SLICE_PLAN.md, TECHNICAL_RISK_REGISTER.md)

### How to Update Traceability?

1. **Open `TRACEABILITY_MATRIX.md`**
2. **Find affected row**: Pillar → Mechanic → Scene → Variable → UI → Test → Acceptance
3. **Update row**: Change affected cells, keep format consistent
4. **Update summary table**: Update totals at bottom (mechanics, scenes, variables, UI, tests, acceptance criteria)
5. **Commit**: `docs: TRACEABILITY_MATRIX.md update (reason: [change description])`
6. **Tag QA Lead**: Ensure tests still match acceptance criteria

---

## Decisions Closed vs. Open for Prototype Validation

### Decisions CLOSED (Cannot Change Without Normative Approval)

| Decision | Document | Rationale |
|----------|----------|-----------|
| **Player fantasy**: "I am the scientist and the soldier" | `VISION.md` | Core identity, changing this changes the game |
| **Core emotion**: "Weighted hope" (not hopelessness, not despair) | `VISION.md` | Core emotional target, changing this changes the experience |
| **4 Pillars**: Choices matter, environment masterable, dual-protagonist, failure teaches | `VISION.md` | Core design principles, changing these breaks the game |
| **4 ANTI-PILLARS**: No survival porn, no white savior, no techno-utopianism, no randomness | `VISION.md` | Explicit boundaries, violating these breaks trust with players |
| **3 Endings**: Public Thaw, Guarded Thaw, Fragile Thaw (with explicit thresholds) | `SURVIVAL_SYSTEMS.md` | Core narrative structure, changing this breaks the arc |
| **9 Systems**: Temperature, resources, shelter, displacement, threats, health, inventory, time, consequences | `SYSTEMS_SPEC.md` | Core gameplay systems, changing these breaks mechanics |
| **16 Phases, 3 Acts**: Fixed campaign structure | `LEVEL_STRUCTURE.md` | Core progression, changing this breaks pacing |
| **38 Accessibility Requirements**: ALL must PASS for shippable | `ACCESSIBILITY_SPEC.md` | Non-negotiable commitment to accessibility |
| **60 FPS, <2s loads, ≤5-8 GB memory**: Technical budgets | `technical_quality.md` | Non-negotiable performance targets |

---

### Decisions OPEN for Prototype Validation (Can Change Based on Playtest Data)

| Decision | Document | Hypothesis | Validation Method |
|----------|----------|------------|-------------------|
| **Health pack value**: +25 health (could be +20 or +30) | `SYSTEMS_SPEC.md` | +25 is generous but not OP | Playtest Phase 6, measure health usage, adjust if players never use or always full |
| **Aster charges per level**: 3 (could be 2 or 4) | `SYSTEMS_SPEC.md` | 3 is enough for meaningful choices | Playtest Phase 9-10, measure charge usage, adjust if players always/never use |
| **Oxygen timer**: 60s (could be 45s or 90s) | `SYSTEMS_SPEC.md` | 60s is generous (most finish in 30-40s) | Playtest Phase 6 oxygen section, measure completion times, adjust if >20% fail |
| **Checkpoint spacing**: ≤5 min (could be ≤3 min or ≤7 min) | `LEVEL_STRUCTURE.md` | ≤5 min is fair (not too punishing, not too easy) | Playtest all phases, measure death frequency, adjust if players complain about repetition |
| **Enemy damage**: 10-50 per hit (could be 5-40 or 15-60) | `SYSTEMS_SPEC.md` | 10-50 is challenging but fair | Playtest combat arenas, measure death frequency, adjust if players die too fast or too slow |
| **Run speed**: 320 pixels/s (could be 280 or 360) | `SYSTEMS_SPEC.md` | 320 is agile but not too fast for puzzles | Playtest puzzle + combat sections, measure completion times, adjust if players feel too slow or too fast |
| **Vertical slice duration**: 20-30 min (could be 15-25 or 25-35) | `VERTICAL_SLICE_PLAN.md` | 20-30 min is ideal for first impression | Playtest Phase 6 with 20+ players, measure completion times, adjust scope if >30 min or <15 min |

**Key Principle**: Closed decisions are STRUCTURAL (vision, pillars, systems, campaign). Open decisions are BALANCE/TUNING (numbers, timings, values) that can be validated through playtesting.

---

## MUST_FIX_BEFORE_IMPLEMENTATION

### Current List (Empty = All Structural Decisions Closed)

**Status**: ✅ EMPTY. All structural decisions are closed. Only balance/tuning decisions remain open (to be validated through prototyping).

**Justification**: 
- Vision is defined (player fantasy, core emotion, pillars, ANTI-PILLARS, audience, differentiation, scope, duration)
- Core loop is defined (minute-by-minute, decision frequency, metrics)
- Systems are defined (9 systems with inputs, outputs, limits, priorities, interactions)
- Level structure is defined (16 phases, 3 acts, zones, shortcuts, decision points, encounters, resources, checkpoints, rhythm)
- Accessibility is defined (38 testable requirements, ALL must PASS)
- Technical budgets are defined (60 FPS, <2s loads, ≤5-8 GB memory)
- Traceability is complete (pillar → mechanic → scene → variable → UI → test → acceptance)

**Remaining Uncertainties**: All remaining uncertainties are PROTOTYPABLE (balance, tuning, feel). No structural uncertainties remain.

---

## Sign-Off

**Lead Designer**: [ ] I approve this as the authoritative source for design decisions
**Lead Programmer**: [ ] I understand which documents are normative and will implement accordingly
**Lead Writer**: [ ] I understand which documents are normative and will write narrative accordingly
**Accessibility Lead**: [ ] I understand 38 requirements are non-negotiable (ALL must PASS)
**QA Lead**: [ ] I understand which documents define acceptance criteria for tests
**Producer**: [ ] I approve this governance structure and will enforce it

**Date**: September 30, 2026
**Status**: ✅ DESIGN AUTHORITY COMPLETE. NORMATIVE DOCUMENTS DECLARED. CONFLICT RESOLUTION DEFINED. CHANGE APPROVAL PROCESS CLEAR. TRACEABILITY UPDATES SPECIFIED. CLOSED VS. OPEN DECISIONS SEPARATED. MUST_FIX LIST EMPTY.
