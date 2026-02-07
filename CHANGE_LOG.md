# Change Log

> Append-only history of all change requests after V1 completion.
> See [CHANGE_PROCESS.md](CHANGE_PROCESS.md) for the full lifecycle.

## How to Read This File

Each entry follows this format:

```
### CHG-NNN: <Short Title>

- **Date**: YYYY-MM-DD
- **Status**: IN_PROGRESS | COMPLETE | REVERTED | BLOCKED | PARTIAL_MERGE_BLOCKED
- **Labels**: [NEEDS_PRODUCT_DECISION] [NEEDS_ARCHITECTURE_REVIEW] [SCHEMA_CHANGE] [BREAKING_SCHEMA_CHANGE] [MODE_ESCALATION]
- **Request**: <User's original prompt>
- **Scope**: backend-only | frontend-only | both
- **Mode**: INLINE | STANDARD
- **Branch**: change/CHG-NNN-short-description
- **Contract Version**: v1.0.0 → v1.1.0 (if changed)
- **Stories**:
  - [ ] Story 1: description (backend/frontend)
  - [ ] Story 2: description (backend/frontend)
- **Files Changed**:
  - Backend: list of files
  - Frontend: list of files
- **Tests**: +N added, M modified
- **Review**: APPROVED | REJECTED
- **DoD**: PASSED (`make dod` green) | FAILED (with failing items)
- **Notes**: any follow-ups or warnings
```

**Status** is a lifecycle state only. **Labels** are metadata flags that can co-exist with any status.
This separation makes it possible to filter/automate on status without ambiguity.

---

## Changes

### CHG-001: Increase Pipeline Limits + Pages Analyzed CTA

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE]
- **Request**: Increase pipeline limits (timeout 90→180s, max pages 8→20) and add a pages_analyzed field to GovernanceReport with a CTA for full-site audit
- **Scope**: both
- **Branch**: change/CHG-001-increase-limits-cta
- **Contract Version**: v1.0.0 → v1.1.0
- **Stories**:
  - [x] Story 1: Increase pipeline limits (backend) — pipeline_timeout_seconds 90→180, max_sample_pages 8→20
  - [x] Story 2: Add pages_analyzed to GovernanceReport schema (backend) — additive field, default 0
  - [x] Story 3: Display pages analyzed + full report CTA (frontend) — text + blue info banner
- **Files Changed**:
  - Backend: app/core/config.py, app/models/schemas.py, app/services/pipeline.py, CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md, tests/test_pipeline.py, tests/test_page_sampler.py, tests/test_health.py, tests/fixtures/reports/governance-report.json
  - Frontend: src/types/api.ts, src/pages/ReportPage.tsx, src/mocks/golden/governance-report.json, CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md, src/pages/__tests__/report-page.test.tsx
- **Tests**: +4 added (backend), +2 added (frontend)
- **Review**: APPROVED
- **DoD**: PASSED (`make dod` green in both repos)
- **Notes**: Contract version bumped to 1.1.0 (additive MINOR). CTA copy uses transparent language. No salesy terms.

### CHG-002: Increase Pipeline Timeout to 450s (REVERTED — process not followed)

- **Date**: 2026-02-07
- **Status**: REVERTED
- **Labels**: (none)
- **Request**: Increase pipeline timeout from 180s to 450s to handle 20-page analysis with PSI + Gemini
- **Scope**: backend-only
- **Branch**: change/CHG-002-increase-timeout-450
- **Contract Version**: (unchanged, 1.1.0)
- **Stories**:
  - [x] Story 1: Increase pipeline_timeout_seconds default from 180 to 450
- **Files Changed**:
  - Backend: app/core/config.py, app/services/pipeline.py, tests/test_pipeline.py, tests/test_health.py
- **Tests**: 0 added, 2 modified (default assertions updated)
- **Review**: APPROVED (config-only change, no contract/schema impact)
- **DoD**: PASSED
- **Notes**: Typical 20-page run ~135s, worst-case ~475s. 450s covers all but pathological sites. REVERTED — process steps skipped. Redone as CHG-003.

### CHG-003: Increase Pipeline Timeout to 450s

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Increase pipeline timeout from 180s to 450s to handle 20-page analysis with PSI + Gemini (redo of CHG-002 with full process)
- **Scope**: backend-only
- **Branch**: change/CHG-003-increase-timeout-450
- **Contract Version**: (unchanged, 1.1.0)
- **Stories**:
  - [ ] Story 1: Increase pipeline_timeout_seconds default from 180 to 450 (backend)
    - **Out of Scope**: Changing fetch_timeout_seconds or max_sample_pages; adding dynamic/per-URL timeout configuration; adding timeout alerting/monitoring
