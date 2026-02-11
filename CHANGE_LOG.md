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

### CHG-035: Ratchet SOLID thresholds to strict values

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-035: ratchet permissive SOLID thresholds to strict values after all refactoring CHGs complete
- **Scope**: both
- **Mode**: INLINE
- **Branch**: change/CHG-035-ratchet-thresholds
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Ratchet backend check_dod.sh + test_layering.py thresholds (backend)
  - [x] Story 2: Update DEFINITION_OF_DONE.md threshold documentation (workspace)
- **Files Changed**:
  - Backend: scripts/check_dod.sh, tests/test_layering.py, ARCHITECTURE.md, PROGRESS.md
  - Frontend: ARCHITECTURE.md, PROGRESS.md
  - Workspace: DEFINITION_OF_DONE.md
- **Tests**: +0 added, 0 modified (existing 555 backend + 189 frontend pass at strict thresholds)
- **Review**: APPROVED (inline — make check + make dod pass in both repos, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green in both repos)
- **Notes**: Backend line limit ratcheted 1300→800 (not 400 as originally planned — gap_analyzer.py at 775 lines). Backend class limit 35→12. Frontend stays at 400 (CompetitorForm.tsx at 370 lines prevents reaching 300).

### CHG-034: Split SidePanel dual contract

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-034: split SidePanel optional-prop dual rendering into BusinessSidePanel + TechnicalSidePanel single-contract components for LSP
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-034-split-sidepanel
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Extract BusinessSidePanel with required `topImprovements` prop (frontend)
  - [x] Story 2: Extract TechnicalSidePanel with required `issues` prop (frontend)
  - [x] Story 3: Reduce SidePanel to thin dispatcher (frontend)
- **Files Changed**:
  - Frontend: src/components/report/BusinessSidePanel.tsx (NEW), src/components/report/TechnicalSidePanel.tsx (NEW), src/components/report/SidePanel.tsx (97→18 lines), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +0 added, 0 modified (existing 6 side-panel tests pass unchanged via dispatcher)
- **Review**: APPROVED (inline — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 8/8 checks)

### CHG-033: Split BusinessImpactCategories dual rendering

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-033: split BusinessImpactCategories optional-prop dual rendering into PersonalizedCategoryCards + LegacyCategoryCards single-contract components for LSP
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-033-split-business-impact
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Extract PersonalizedCategoryCards with required `insights` prop (frontend)
  - [x] Story 2: Extract LegacyCategoryCards with required `issues` prop (frontend)
  - [x] Story 3: Reduce BusinessImpactCategories to thin dispatcher (frontend)
- **Files Changed**:
  - Frontend: src/components/report/PersonalizedCategoryCards.tsx (NEW), src/components/report/LegacyCategoryCards.tsx (NEW), src/components/report/BusinessImpactCategories.tsx (217→19 lines), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +0 added, 0 modified (existing 10 business-impact tests pass unchanged via dispatcher)
- **Review**: APPROVED (inline — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 8/8 checks)

### CHG-032: Extract page API calls into hooks

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-032: extract apiClient calls from LandingPage and ReportPage into useGovernanceSubmit and useSeoSubmit hooks for DIP
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-032-extract-api-hooks
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Create useGovernanceSubmit hook (frontend)
  - [x] Story 2: Create useSeoSubmit hook (frontend)
  - [x] Story 3: Update LandingPage and ReportPage to use hooks (frontend)
- **Files Changed**:
  - Frontend: src/hooks/useGovernanceSubmit.ts (NEW), src/hooks/useSeoSubmit.ts (NEW), src/pages/LandingPage.tsx, src/pages/ReportPage.tsx, src/hooks/__tests__/useGovernanceSubmit.test.ts (NEW), src/hooks/__tests__/useSeoSubmit.test.ts (NEW), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +9 added, 0 modified (existing 12 report-page + 4 form-submission tests pass unchanged)
- **Review**: APPROVED (inline — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 8/8 checks)

### CHG-031: Extract ReportPage tab content + content map

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-031: extract 4 inline component definitions from ReportPage.tsx into dedicated component files for SRP/OCP
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-031-tab-content-map
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Extract GovernanceContent, BusinessContent, SEOContent, SEOPollingProgress into components/report/ (frontend)
  - [x] Story 2: Replace inline definitions in ReportPage.tsx with imports (frontend)
- **Files Changed**:
  - Frontend: src/components/report/GovernanceContent.tsx (NEW), src/components/report/BusinessContent.tsx (NEW), src/components/report/SEOContent.tsx (NEW), src/components/report/SEOPollingProgress.tsx (NEW), src/pages/ReportPage.tsx, src/components/report/__tests__/tab-content-extraction.test.tsx (NEW), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +7 added, 0 modified (existing 12 report-page tests pass unchanged)
- **Review**: APPROVED (inline — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 8/8 checks)

