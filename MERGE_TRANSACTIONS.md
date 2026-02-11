# Merge Transaction Log

> Append-only audit trail for cross-repo merges.
> Every merge gate execution logs an entry here, regardless of outcome.
> Never delete entries.

<!-- Template for new entries:

### TX-YYYY-MM-DD-HH:MM — CHG-NNN
- **status:** STARTED | COMPLETED | ROLLED_BACK | FAILED
- **backend_branch:** change/CHG-NNN-... (or "n/a")
- **frontend_branch:** change/CHG-NNN-... (or "n/a")
- **backend_merge_commit:** <sha> (or "n/a")
- **frontend_merge_commit:** <sha> (or "n/a")
- **manifest_commit:** <sha> (or "n/a")
- **notes:** <what happened>

-->

### TX-2026-02-07-001 — CHG-001
- **status:** COMPLETED
- **backend_branch:** change/CHG-001-increase-limits-cta
- **frontend_branch:** change/CHG-001-increase-limits-cta
- **backend_merge_commit:** b3abc1172e8b2c26cf85c3328d5dec45b8dec0aa
- **frontend_merge_commit:** 3f78b7548ea0ae6c82aa589a9947fc2290327c60
- **manifest_commit:** (workspace root, uncommitted)
- **notes:** Clean merge. Both repos merged with --no-ff. Contract v1.1.0. 354 tests total.

### TX-2026-02-07-002 — CHG-002
- **status:** COMPLETED
- **backend_branch:** change/CHG-002-increase-timeout-450
- **frontend_branch:** n/a
- **backend_merge_commit:** be8fe7db4325b714a44efb1b572e2a74d85aaaf6
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only config change. pipeline_timeout_seconds 180→450. No contract change. (CHG-002 — reverted, process not followed)

### TX-2026-02-07-003 — CHG-003
- **status:** COMPLETED
- **backend_branch:** change/CHG-003-increase-timeout-450
- **frontend_branch:** n/a
- **backend_merge_commit:** 11dd2d9f8797d14cc557e7ce78910482e1c7aa84
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Redo of CHG-002 with full 8-step process. pipeline_timeout_seconds 180→450. Review Agent approved. All 11 triggers pass.

### TX-2026-02-07-004 — CHG-004
- **status:** COMPLETED
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-004-fix-progress-percentage
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** d71af697d3bd8cc2786af4d16f8cbecd10fb69ba
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. ProgressBar showed raw 0.0–1.0 as percentage instead of multiplying by 100. Fixed component + corrected mock data in report-page tests. 5 new tests added. INLINE mode.

### TX-2026-02-07-005 — CHG-005
- **status:** COMPLETED
- **backend_branch:** change/CHG-005-two-view-report
- **frontend_branch:** change/CHG-005-two-view-report
- **backend_merge_commit:** ab6af00334855f88b8c7965923ec7afc7281c44f
- **frontend_merge_commit:** 4294761d92c705d7e798b5dee95c5c845acf1519
- **manifest_commit:** (workspace root)
- **notes:** Two-view report: Business Overview (default) + Technical Details tabs. 38 new tests (20 backend, 18 frontend). Contract 1.1.0 → 1.2.0 (additive). Schema: executive_narrative, business_category, TopImprovement, top_improvements. Review Agent approved, 4 fix commits. STANDARD mode.

### TX-2026-02-07-006 — CHG-006
- **status:** COMPLETED
- **backend_branch:** change/CHG-006-business-narrative
- **frontend_branch:** n/a
- **backend_merge_commit:** 40e6bb98c87b62ef4f677bc8c93ea01eea3e2da0
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Rewrote executive narrative to frame around predicted business goals. New module business_goals.py. No schema change. 25 new tests. INLINE mode.

### TX-2026-02-07-007 — CHG-007
- **status:** COMPLETED
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-007-move-competitor-form
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** 3b96e996f72fa16446d5dab947d1e8c72e6dc4c8
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. Moved CompetitorForm from Technical Details tab to Competitive SEO tab. SEO tab always accessible. 1 new test. INLINE mode.

### TX-2026-02-07-008

- **status:** COMPLETED
- **change_id:** CHG-008
- **backend_branch:** change/CHG-008-suggest-competitors
- **frontend_branch:** change/CHG-008-suggest-competitors
- **backend_merge_commit:** 20dd23935c126412637fd935ced9e5afe78956ae
- **frontend_merge_commit:** 8cf5234e4a5b77a5921de5404466c95eef026369
- **manifest_commit:** (workspace root)
- **notes:** Both repos. New suggest-competitors endpoint (backend) + suggestion cards UI (frontend). Contract 1.2.0→1.3.0. 10 new tests (6 backend + 4 frontend). STANDARD mode.

