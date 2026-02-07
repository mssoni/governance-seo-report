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

### CHG-006: Business-Goal-Aware Executive Narrative

- **Date**: 2026-02-07
- **Status**: IN_PROGRESS
- **Labels**: (none)
- **Request**: Rewrite executive narrative to frame findings around predicted business goals (e.g., "more patients" for clinics) instead of citing technical issue titles. Never mention technical jargon — only business outcomes on/off track.
- **Scope**: backend-only
- **Mode**: INLINE
- **Branch**: change/CHG-006-business-narrative
- **Contract Version**: (unchanged, 1.2.0 — executive_narrative is still a string)
- **Stories**:
  - [x] Create business goal mapping per BusinessType (10 types)
  - [x] Rewrite deterministic narrative builder with business framing
  - [x] Update Gemini prompt with business context
  - [x] Wire business_type/intent through pipeline to narrative builders
- **Files Changed**:
  - `backend/app/reasoning/business_goals.py` — new file: goal mapping for 10 business types, category impacts, positive translations
  - `backend/app/reasoning/gemini_summarizer.py` — rewritten build_deterministic_narrative(), updated Gemini prompt
  - `backend/app/services/pipeline.py` — passes business_type and intent to narrative builders
  - `backend/tests/test_business_narrative.py` — new file, 25 tests
  - `backend/tests/test_business_view.py` — 1 assertion updated for new vocabulary
- **Tests**: 25 added, 1 modified. Total: 277 backend tests
- **Review**: APPROVED (INLINE — orchestrator review, all 11 triggers pass, make check + make dod green)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. No schema change. Out of scope: frontend changes, contract bump, new models. TDD confirmed (import error before implementation). Narrative never uses technical jargon — enforced by test with 27 banned terms.

### CHG-007: Move CompetitorForm to SEO tab

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Move the CompetitorForm (competitor URL inputs) from the Technical Details tab to the Competitive SEO Report tab.
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-007-move-competitor-form
- **Contract Version**: (unchanged, 1.2.0)
- **Stories**:
  - [x] Move CompetitorForm, SEO polling progress, and SEO error indicators from technical tab to seo tab
- **Files Changed**:
  - `frontend/src/pages/ReportPage.tsx` — moved CompetitorForm + SEO polling/error to seo tab; seoEnabled always true
  - `frontend/src/pages/__tests__/report-page.test.tsx` — 1 new test verifying form placement
- **Tests**: 1 added. Total: 146 frontend tests
- **Review**: APPROVED (INLINE — orchestrator review, all 11 triggers pass, make check + make dod green)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. UI layout change only. SEO tab now always accessible (not locked behind completed report). Out of scope: backend, schema, new components.

### CHG-008: Suggest competitors via Google Places API

- **Date**: 2026-02-07
- **Status**: IN_PROGRESS
- **Labels**: [SCHEMA_CHANGE]
- **Request**: Auto-suggest competitor businesses on the CompetitorForm using Google Places text search, based on user's business_type and location.
- **Scope**: backend + frontend
- **Mode**: STANDARD
- **Branch**: change/CHG-008-suggest-competitors
- **Contract Version**: v1.2.0 → v1.3.0 (new endpoint + new models = additive MINOR)
- **Stories**:
  - [x] Backend: New GET /api/report/suggest-competitors endpoint using PlacesClient.text_search
  - [x] Frontend: Call suggestion endpoint and display clickable suggestions on CompetitorForm
- **Files Changed**:
  - Backend: app/api/suggest.py (new), app/models/schemas.py, app/main.py, tests/test_suggest_competitors.py (new), CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md
  - Frontend: src/types/api.ts, src/services/api-client.ts, src/hooks/useCompetitorSuggestions.ts (new), src/components/CompetitorForm.tsx, src/pages/ReportPage.tsx, src/components/__tests__/competitor-suggestions.test.tsx (new), CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md
- **Tests**: +6 backend, +4 frontend (10 total)
- **Review**: APPROVED (Review Agent — all 11 triggers pass after fixes; make check + make dod green)
- **DoD**: (pending merge)
- **Notes**: Risk: LOW. Confidence: HIGH. Uses existing PlacesClient infrastructure. Review agent fixed: (1) IO layering violation — CompetitorForm was importing useCompetitorSuggestions hook directly, refactored to receive suggestions via props from ReportPage; (2) removed unused waitFor import in test; (3) bumped contract version 1.2.0→1.3.0 and updated all documentation (CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md, CHANGE_MANIFEST.json). Out of scope: changing existing SEO pipeline, modifying Places client.