### CHG-030: Split gemini_summarizer.py with SummarizerProtocol

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-030: split 875-line gemini_summarizer.py into 4 focused modules with SummarizerProtocol for DIP
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-030-summarizer-split
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Create summarizer_protocol.py with PersonalizedContent + SummarizerProtocol (backend)
  - [x] Story 2: Extract deterministic_summarizer.py + personalization_prompt.py (backend)
  - [x] Story 3: Slim gemini_summarizer.py to Gemini API only + barrel re-exports (backend)
- **Files Changed**:
  - Backend: app/reasoning/summarizer_protocol.py (NEW), app/reasoning/deterministic_summarizer.py (NEW), app/reasoning/personalization_prompt.py (NEW), app/reasoning/gemini_summarizer.py, tests/test_summarizer_split.py (NEW), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +12 added, 0 modified (barrel re-exports preserve all existing imports)
- **Review**: APPROVED (standard — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 9/9 checks)

### CHG-029: Crawler protocols for DIP in pipeline steps

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-029: create crawler callable protocols (UrlNormalizer, HtmlFetcher, SitemapParser, PageSampler) and inject them into pipeline step constructors for Dependency Inversion
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-029-crawler-protocols
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Create crawlers/protocols.py with 4 callable protocol types (backend)
  - [x] Story 2: Update step classes to accept injected deps; replace GOVERNANCE_STEPS with build_governance_steps() factory (backend)
  - [x] Story 3: Add H-SOLID-4 DIP enforcement tests to test_layering.py (backend)
- **Files Changed**:
  - Backend: app/crawlers/protocols.py (NEW), app/services/pipeline_steps.py, app/services/pipeline.py, tests/test_crawler_protocols.py (NEW), tests/test_pipeline_steps.py, tests/test_layering.py, ARCHITECTURE.md, PROGRESS.md
- **Tests**: +18 added, 7 modified (GOVERNANCE_STEPS → build_governance_steps)
- **Review**: APPROVED (standard — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 9/9 checks)

### CHG-028: Extract pipeline steps into PipelineStep protocol

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-028: extract 9 pipeline steps from execute_governance_steps into self-contained PipelineStep classes with PipelineContext
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-028-pipeline-steps
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Create PipelineContext mutable dataclass for intermediate state (backend)
  - [x] Story 2: Create 9 PipelineStep classes with run(ctx) method (backend)
  - [x] Story 3: Rewrite execute_governance_steps to iterate GOVERNANCE_STEPS list (backend)
  - [x] Story 4: Update test mock patch targets to pipeline_steps module (backend)
- **Files Changed**:
  - Backend: app/services/pipeline_context.py (NEW), app/services/pipeline_steps.py (NEW), app/services/pipeline.py, tests/test_pipeline_steps.py (NEW), tests/test_pipeline.py, tests/test_seo_pipeline.py, tests/test_error_handling.py, tests/test_business_view.py, ARCHITECTURE.md, PROGRESS.md
- **Tests**: +10 added, 4 modified (patch target updates)
- **Review**: APPROVED (standard — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 9/9 checks)

---

### CHG-027: Extract report-building functions from pipeline.py

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-027: extract ~570 lines of pure report-building logic from pipeline.py into reasoning/report_builder.py and services/error_classifier.py
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-027-report-builder
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: Extract build_executive_summary, build_metrics, build_top_improvements, LIMITATIONS to reasoning/report_builder.py (backend)
  - [x] Story 2: Extract PipelineCrawlError, categorize_fetch_error, is_html_content to services/error_classifier.py (backend)
  - [x] Story 3: Wire pipeline.py to use new modules with backward-compat aliases (backend)
- **Files Changed**:
  - Backend: app/reasoning/report_builder.py (NEW), app/services/error_classifier.py (NEW), app/services/pipeline.py, tests/test_report_builder.py (NEW), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +18 added, 0 modified
- **Review**: APPROVED (inline — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 9/9 checks)

---

### CHG-026: Detector protocol and registry in engine.py

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: SOLID refactoring plan — CHG-026: eliminate OCP violation in engine.py
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-026-detector-registry
- **Contract Version**: v1.8.0 (unchanged)
- **Stories**:
  - [x] Story 1: DetectorContext + RegisteredDetector + DETECTOR_REGISTRY + @register_detector in protocols.py (backend)
  - [x] Story 2: Self-registration adapters in all 8 detector modules (backend)
  - [x] Story 3: Rewrite engine.py to iterate registry (backend)
  - [x] Story 4: Move merge functions to detector modules (backend)
- **Files Changed**:
  - Backend: app/detectors/protocols.py (NEW), app/detectors/__init__.py, app/detectors/engine.py, app/detectors/stack_detector.py, app/detectors/integration_detector.py, app/detectors/a11y_detector.py, app/detectors/security_detector.py, app/detectors/site_age_detector.py, app/detectors/partner_detector.py, app/detectors/complexity_detector.py, app/reasoning/inventory_analyzer.py, tests/test_detector_registry.py (NEW), ARCHITECTURE.md, PROGRESS.md