- **Files Changed**:
  - Backend: app/core/config.py, app/services/pipeline.py, .env.example, tests/test_pipeline.py, tests/test_health.py, ARCHITECTURE.md, PROGRESS.md, CURRENT_TASKS.md
- **Tests**: 0 added, 3 modified (test_health.py, test_pipeline.py x2 — default assertions updated from 180→450)
- **Review**: (pending)
- **DoD**: (pending)
- **Files Changed**:
  - Backend: app/core/config.py, app/services/pipeline.py, .env.example, tests/test_pipeline.py, tests/test_health.py, ARCHITECTURE.md, PROGRESS.md, CURRENT_TASKS.md, REVIEW_LOG.md
- **Tests**: 0 added, 4 modified (default assertions updated 180→450)
- **Review**: APPROVED (Review Agent — all 11 triggers pass, make check + make dod green)
- **DoD**: PASSED
- **Notes**: Redo of CHG-002 following full 8-step process. TDD confirmed (tests failed first). Risk: LOW. Confidence: HIGH.

### CHG-004: Fix ProgressBar percentage display

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Progress bar shows 0.8% instead of 80% — backend sends 0.0–1.0, frontend displays raw value with % sign
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-004-fix-progress-percentage
- **Contract Version**: (unchanged, 1.1.0)
- **Stories**:
  - [x] Story 1: Multiply progress by 100 and round in ProgressBar component
- **Files Changed**:
  - `frontend/src/components/ProgressBar.tsx` — added `Math.round(progress * 100)` conversion
  - `frontend/src/components/__tests__/progress-bar.test.tsx` — new file, 5 tests
  - `frontend/src/pages/__tests__/report-page.test.tsx` — fixed mock data (30→0.30, 100→1.0, 45→0.45)
- **Tests**: 5 added, 3 modified (mock data corrected to match backend 0.0–1.0 contract)
- **Review**: APPROVED (INLINE — orchestrator review, all 11 triggers pass, make check + make dod green)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. Root cause: ProgressBar displayed backend's 0.0–1.0 float directly with % sign. Existing test mocks used 0–100 scale incorrectly, masking the bug. TDD confirmed (3 tests failed before fix).

### CHG-005: Two-View Report — Business Overview + Technical Details

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE]
- **Request**: Add "Business Overview" tab (default) showing executive narrative, business-impact categories, and top 3 improvements. Keep existing technical view as "Technical Details" tab. Make report accessible to non-technical business owners.
- **Scope**: backend + frontend
- **Mode**: STANDARD
- **Branch**: change/CHG-005-two-view-report
- **Contract Version**: 1.1.0 → 1.2.0 (additive)
- **Stories**:
  - [x] Backend: Schema additions (executive_narrative, business_category, TopImprovement, top_improvements)
  - [x] Backend: Business category mapping for all 28 signal templates
  - [x] Backend: Executive narrative generation (Gemini + deterministic fallback)
  - [x] Backend: Top 3 improvements extraction from pipeline
  - [x] Backend: Tests for all new functionality (20 new tests)
  - [x] Frontend: Type updates, 3 new components (ExecutiveStory, BusinessImpactCategories, TopImprovements)
  - [x] Frontend: Tab restructure (Business Overview default, Technical Details, SEO)
  - [x] Frontend: Tests for new components and tab behavior (18 new tests)
- **Files Changed**:
  - Backend (14 files): schemas.py, templates.py, issue_builder.py, gemini_summarizer.py, pipeline.py, golden fixture, test_business_view.py (new), CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md, REVIEW_LOG.md
  - Frontend (18 files): api.ts, ExecutiveStory.tsx (new), BusinessImpactCategories.tsx (new), TopImprovements.tsx (new), ReportTabs.tsx, ReportPage.tsx, SidePanel.tsx, golden fixture, 4 new test files, CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md, REVIEW_LOG.md
- **Tests**: 38 added (20 backend, 18 frontend). Total: 397 (252 backend, 145 frontend)
- **Review**: APPROVED (Review Agent — all 11 triggers pass, make check + make dod green in both repos)
- **DoD**: PASSED
- **Notes**: Risk: MEDIUM. Confidence: HIGH. Additive schema change only. Existing views untouched. Out of scope: checklist changes, SEO report changes, backend detector changes. Review agent applied 4 fix commits (contract bump, docs, review log).