### TX-2026-02-07-009

- **status:** COMPLETED
- **change_id:** CHG-009
- **backend_branch:** change/CHG-009-demo-mode
- **frontend_branch:** n/a
- **backend_merge_commit:** 753d7b28108c76b2100caf3da7fed8bb5ddb41e7
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Demo mode for instant report generation. 9 new tests. INLINE mode.

### TX-2026-02-07-010

- **status:** COMPLETED
- **change_id:** CHG-010
- **backend_branch:** change/CHG-010-fix-fixture-drift
- **frontend_branch:** change/CHG-010-fix-fixture-drift
- **backend_merge_commit:** a20049ab19e7ee714be7279ac6621973ce2a6171
- **frontend_merge_commit:** 37f5aefcd1a524d8107583d250b9b47db7812280
- **manifest_commit:** (workspace root)
- **notes:** Both repos. Fix golden fixture narrative drift. 1 new drift guard test. Process update: DEFINITION_OF_DONE.md. INLINE mode.

### TX-2026-02-07-011 — CHG-011 [PROCESS_VIOLATION]

- **status:** COMPLETED (retroactive — logged after audit)
- **change_id:** CHG-011
- **backend_branch:** n/a (VIOLATION: committed directly to main, no feature branch)
- **frontend_branch:** n/a (VIOLATION: committed directly to main, no feature branch)
- **backend_merge_commit:** 34bbe4c01ec51f92bf23bde9917a254e905eb0a5 (direct commit, not --no-ff merge)
- **frontend_merge_commit:** 54420cfe30cef747ab8f86487f519e35f73a10c6 (direct commit, not --no-ff merge)
- **manifest_commit:** (workspace root)
- **notes:** RETROACTIVE ENTRY. CHG-011 was executed without proper merge protocol: no submodule feature branches, no --no-ff merge, no MERGE_TRANSACTIONS entry, no Review Agent despite STANDARD mode. Code is functional and tests pass, but process was violated. Remediated by creating validate_change.sh enforcement script and hardening change-agent.mdc rule.

### TX-2026-02-08-012 — CHG-012

- **status:** COMPLETED
- **change_id:** CHG-012
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-012-click-suggestion-fill-url
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** df0c8869a33f03f22b94c3888478637e388b8d1f
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. Click suggestion card to fill competitor URL input. 5 new tests. INLINE mode. Full process followed.

### TX-007 — CHG-013

- **status:** COMPLETED
- **change_id:** CHG-013
- **backend_branch:** change/CHG-013-seo-reuse-governance
- **frontend_branch:** change/CHG-013-seo-reuse-governance
- **backend_merge_commit:** 04da9065e9726b0a7b0ada3edb9ff3b957f0991a
- **frontend_merge_commit:** b8a3b1a02ac8ca319820f360b3d8988b2e071deb
- **manifest_commit:** (workspace root)
- **notes:** SEO pipeline reuses governance results. 8 new tests (6 BE + 2 FE). Contract 1.4.0→1.5.0. STANDARD mode. Full process followed.

### TX-2026-02-09-014 — CHG-014

- **status:** COMPLETED
- **change_id:** CHG-014
- **backend_branch:** change/CHG-014-foundation-signals
- **frontend_branch:** n/a
- **backend_merge_commit:** 7ea260bd0e962683ef9fdfae435434198589cf4a
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Phase 1 Foundation Signals. 5 new detector/analyzer modules (site_age, partner, complexity, inventory, technical_debt). 15 new GovernanceReport fields. 54 new tests. Contract 1.5.0→1.6.0. STANDARD mode. Stories 1-6 complete (detectors + schema). Stories 7-8 deferred (reasoning templates + pipeline integration).

### TX-2026-02-09-015 — CHG-015

- **status:** COMPLETED
- **change_id:** CHG-015
- **backend_branch:** change/CHG-015-phase1-pipeline-integration
- **frontend_branch:** change/CHG-015-phase1-pipeline-integration
- **backend_merge_commit:** 44b98792f7f35757cb4ce9517afbf7f6a0df85aa
- **frontend_merge_commit:** 063fe3c3db09cca23893d37ac22619e0f1938431
- **manifest_commit:** (workspace root)
- **notes:** Phase 1 Foundation Signals pipeline integration. 5 reasoning templates + issue builder integration + 4 detectors wired into pipeline + golden fixtures updated. STANDARD mode. 9 new tests (378 backend total). Contract 1.6.0 (no change). Atomic --no-ff merge successful in both repos.

### TX-2026-02-09-016 — CHG-016