- **Tests**: +8 added, 0 modified
- **Review**: APPROVED (inline — make check + make dod pass, no auto-reject triggers)
- **DoD**: PASSED (`make dod` green, all 9/9 checks)

---

### CHG-025: Split schemas.py into domain-grouped modules

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Split monolithic schemas.py (34 classes) into 6 domain-grouped modules for SRP/ISP improvement.
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-025-split-schemas
- **Contract Version**: (unchanged, 1.8.0)
- **Stories**:
  - [x] Story 1: Split 34 classes into 6 domain files with barrel re-export in schemas.py
- **Files Changed**:
  - Backend: `app/models/enums.py` (new), `app/models/requests.py` (new), `app/models/governance.py` (new), `app/models/seo.py` (new), `app/models/responses.py` (new), `app/models/transparency.py` (new), `app/models/schemas.py` (rewritten as barrel), `tests/test_schema_split.py` (new)
- **Tests**: +14 added (test_schema_split.py)
- **Review**: APPROVED (INLINE review — all auto-reject triggers pass, `make check` + `make dod` green)
- **DoD**: PASSED (`make dod` green)
- **Out of Scope**: Changing model fields, renaming classes, modifying consumers, strict class count threshold (CHG-035)

---

### CHG-024: Add SOLID compliance checks to DoD and review process

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Embed SOLID principle checks into the Review Agent, DoD enforcement scripts, and test_layering.py so regressions are caught automatically.
- **Scope**: both + workspace
- **Mode**: INLINE
- **Branch**: change/CHG-024-solid-compliance-checks
- **Contract Version**: (unchanged, 1.8.0)
- **Stories**:
  - [ ] Story 1: Add SOLID hard gates to check_dod.sh (both repos) + test_layering.py with permissive thresholds
  - [ ] Story 2: Add SOLID review items to DEFINITION_OF_DONE.md + update Review Agent template
- **Files Changed**:
  - Workspace: `DEFINITION_OF_DONE.md`, `CHANGE_PROCESS.md`, `CLAUDE.md`
  - Backend: `scripts/check_dod.sh`, `tests/test_layering.py`
  - Frontend: `scripts/check_dod.sh`
- **Tests**: +3 added (TestClassCountEnforcement, TestModuleLineCounts, TestNoLiveCallsInTests updated) in backend test_layering.py
- **Review**: APPROVED (INLINE)
- **DoD**: PASSED (`make dod` green in both repos)
- **Out of Scope**: Refactoring any existing production code; strict threshold enforcement (that's CHG-035)

---

### CHG-023: Pipeline Performance Optimization

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE]
- **Request**: Pipeline slow due to duplicate page fetching, redundant robots.txt requests, and 3×N per-issue Gemini calls; optimize all three and batch Gemini into single call with issue_insights in Business Overview
- **Scope**: both
- **Mode**: STANDARD
- **Branch**: change/CHG-023-pipeline-perf
- **Contract Version**: 1.7.0 → 1.8.0
- **Stories**:
  - [x] Story 1: robots.txt cache — eliminate redundant same-domain fetches (backend)
  - [x] Story 2: Eliminate duplicate page fetching + parallelize sampler (backend)
  - [x] Story 3: Batch Gemini into single call + issue_insights in Business Overview (both)
- **Files Changed**:
  - Backend: `app/crawlers/html_fetcher.py`, `app/crawlers/page_sampler.py`, `app/services/pipeline.py`, `app/reasoning/gemini_summarizer.py`, `app/models/schemas.py`, `tests/test_html_fetcher.py`, `tests/test_page_sampler.py`, `tests/test_pipeline.py`, `tests/test_gemini_summarizer.py`, `tests/test_error_handling.py`, `tests/test_seo_pipeline.py`, `tests/fixtures/reports/governance-report.json`, `CONTRACTS.md`, `ARCHITECTURE.md`, `PROGRESS.md`
  - Frontend: `src/types/api.ts`, `src/components/report/ExecutiveStory.tsx`, `src/pages/ReportPage.tsx`, `src/components/report/__tests__/executive-story.test.tsx`, `src/mocks/golden/governance-report.json`, `CONTRACTS.md`, `ARCHITECTURE.md`, `PROGRESS.md`
- **Tests**: +16 added (13 backend + 3 frontend), 6 modified
- **Out of Scope**: Shared httpx client (SSRF risk), persistent cross-run caching, redesigning issue detail panel, changing SEO report
- **Review**: APPROVED
- **DoD**: PASSED (`make dod` green in both repos)
- **Notes**: Reduces Gemini calls from 3N+1 to 1. Eliminates ~19 redundant robots.txt fetches and double page fetching. Pipeline reuses sampler soups directly. Business Overview shows "Key Findings" blue-bordered list from batch issue_insights.

