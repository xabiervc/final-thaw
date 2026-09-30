# FINAL THAW — Source of Truth (Single Source of Truth Declaration)

## Purpose

This document declares **ONE definitive version** of each document category. All other versions (premium, final, complete, 100 percent, enhanced, v2, etc.) are **ARCHIVED** and should not be used for implementation.

**Rule**: If a document is not listed here as "ACTIVE", it is ARCHIVED. Do not use it for implementation.

---

## Active Documents (Source of Truth)

### Category 1: Design

| Document | Active File | Archived Files |
|----------|-------------|----------------|
| **Core Gameplay Loop** | `docs/core_gameplay_loop.md` | `docs/quality_enhancements.md`, `docs/premium_quality_enhancements.md`, `docs/gameplay_technical_enhancements.md` |
| **Design FAQ (6 Questions)** | `docs/design_faq.md` | None |
| **Non-Negotiable Pillars** | `docs/non_negotiable_pillars.md` | `docs/quality_vision.md`, `docs/award_vision.md` (vision content merged into core_gameplay_loop.md) |

### Category 2: Narrative

| Document | Active File | Archived Files |
|----------|-------------|----------------|
| **Narrative Complete** | `docs/narrative_complete.md` | `docs/narrative_enhancements.md`, `docs/narrative_design_complete.md`, `docs/narrative_documentation.md` |
| **Story Bible** | `docs/story_bible.md` | None (original, kept for reference) |
| **Character Bible** | `docs/character_bible.md` | None (original, kept for reference) |
| **Act Outline** | `docs/act_outline.md` | None (original, kept for reference) |
| **Sample Dialogue** | `docs/sample_dialogue.md` | None (original, kept for reference) |

### Category 3: Accessibility

| Document | Active File | Archived Files |
|----------|-------------|----------------|
| **Accessibility Requirements** | `docs/accessibility_requirements.md` | `docs/accessibility_implementation.md` (implementation details merged into requirements) |

### Category 4: Technical Quality

| Document | Active File | Archived Files |
|----------|-------------|----------------|
| **Technical Quality** | `docs/technical_quality.md` | `docs/technical_excellence.md`, `docs/gameplay_technical_enhancements.md` (technical content merged into technical_quality.md) |

### Category 5: Phase Prompts

| Document | Active File | Archived Files |
|----------|-------------|----------------|
| **Award Level README** | `prompts/AWARD_LEVEL_README.md` | `docs/phase_prompts_update_guide.md`, `docs/ALL_PHASES_AWARD_LEVEL_SUMMARY.md` |
| **Phase 0-3 Award Prompts** | `prompts/phase_00_technical_foundation_award.md`, `prompts/phase_01_elena_movement_award.md`, `prompts/phase_02_abandoned_laboratory_award.md`, `prompts/phase_03_marcus_combat_award.md` | Original prompts in `prompts/phase_00_*.md` etc. (kept for reference) |
| **Phase 4-16 Enhancements** | `prompts/phase_04_to_16_award_enhancements.md` | `docs/quality_integration_summary.md` (enhancement content merged into phase_04_to_16_award_enhancements.md) |

### Category 6: Executive & Verification

| Document | Active File | Archived Files |
|----------|-------------|----------------|
| **Pre-Production Index** | `docs/PREPRODUCTION_INDEX.md` | `docs/critic_response_executive_summary.md`, `docs/award_checklist.md` |
| **Completion Verification** | `docs/COMPLETION_VERIFICATION.md` | None |
| **Source of Truth** | `docs/SOURCE_OF_TRUTH.md` | This document |

---

## Archived Documents (Do Not Use)

### Quality Enhancement Documents (Archived)

These documents were working drafts during the enhancement process. Their content has been **merged into** the active documents listed above. Do not use them for implementation.

| File | Status | Content Merged Into |
|------|--------|---------------------|
| `docs/quality_enhancements.md` | ❌ ARCHIVED | `docs/core_gameplay_loop.md` |
| `docs/premium_quality_enhancements.md` | ❌ ARCHIVED | `docs/core_gameplay_loop.md` |
| `docs/gameplay_technical_enhancements.md` | ❌ ARCHIVED | `docs/core_gameplay_loop.md` + `docs/technical_quality.md` |
| `docs/quality_vision.md` | ❌ ARCHIVED | `docs/non_negotiable_pillars.md` |
| `docs/award_vision.md` | ❌ ARCHIVED | `docs/non_negotiable_pillars.md` |
| `docs/quality_integration_summary.md` | ❌ ARCHIVED | `prompts/phase_04_to_16_award_enhancements.md` |
| `docs/narrative_enhancements.md` | ❌ ARCHIVED | `docs/narrative_complete.md` |
| `docs/narrative_design_complete.md` | ❌ ARCHIVED | `docs/narrative_complete.md` |
| `docs/narrative_documentation.md` | ❌ ARCHIVED | `docs/narrative_complete.md` |
| `docs/technical_excellence.md` | ❌ ARCHIVED | `docs/technical_quality.md` |
| `docs/accessibility_implementation.md` | ❌ ARCHIVED | `docs/accessibility_requirements.md` |
| `docs/phase_prompts_update_guide.md` | ❌ ARCHIVED | `prompts/AWARD_LEVEL_README.md` |
| `docs/ALL_PHASES_AWARD_LEVEL_SUMMARY.md` | ❌ ARCHIVED | `prompts/AWARD_LEVEL_README.md` |
| `docs/critic_response_executive_summary.md` | ❌ ARCHIVED | `docs/PREPRODUCTION_INDEX.md` |
| `docs/award_checklist.md` | ❌ ARCHIVED | `docs/PREPRODUCTION_INDEX.md` |