- **status:** COMPLETED
- **change_id:** CHG-016
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-016-business-first-view
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** 8116de54ff6afabb1956d16e8e17cb6dcf239c74
- **manifest_commit:** (workspace root)
- **notes:** Business-first confidence filtering for Foundation Signals. Business Overview filters issues to show only HIGH confidence + OBSERVED. BusinessImpactCategories redesigned: leads with business impact messaging, "We observed" section, subtle confidence indicators. INLINE mode. Frontend-only. 4 tests updated. Contract 1.6.0 (no change).

### TX-2026-02-09-017 — CHG-017

- **status:** COMPLETED
- **change_id:** CHG-017
- **backend_branch:** change/CHG-017-cdp-psi-fallback
- **frontend_branch:** n/a
- **backend_merge_commit:** 0e3ee1f
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Playwright CDP fallback for PSI API failures. 21 new tests (15 CDP + 6 fallback). Contract 1.6.0 (no change). STANDARD mode. Atomic --no-ff merge successful.

### TX-2026-02-09-018 — CHG-018

- **status:** COMPLETED
- **change_id:** CHG-018
- **backend_branch:** change/CHG-018-segment-personalization
- **frontend_branch:** change/CHG-018-segment-personalization
- **backend_merge_commit:** 4b55cf7642358df606d2b1bfc13eb00006586d66
- **frontend_merge_commit:** 410788996fd5eec8bb63cce6227cae5cc675a5dc
- **manifest_commit:** (workspace root)
- **notes:** Segment-aware personalized Business Overview. 54 new tests (49 BE + 5 FE). Contract 1.6.0→1.7.0. STANDARD mode. Review: APPROVED. Atomic --no-ff merge successful in both repos.

### TX-2026-02-10-020 — CHG-020

- **status:** COMPLETED
- **change_id:** CHG-020
- **backend_branch:** change/CHG-020-honest-5x5-lists
- **frontend_branch:** change/CHG-020-honest-5x5-lists
- **backend_merge_commit:** 3f6545b
- **frontend_merge_commit:** 8e98ebe
- **manifest_commit:** (workspace root)
- **notes:** Both repos. Honest 5+5 bulleted lists in Business Overview. PersonalizedContent gains whats_working + needs_attention. Gemini prompt gets page context + honest tone. Frontend pills replaced with bulleted lists. 12 new backend tests, 8 rewritten frontend tests.

### TX-2026-02-09-019 — CHG-019

- **status:** COMPLETED
- **change_id:** CHG-019
- **backend_branch:** change/CHG-019-fix-zip-mismatch
- **frontend_branch:** n/a
- **backend_merge_commit:** 322e83da517673a6baa43dbb798e985300a78152
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Fix zip() length mismatch in page/soup collection. 1 new test. INLINE mode. Full process followed.

### TX-2026-02-10-021 — CHG-021

- **status:** COMPLETED
- **change_id:** CHG-021
- **backend_branch:** change/CHG-021-increase-timeout-750
- **frontend_branch:** n/a
- **backend_merge_commit:** e66f831
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. pipeline_timeout_seconds 450→750. Config-only. INLINE mode. Full process followed.

### TX-2026-02-10-022 — CHG-022

- **status:** COMPLETED
- **change_id:** CHG-022
- **backend_branch:** change/CHG-022-concurrent-page-fetch
- **frontend_branch:** n/a
- **backend_merge_commit:** e794f81
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Concurrent page fetching via asyncio.gather + semaphore. 6 new tests. STANDARD mode. Full process followed.

### TX-2026-02-10-023 — CHG-023

- **status:** COMPLETED
- **change_id:** CHG-023
- **backend_branch:** change/CHG-023-pipeline-perf
- **frontend_branch:** change/CHG-023-pipeline-perf
- **backend_merge_commit:** 0e81416
- **frontend_merge_commit:** 891a8bd
- **manifest_commit:** (workspace root)
- **notes:** Both repos. Pipeline performance optimization: robots.txt cache, parallel sampler with soups, batch Gemini issue_insights. Contract 1.7.0→1.8.0. 16 new tests (13 backend + 3 frontend). STANDARD mode. Full process followed.

### TX-2026-02-10-030 — CHG-030

- **status:** COMPLETED
- **change_id:** CHG-030
- **backend_branch:** change/CHG-030-summarizer-split
- **frontend_branch:** n/a
- **backend_merge_commit:** ba7513c
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Split gemini_summarizer.py 875→308 lines. 3 new modules + SummarizerProtocol. 12 new tests. STANDARD mode.

### TX-2026-02-10-029 — CHG-029

- **status:** COMPLETED
- **change_id:** CHG-029
- **backend_branch:** change/CHG-029-crawler-protocols
- **frontend_branch:** n/a
- **backend_merge_commit:** cb828ec
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Crawler callable protocols + DIP injection into pipeline steps. 18 new tests. STANDARD mode.