---

### CHG-022: Concurrent Page Fetching

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Pipeline still timing out because sequential page soup collection takes ~300s worst-case; convert to concurrent fetching
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-022-concurrent-page-fetch
- **Contract Version**: 1.7.0 (no change)
- **Stories**:
  - [x] Story 1: Concurrent soup fetching with asyncio.gather + semaphore
  - [x] Story 2: Config setting max_concurrent_page_fetches (default 5)
  - [x] Story 3: Tests + documentation
- **Files Changed**: `app/services/pipeline.py`, `app/core/config.py`, `.env.example`, `tests/test_pipeline.py`, `tests/test_seo_pipeline.py`, `tests/test_error_handling.py`, `ARCHITECTURE.md`, `PROGRESS.md`
- **Tests**: +6 new, 3 modified (mock settings in seo_pipeline, error_handling, pipeline)
- **Out of Scope**: Per-domain rate limiting, parallelizing other pipeline steps (PSI, Gemini), adaptive concurrency
- **Review**: APPROVED
- **DoD**: PASSED
- **Notes**: Reduces worst-case soup collection from ~300s (20×15s sequential) to ~60s (4 batches × 15s). Semaphore prevents Playwright resource exhaustion.

---

### CHG-021: Increase Pipeline Timeout to 750s

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Pipeline failing after 450s with expanded detectors and Gemini prompts; increase to 750s
- **Scope**: backend-only
- **Mode**: INLINE
- **Branch**: change/CHG-021-increase-timeout-750
- **Contract Version**: 1.7.0 (no change)
- **Stories**:
  - [x] Story 1: `pipeline_timeout_seconds` 450→750
- **Files Changed**: `app/core/config.py`, `.env.example`, `app/services/pipeline.py` (docstring), `ARCHITECTURE.md`, `tests/test_pipeline.py`, `tests/test_error_handling.py`, `tests/test_health.py`
- **Tests**: 0 new (existing assertions updated 450→750)
- **Out of Scope**: dynamic/per-URL timeout config, timeout alerting, changing fetch_timeout_seconds
- **Review**: INLINE
- **DoD**: PASSED
- **Notes**: Config-only change. Needed after CHG-014/015/019/020 added more pipeline work.

---

### CHG-020: Honest 5+5 Bulleted Lists in Business Overview

- **Date**: 2026-02-10
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Add personalized 5 strengths + 5 fixes as bulleted lists (not pills), honest tone, page-level references, not salesy
- **Scope**: both
- **Mode**: STANDARD
- **Branch**: change/CHG-020-honest-5x5-lists
- **Contract Version**: 1.7.0 (no change)
- **Stories**:
  - [x] Story 1: Gemini generates personalized 5+5 lists (backend)
  - [x] Story 2: Frontend renders bulleted lists instead of pills
  - [x] Story 3: Fixtures + documentation
- **Files Changed**:
  - Backend: `app/reasoning/gemini_summarizer.py`, `app/services/pipeline.py`, `tests/test_personalized_report.py`, `tests/fixtures/reports/governance-report.json`
  - Frontend: `src/components/report/ExecutiveStory.tsx`, `src/components/report/__tests__/executive-story.test.tsx`, `src/components/report/__tests__/executive-summary.test.tsx`, `src/mocks/golden/governance-report.json`
- **Tests**: 12 new backend tests, 8 rewritten frontend tests (458 backend / 170 frontend)
- **Review**: PASS — no auto-reject triggers
- **DoD**: PASS — all gates (backend 7/7, frontend 6/6)
- **Notes**: No schema change — SummaryItem already has title+description, frontend just didn't render description. PersonalizedContent dataclass gains whats_working + needs_attention fields. Gemini prompt expanded with page context, foundation signals, honest tone rules. Deterministic fallback produces 5 items each with padding.

---

### CHG-019: Fix zip() length mismatch in page/soup collection

- **Date**: 2026-02-09
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Fix "zip() argument 2 is shorter than argument 1" runtime error when some sampled pages fail to re-fetch
- **Scope**: backend-only
- **Mode**: INLINE
- **Branch**: change/CHG-019-fix-zip-mismatch
- **Contract Version**: 1.7.0 (no change)
- **Stories**:
  - [x] Story 1: Fix page/soup sync in pipeline — Risk: LOW
- **Files Changed**:
  - Backend: `app/services/pipeline.py`, `tests/test_pipeline.py`
- **Tests**: +1 added
- **Review**: INLINE (code review in-line)
- **DoD**: PASSED (`make dod` green, `make check` green)
- **Notes**: Pre-existing bug where failed page re-fetches caused pages[] and soups[] to have different lengths, crashing run_detectors(). Fix builds both lists in lockstep.

---

### CHG-018: Segment-Aware Personalized Business Overview