**Why Archived?**
- These were **working documents** created during the iterative enhancement process
- Their content has been **consolidated** into the active documents
- Keeping them active creates **confusion** about which version to use
- **One source of truth per category** eliminates ambiguity

---

## How to Use This Document

### For Implementation

1. **Open `docs/PREPRODUCTION_INDEX.md`** — This shows the complete list of active documents organized by category
2. **Use ONLY active documents** — If a document is not listed as "Active" in this SOURCE_OF_TRUTH.md, do not use it
3. **Ignore archived documents** — They are kept in the repo for historical reference only, not for implementation

### For New Team Members

1. **Read `docs/PREPRODUCTION_INDEX.md` first** — Overview of all active documentation
2. **Read `docs/SOURCE_OF_TRUTH.md` (this document)** — Understand which files are definitive
3. **Read active documents in order**: Design → Narrative → Accessibility → Technical → Phase Prompts
4. **Do NOT read archived documents** — They are outdated working drafts

### For Version Control

- **Active documents** = Current, definitive, use for implementation
- **Archived documents** = Historical reference, do not use, content merged into active
- **If you create a new document** = Add it to this SOURCE_OF_TRUTH.md as "Active" or "Archived"

---

## Document Lifecycle

### Creation → Enhancement → Consolidation → Archive

1. **Creation**: Initial document created (e.g., `quality_enhancements.md`)
2. **Enhancement**: Document improved iteratively (e.g., `premium_quality_enhancements.md`, `gameplay_technical_enhancements.md`)
3. **Consolidation**: All enhancements merged into ONE definitive document (e.g., `core_gameplay_loop.md`)
4. **Archive**: Original working documents marked as archived in SOURCE_OF_TRUTH.md

**This lifecycle prevents**:
- Multiple versions of the same document
- Confusion about which file to use
- Outdated information being used for implementation

---

## Verification Checklist

Before starting implementation, verify:

- [ ] You have read `docs/PREPRODUCTION_INDEX.md`
- [ ] You have read `docs/SOURCE_OF_TRUTH.md` (this document)
- [ ] You know which documents are ACTIVE vs. ARCHIVED
- [ ] You are using ONLY active documents for implementation
- [ ] You have NOT opened any archived documents (they are for reference only)

**If you accidentally use an archived document**: Stop immediately. Switch to the active document listed in this SOURCE_OF_TRUTH.md.

---

## Sign-Off

**Lead Designer**: [ ] I have read and understand this SOURCE_OF_TRUTH.md
**Lead Writer**: [ ] I have read and understand this SOURCE_OF_TRUTH.md
**Lead Programmer**: [ ] I have read and understand this SOURCE_OF_TRUTH.md
**Producer**: [ ] I have read and understand this SOURCE_OF_TRUTH.md

**Date**: September 30, 2026
**Status**: ✅ SOURCE OF TRUTH DECLARED. ALL TEAM MEMBERS MUST USE ACTIVE DOCUMENTS ONLY.

---

## Quick Reference: Active Documents Only

### Must Read (In Order)
1. `docs/PREPRODUCTION_INDEX.md` — Overview
2. `docs/SOURCE_OF_TRUTH.md` — This document
3. `docs/core_gameplay_loop.md` — Core design
4. `docs/design_faq.md` — 6 critical questions
5. `docs/non_negotiable_pillars.md` — 4 pillars
6. `docs/narrative_complete.md` — Full narrative
7. `docs/accessibility_requirements.md` — 38 requirements
8. `docs/technical_quality.md` — 10 technical categories
9. `prompts/AWARD_LEVEL_README.md` — Which prompts to use
10. `docs/COMPLETION_VERIFICATION.md` — 100% verification

### Do Not Read (Archived)
- `docs/quality_enhancements.md`
- `docs/premium_quality_enhancements.md`
- `docs/gameplay_technical_enhancements.md`
- `docs/quality_vision.md`
- `docs/award_vision.md`
- `docs/quality_integration_summary.md`
- `docs/narrative_enhancements.md`
- `docs/narrative_design_complete.md`
- `docs/narrative_documentation.md`
- `docs/technical_excellence.md`
- `docs/accessibility_implementation.md`
- `docs/phase_prompts_update_guide.md`
- `docs/ALL_PHASES_AWARD_LEVEL_SUMMARY.md`
- `docs/critic_response_executive_summary.md`
- `docs/award_checklist.md`

**Total Active Documents**: 10
**Total Archived Documents**: 15

**Use ONLY the 10 active documents. Ignore the 15 archived documents.**
