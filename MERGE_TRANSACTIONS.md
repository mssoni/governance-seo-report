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