- **Date**: 2026-02-09
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE]
- **Request**: Build 3-segment personalized Business Overview (Revenue-Driven, Risk-Aware, Oversight) with aggressive LLM usage for website-specific, segment-aware report content.
- **Scope**: both
- **Mode**: STANDARD
- **Branch**: change/CHG-018-segment-personalization
- **Contract Version**: 1.6.0 → 1.7.0
- **Stories**:
  - [x] Story 1: Segment Classifier Module — Risk: LOW
  - [x] Story 2: Schema + Foundation Signal Wiring — Risk: LOW
  - [x] Story 3: LLM Personalized Report Generation — Risk: MEDIUM
  - [x] Story 4: Frontend Segment-Aware Rendering — Risk: LOW
  - [x] Story 5: Contract Sync + Documentation — Risk: LOW
  - Out of Scope: Adding new BusinessType enum values, multiple Gemini calls, modifying issue templates, SEO tab changes, ENGINEERING_PLAN.md
- **Files Changed**:
  - Backend: `app/reasoning/segment_classifier.py` (new), `app/models/schemas.py`, `app/reasoning/gemini_summarizer.py`, `app/services/pipeline.py`, `tests/test_segment_classifier.py` (new), `tests/test_personalized_report.py` (new), `tests/test_pipeline.py`, `tests/fixtures/reports/governance-report.json`
  - Frontend: `src/types/api.ts`, `src/components/report/BusinessImpactCategories.tsx`, `src/pages/ReportPage.tsx`, `src/components/report/__tests__/business-impact-categories.test.tsx`, `src/mocks/golden/governance-report.json`
  - Docs: `CHANGE_MANIFEST.json`, `CHANGE_LOG.md`, backend/frontend `CONTRACTS.md`, `ARCHITECTURE.md`, `PROGRESS.md`
- **Tests**: +54 added (31 segment classifier + 18 personalized report + 5 frontend), 1 modified (test_pipeline.py)
- **Review**: APPROVED — 0 auto-reject triggers, 3 non-blocking observations
- **DoD**: PASSED (`make dod` green in both repos)
- **Notes**: Three segments: dental/clinic/healthcare → Revenue-Driven; construction/logistics/manufacturing/professional_services → Risk-Aware; ngo/education → Oversight. LLM generates structured JSON (narrative + 4 category insights + 3 improvements) in ONE call. Deterministic fallback is segment-aware.

---

### CHG-017: Playwright CDP fallback for PSI API failures

- **Date**: 2026-02-09
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: When PSI API fails for a site (e.g., NO_FCP error), fall back to local Playwright CDP-based performance measurement so reports always have performance data.
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-017-cdp-psi-fallback
- **Contract Version**: 1.6.0 (unchanged)
- **Stories**:
  - [x] Story 1: CDP performance measurement module (cdp_perf_client.py)
  - [x] Story 2: PSI client CDP integration (fallback in psi_client.py)
  - [x] Story 3: Verify transparent integration
  - Out of Scope: Network/CPU throttling, Speed Index, persistent browser pools, screenshots, making CDP primary, separate CDP timeout config, E2E testing against real sites
- **Files Changed**:
  - Backend: app/services/cdp_perf_client.py (new), app/services/psi_client.py (modified), tests/test_cdp_perf_client.py (new), tests/test_psi_client.py (modified)
- **Tests**: +21 added (15 CDP + 6 fallback), 0 modified → 395 BE total
- **Review**: APPROVED (inline review — all 11 auto-reject triggers pass)
- **DoD**: PASSED (`make dod` green — all 7 checks)
- **Notes**: PSI API returns NO_FCP for sites like vanillasmiles.dental where Google's Lighthouse servers can't render the page. CDP fallback uses local headless Chromium.

---

### CHG-013: SEO pipeline reuse governance results

- **Date**: 2026-02-08
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE]
- **Request**: When submitting the SEO report after a governance report, reuse the already-computed governance data instead of re-running all 9 governance steps (crawl, detect, PSI, etc.).
- **Scope**: both (backend + frontend)
- **Mode**: STANDARD
- **Branch**: change/CHG-013-seo-reuse-governance
- **Contract Version**: 1.4.0 → 1.5.0 (additive: optional `governance_job_id` field on `SEOReportRequest`)
- **Stories**:
  - [x] Cache `GovernancePipelineData` on `JobRecord` after governance pipeline completes
  - [x] Accept optional `governance_job_id` in SEO request, skip governance steps if valid cached data exists
  - [x] Frontend passes governance `jobId` when submitting SEO report
  - Out of Scope: persistent caching, TTL eviction, sharing results across IPs, changing the /full endpoint
- **Files Changed**:
  - Backend: app/models/schemas.py, app/services/job_manager.py, app/services/pipeline.py, app/services/seo_pipeline.py, ARCHITECTURE.md, CONTRACTS.md, PROGRESS.md
  - Frontend: src/types/api.ts, src/pages/ReportPage.tsx, src/components/CompetitorForm.tsx, ARCHITECTURE.md, CONTRACTS.md, PROGRESS.md
