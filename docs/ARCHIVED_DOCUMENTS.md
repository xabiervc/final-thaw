# FINAL THAW — Archived Documents

## Purpose

This document explicitly marks **OBSOLETE/ARCHIVED DOCUMENTS** to prevent confusion during implementation. These documents are kept for HISTORICAL REFERENCE ONLY and must NOT be used as authoritative sources.

**Normative Authority**: Use `docs/DESIGN_AUTHORITY.md` as the authoritative source for which documents are normative.

---

## Archived Documents (Do Not Use as Authoritative)

### 1. `docs/SOURCE_OF_TRUTH.md`

**Status**: ℹ️ ARCHIVED (superseded by `DESIGN_AUTHORITY.md`)

**Original Purpose**: Declared definitive versions of documents.

**Why Archived**: `DESIGN_AUTHORITY.md` now serves as the comprehensive governance document, including normative declarations, conflict resolution, and change approval.

**Use Instead**: `docs/DESIGN_AUTHORITY.md`

---

### 2. `docs/award_vision.md`

**Status**: ℹ️ ARCHIVED (superseded by `VISION.md`)

**Original Purpose**: Early vision document with award strategy.

**Why Archived**: `VISION.md` is the complete, normative vision document with player fantasy, core emotion, pillars, ANTI-PILLARS, audience, differentiation, scope, and duration.

**Use Instead**: `docs/VISION.md`

---

### 3. `docs/PREPRODUCTION_INDEX.md`

**Status**: ℹ️ ARCHIVED (superseded by `CRITICAL_DOCS_INDEX.md`)

**Original Purpose**: Full documentation index.

**Why Archived**: `CRITICAL_DOCS_INDEX.md` is the current, maintained index of critical documents.

**Use Instead**: `docs/CRITICAL_DOCS_INDEX.md`

---

### 4. `docs/core_gameplay_loop.md`

**Status**: ℹ️ INFORMATIVE (complements `CORE_LOOP.md`, not superseded)

**Original Purpose**: Extended core loop specification.

**Why Informative**: This document provides additional detail but `CORE_LOOP.md` is the normative 1-page specification.

**Use Instead**: `docs/CORE_LOOP.md` (normative), this document (informative reference only)

---

### 5. `GDD.md`

**Status**: ℹ️ INFORMATIVE (high-level overview only)

**Original Purpose**: High-level game design document.

**Why Informative**: This is a high-level overview. Use specific normative documents for each area (VISION.md, CORE_LOOP.md, SYSTEMS_SPEC.md, etc.).

**Use Instead**: Specific normative documents per `DESIGN_AUTHORITY.md`

---

## How to Identify Archived Documents

Archived documents should have this header:

```markdown
# [DOCUMENT TITLE]

**Status**: ℹ️ ARCHIVED (superseded by [NEW_DOCUMENT.md])

**Original Purpose**: [Why this document was created]

**Why Archived**: [Why this document is no longer authoritative]

**Use Instead**: [Link to normative document]
```

---

## How to Archive a Document

If you discover a document that should be archived:

1. **Add archive header** at the top of the document
2. **Update `ARCHIVED_DOCUMENTS.md`** with the document details
3. **Update `DESIGN_AUTHORITY.md`** if the document was listed as normative
4. **Commit**: `docs: [document] archived (superseded by [new_document])`

---

## Verification Checklist

Before starting implementation, verify:

- [ ] All archived documents are marked in this file
- [ ] `DESIGN_AUTHORITY.md` lists only current normative documents
- [ ] No archived documents are referenced as authoritative in README.md or other docs
- [ ] Team members understand which documents are normative vs. archived

---

**Date**: September 30, 2026

**Status**: ✅ ARCHIVED DOCUMENTS EXPLICITLY MARKED. NO CONFUSION BETWEEN NORMATIVE AND HISTORICAL DOCUMENTS.