### TX-2026-02-10-028 — CHG-028

- **status:** COMPLETED
- **change_id:** CHG-028
- **backend_branch:** change/CHG-028-pipeline-steps
- **frontend_branch:** n/a
- **backend_merge_commit:** 9d7c3e4
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Extract 9 pipeline steps into PipelineStep classes. pipeline.py 686→247 lines. 10 new tests. STANDARD mode.

### TX-2026-02-10-027 — CHG-027

- **status:** COMPLETED
- **change_id:** CHG-027
- **backend_branch:** change/CHG-027-report-builder
- **frontend_branch:** n/a
- **backend_merge_commit:** e1a78b5
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Extract report-building functions from pipeline.py → reasoning/report_builder.py + services/error_classifier.py. pipeline.py 1256→686 lines. 18 new tests. STANDARD mode.

### TX-2026-02-10-026 — CHG-026

- **status:** COMPLETED
- **change_id:** CHG-026
- **backend_branch:** change/CHG-026-detector-registry
- **frontend_branch:** n/a
- **backend_merge_commit:** 98b9491
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Detector protocol + registry pattern. 8 detectors self-register. engine.py iterates registry. 8 new tests. STANDARD mode.

### TX-2026-02-10-025 — CHG-025

- **status:** COMPLETED
- **change_id:** CHG-025
- **backend_branch:** change/CHG-025-split-schemas
- **frontend_branch:** n/a
- **backend_merge_commit:** 901a8ff
- **frontend_merge_commit:** n/a
- **manifest_commit:** (workspace root)
- **notes:** Backend-only. Split schemas.py (34 classes) into 6 domain modules. Barrel re-export preserves all imports. 14 new tests. STANDARD mode.

### TX-2026-02-10-024 — CHG-024

- **status:** COMPLETED
- **change_id:** CHG-024
- **backend_branch:** change/CHG-024-solid-compliance-checks
- **frontend_branch:** change/CHG-024-solid-compliance-checks
- **backend_merge_commit:** febc10c
- **frontend_merge_commit:** 99df5ef
- **manifest_commit:** (workspace root)
- **notes:** Both repos + workspace. SOLID compliance checks: backend check_dod.sh [8/9]+[9/9], frontend check_dod.sh [7/8]+[8/8], test_layering.py TestClassCountEnforcement+TestModuleLineCounts, DEFINITION_OF_DONE.md SOLID section, Review Agent template SOLID phase. INLINE mode. No production code changes.

### TX-2026-02-10-031 — CHG-031

- **status:** COMPLETED
- **change_id:** CHG-031
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-031-tab-content-map
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** bd6045f
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. Extract ReportPage tab content into 4 dedicated components. INLINE mode. 180 frontend tests, 7 new.

### TX-2026-02-10-032 — CHG-032

- **status:** COMPLETED
- **change_id:** CHG-032
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-032-extract-api-hooks
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** a38a337
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. Extract page API calls into useGovernanceSubmit + useSeoSubmit hooks. INLINE mode. 189 frontend tests, 9 new.

### TX-2026-02-10-035 — CHG-035

- **status:** COMPLETED
- **change_id:** CHG-035
- **backend_branch:** change/CHG-035-ratchet-thresholds
- **frontend_branch:** change/CHG-035-ratchet-thresholds
- **backend_merge_commit:** 1c53e6c
- **frontend_merge_commit:** 971e5a1
- **manifest_commit:** (workspace root)
- **notes:** Both repos + workspace. Ratchet SOLID thresholds: backend line 1300→800, class 35→12. DEFINITION_OF_DONE.md updated. INLINE mode. 12-CHG SOLID refactoring plan complete.

### TX-2026-02-10-034 — CHG-034

- **status:** COMPLETED
- **change_id:** CHG-034
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-034-split-sidepanel
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** b99ae9b
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. Split SidePanel dual contract into BusinessSidePanel + TechnicalSidePanel. 0 new tests (6 existing pass via dispatcher). INLINE mode.

### TX-2026-02-10-033 — CHG-033

- **status:** COMPLETED
- **change_id:** CHG-033
- **backend_branch:** n/a
- **frontend_branch:** change/CHG-033-split-business-impact
- **backend_merge_commit:** n/a
- **frontend_merge_commit:** 0b67d53
- **manifest_commit:** (workspace root)
- **notes:** Frontend-only. Split BusinessImpactCategories dual rendering into PersonalizedCategoryCards + LegacyCategoryCards. 0 new tests (10 existing pass unchanged via dispatcher). INLINE mode.