- **Tests**: +8 added (6 backend + 2 frontend) → 315 BE, 161 FE, 476 total
- **Review**: APPROVED (STANDARD — Review Agent verified 11 auto-reject triggers, backward compatibility, fallback safety, IO boundary, contract sync)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. Backward-compatible — fallback to full pipeline if governance_job_id missing or invalid. TDD confirmed (tests failed before implementation).

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
- **Status**: COMPLETE
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
- **Status**: COMPLETE
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
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. Uses existing PlacesClient infrastructure. Review agent fixed: (1) IO layering violation — CompetitorForm was importing useCompetitorSuggestions hook directly, refactored to receive suggestions via props from ReportPage; (2) removed unused waitFor import in test; (3) bumped contract version 1.2.0→1.3.0 and updated all documentation (CONTRACTS.md, ARCHITECTURE.md, PROGRESS.md, CHANGE_MANIFEST.json). Out of scope: changing existing SEO pipeline, modifying Places client.

### CHG-009: Demo mode for instant report generation

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Add DEMO_MODE env variable that skips all real crawling/PSI/Gemini calls and returns golden fixture data instantly, for local development and testing.
- **Scope**: backend only
- **Mode**: INLINE
- **Branch**: change/CHG-009-demo-mode
- **Contract Version**: unchanged (1.3.0)
- **Stories**:
  - [x] Add `demo_mode: bool = False` to Settings
  - [x] Governance pipeline short-circuits to golden fixture when demo_mode=True
  - [x] SEO pipeline short-circuits to golden fixture when demo_mode=True
  - [x] Suggest-competitors endpoint returns hardcoded demo data when demo_mode=True
  - [x] Existing tests patched to explicitly set demo_mode=False
- **Files Changed**: app/core/config.py, app/services/pipeline.py, app/services/seo_pipeline.py, app/services/demo_fixture.py (new), app/api/suggest.py, .env.example, tests/test_demo_mode.py (new), tests/test_pipeline.py, tests/test_seo_pipeline.py, tests/test_error_handling.py, tests/test_suggest_competitors.py
- **Tests**: +9 new (292 total backend)
- **Review**: APPROVED (INLINE — orchestrator review)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. Production safety: demo_mode defaults to False. No schema/contract change. Out of scope: frontend, production deployment.

### CHG-010: Fix golden fixture narrative drift

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Golden fixture `executive_narrative` was stale (pre-CHG-006 technical language). Update to match current business-goal-aware narrative format. Add drift guard test and process rule.
- **Scope**: backend + frontend
- **Mode**: INLINE
- **Branch**: change/CHG-010-fix-fixture-drift
- **Contract Version**: unchanged (1.3.0)
- **Stories**:
  - [x] Update backend fixture narrative to business-goal language
  - [x] Update frontend fixture narrative to match
  - [x] Add drift guard test (jargon ban list on fixture narrative)
  - [x] Update frontend test assertions for new narrative text
  - [x] Add "Golden Fixtures" section to DEFINITION_OF_DONE.md
- **Files Changed**:
  - Backend: tests/fixtures/reports/governance-report.json, tests/test_business_narrative.py
  - Frontend: src/mocks/golden/governance-report.json, src/components/report/__tests__/executive-story.test.tsx, src/pages/__tests__/report-page.test.tsx
  - Process: DEFINITION_OF_DONE.md
- **Tests**: +1 new drift guard test (293 backend total)
- **Review**: APPROVED (INLINE)
- **DoD**: PASSED
- **Notes**: Root cause — CHG-006 changed narrative generation but did not update golden fixtures. New drift guard test prevents recurrence. New DoD section "Golden Fixtures" added.

### CHG-011: Improve competitor suggestion relevance + Google review card

- **Date**: 2026-02-07
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE] [PROCESS_VIOLATION]
- **Request**: Competitor suggestions for skinsureclinic.com returned generic medical clinics instead of dermatology clinics. Need more relevant competitors based on actual business specialty, area-aware search, and a Google review card for the user's clinic.
- **Scope**: both
- **Mode**: STANDARD
- **Branch**: change/CHG-011-improve-competitor-suggestions
- **Contract Version**: v1.3.0 → v1.4.0 (additive — new `user_place` field on SuggestCompetitorsResponse)
- **Stories**:
  - [x] Backend: Two-step search — find user's place on Google Places by domain → extract specific types + area → search for competitors with those types near that area
  - [x] Backend: Add `user_place` to `SuggestCompetitorsResponse` schema
  - [x] Backend: Add `websiteUri` to PlacesClient field mask + `website_url` to PlaceResult
  - [x] Backend: Filter out user's own place from competitor results (by place_id + domain)
  - [x] Frontend: Pass `websiteUrl` to `useCompetitorSuggestions` hook → API
  - [x] Frontend: Display Google Business Profile review card for user's clinic
  - [x] Frontend: Update types, api-client, hook for new response shape
- **Files Changed**:
  - Backend: app/api/suggest.py (rewritten), app/models/schemas.py, app/services/places_client.py, tests/test_suggest_competitors.py (rewritten, 22 tests), CONTRACTS.md, ARCHITECTURE.md
  - Frontend: src/types/api.ts, src/services/api-client.ts, src/hooks/useCompetitorSuggestions.ts, src/components/CompetitorForm.tsx, src/pages/ReportPage.tsx, src/components/__tests__/competitor-suggestions.test.tsx (8 tests), CONTRACTS.md, ARCHITECTURE.md
- **Tests**: +16 backend (309 total), +4 frontend (154 total)
- **Review**: APPROVED (STANDARD — orchestrator review, all checks green)
- **DoD**: PASSED
- **Notes**: Risk: MEDIUM (IO module + schema change). Confidence: HIGH. Root cause: suggest endpoint mapped "clinic" → "medical clinic" generically instead of using the website's actual Google Place types (e.g., "dermatologist"). Two-step search now: (1) find user's business by domain, (2) use its specific types for competitor search. Out of scope: changing PlacesClient internals, modifying SEO pipeline, adding new API endpoints.
- **Process Violations** (retroactive audit):
  1. No feature branches created in submodules — committed directly to main
  2. No `--no-ff` merge commits — fast-forward commits on main
  3. No MERGE_TRANSACTIONS.md entry logged
  4. No Review Agent spawned despite STANDARD mode declaration
  5. No TDD fail-first evidence shown
  - **Remediation**: `validate_change.sh` script created to prevent recurrence

### CHG-014: Phase 1 Foundation Signals

- **Date**: 2026-02-09
- **Status**: COMPLETE
- **Labels**: [SCHEMA_CHANGE]
- **Request**: Implement Phase 1 Foundation Signals from the 150+ signal integration analysis. Add SiteAgeSignals, PartnerSignals, ComplexityFlags, SiteInventorySignals, and TechnicalDebtSignals to establish "owner who never forgot" baseline.
- **Scope**: backend-only
- **Mode**: STANDARD
- **Branch**: change/CHG-014-foundation-signals
- **Contract Version**: v1.5.0 → v1.6.0 (additive: 15 new fields on GovernanceReport)
- **Stories**:
  - [x] SiteAgeSignals detector (copyright_year, blog_last_post_date, sitemap_latest_lastmod, update_cadence)
  - [x] PartnerSignals detector (agency_name, agency_credit_url, link validation)
  - [x] ComplexityFlags detector (login_link_present, app_routes_on_same_host, multi_locale)
  - [x] SiteInventorySignals analyzer (page_count_estimate, templates_estimate, top_sections)
  - [x] TechnicalDebtSignals scorer (technical_debt_score, missing_semantic_html, high_inline_style_ratio)
  - [x] Schema evolution (15 new fields on GovernanceReport)
  - [ ] Reasoning templates (stale_content, agency_link_dead, hidden_complexity, copyright_outdated, technical_debt_high)
  - [ ] Pipeline integration (wire new detectors into governance pipeline)
  - Out of Scope: Golden fixture updates, frontend changes, new metric cards, UI integration
- **Files Changed**:
  - Backend: app/detectors/site_age_detector.py (new), app/detectors/partner_detector.py (new), app/detectors/complexity_detector.py (new), app/reasoning/inventory_analyzer.py (new), app/reasoning/technical_debt_scorer.py (new), app/models/schemas.py, tests/test_site_age_detector.py (new, 13 tests), tests/test_partner_detector.py (new, 9 tests), tests/test_complexity_detector.py (new, 13 tests), tests/test_inventory_analyzer.py (new, 10 tests), tests/test_technical_debt_scorer.py (new, 9 tests), ARCHITECTURE.md, CONTRACTS.md, PROGRESS.md
- **Tests**: +54 added (13 + 9 + 13 + 10 + 9) → 369 BE total
- **Review**: APPROVED (inline review - all 11 auto-reject triggers passed, scope discipline verified)
- **DoD**: PASSED (make dod green, all checklist items verified)
- **Notes**: Risk: MEDIUM (schema change + new modules). Confidence: HIGH. TDD followed strictly (all 54 tests written first, failed, then passed). Phase 1 of 4-phase Foundation Signals roadmap (6 weeks total).

### CHG-012: Click competitor suggestion to fill URL input

- **Date**: 2026-02-08
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: When clicking a competitor suggestion card, fill the next empty competitor URL input with the card's website URL. If no website URL, show "This business has no website" message.
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-012-click-suggestion-fill-url
- **Contract Version**: (unchanged, 1.4.0)
- **Stories**:
  - [ ] Click suggestion card with website_url → fill next empty competitor URL field
  - [ ] Click suggestion card without website_url → show "no website" message
  - Out of Scope: changing suggestion API, drag-and-drop, suggestion card layout redesign, allowing >3 competitors
- **Files Changed**:
  - Frontend: src/components/CompetitorForm.tsx, src/components/__tests__/competitor-suggestions.test.tsx, ARCHITECTURE.md, PROGRESS.md
- **Tests**: +5 added (159 frontend total)
- **Review**: APPROVED (INLINE — orchestrator review, all 11 triggers pass, make check + make dod green)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. Pure UI interaction — no API/schema/IO changes. TDD confirmed (5 tests failed before implementation).

### CHG-015: Phase 1 Foundation Signals - Pipeline Integration (Completes CHG-014)

**Status**: COMPLETE
**Date Started**: 2026-02-09
**Date Completed**: 2026-02-09
**Scope**: backend + frontend
**Branch**: change/CHG-015-phase1-pipeline-integration
**Mode**: STANDARD

**Description**:
Completes CHG-014 deferred stories 7-8: create 5 reasoning templates for Foundation Signals (stale_content, agency_link_dead, hidden_complexity, copyright_outdated, technical_debt_high) + wire new detectors into governance pipeline + update issue_builder + update golden fixtures.

**User Story**:
As a governance-focused user, I want to see issues surfaced when my site has stale content, dead agency links, hidden complexity, outdated copyright, or high technical debt, so I understand maintenance risks.

**Stories**:
1. ✓ Create 5 reasoning templates for Foundation Signals (stale_content, agency_link_dead, hidden_complexity, copyright_outdated, technical_debt_high) — Risk: LOW
2. ✓ Wire new detectors into pipeline step 5 + update issue_builder to inspect new signals + update golden fixtures — Risk: MEDIUM

**Dependencies**: CHG-014 (detectors + schema already merged)

**Out of Scope**:
- Frontend UI changes (metric cards, tabs) — deferred to future work
- SEO pipeline changes — Foundation Signals are governance-only
- Modifying existing templates — all templates remain unchanged

**Risks**:
- Pipeline integration errors if detector interfaces change ← Mitigated by integration tests
- Golden fixtures may drift if not updated consistently ← Fixed via automated update script

**Files Changed**:
- backend/app/reasoning/templates.py — added 5 new templates (#28-32) to registry
- backend/app/reasoning/issue_builder.py — added Foundation Signals inspection in _collect_raw_issues()
- backend/app/detectors/engine.py — expanded DetectorResults + run_detectors() to call 4 new detectors
- backend/app/services/pipeline.py — pass sitemap_urls to run_detectors(), call score_technical_debt() after PSI
- backend/tests/fixtures/reports/governance_report.json — added 15 new CHG-014 fields with sample data
- frontend/src/mocks/golden/governance-report.json — added 15 new CHG-014 fields with sample data
- backend/tests/test_templates.py — added 5 new signal IDs to REQUIRED_SIGNAL_IDS
- backend/tests/test_foundation_signals_integration.py — NEW FILE: 9 integration tests

**Tests**:
- Backend: +9 tests (9 Foundation Signals integration tests)
- Frontend: 0 (no UI changes)
- Total: +9 (378 backend tests total)

**Review**: APPROVED
**DoD**: PASSED
**Merge Commit**: (backend: pending, frontend: pending)
**Completion Date**: 2026-02-09


### CHG-016: Business-First Foundation Signals View

- **Date**: 2026-02-09
- **Status**: COMPLETE
- **Labels**: (none)
- **Request**: Show ONLY high-confidence observed issues in Business Overview; redesign category cards to lead with business impact instead of severity scores.
- **Scope**: frontend-only
- **Mode**: INLINE
- **Branch**: change/CHG-016-business-first-view
- **Contract Version**: (unchanged, 1.6.0)
- **Stories**:
  - [x] Filter Business Overview by confidence (HIGH + OBSERVED only) — Risk: LOW
  - [x] Redesign BusinessImpactCategories cards (business impact first) — Risk: LOW
  - Out of Scope: Backend changes, Technical Details tab (shows all issues), narrative enhancement
- **Files Changed**:
  - Frontend: src/pages/ReportPage.tsx, src/components/report/BusinessImpactCategories.tsx, src/components/report/__tests__/business-impact-categories.test.tsx, ARCHITECTURE.md
- **Tests**: 0 added (161 total, 4 updated)
- **Review**: APPROVED (INLINE — make check + make dod green, no auto-reject triggers)
- **DoD**: PASSED
- **Notes**: Risk: LOW. Confidence: HIGH. Pure UI filtering/display logic. Foundation Signals like `stale_content` (MEDIUM + INFERRED) now hidden in Business Overview, `copyright_outdated` (HIGH + OBSERVED) shown. Business language replaces technical jargon.

