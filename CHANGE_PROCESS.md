# Change Process v2.4

> How changes are requested, developed, reviewed, and merged after V1 is complete.
> v2.0: merge safety, contract versioning, IO boundaries, flaky test protocol, deterministic rejection.
> v2.1: automated DoD enforcement (`make dod`), atomic merge protocol, CHG ID allocation script,
> DNS rebinding protection, attempt-budget kill switch, layering tests, compatibility matrix.
> v2.2: hard-gate vs heuristic labeling, merge strategy enforcement (`--no-ff`, no squash),
> merge transaction log, structured escalation templates, centralized observability helper,
> response size cap, redirect re-validation, data migration placeholder rules.
> v2.3: intent→outcome framing, risk classification, pre-flight invariant checks, mandatory
> out-of-scope, global default behavior rules, confidence signal, "unlocks later" field.
> v2.4: periodic documentation sync rule — every 5 changes, full doc audit + ENGINEERING_PLAN.md refresh.

## Overview

Every change follows an **8-step lifecycle**. The assistant acts as a **Change Agent** (orchestrator) — the user provides a plain-English change request and the agent handles everything autonomously.

**Minimal ambiguity; remaining cases are explicitly escalated.** The user's only role is to describe the change. The process uses hard gates where possible and deterministic heuristics elsewhere. If acceptance criteria cannot be written objectively, the orchestrator escalates with a `NEEDS_PRODUCT_DECISION` label.

**ABSOLUTE RULE — ALL 8 STEPS, EVERY TIME:** Every change follows all 8 steps. No step is ever skipped. What changes is the **execution mode** — INLINE or STANDARD — which controls *how* steps 3–6 execute, never *whether* they execute. Mode is determined by objective surface-type criteria (what files/modules are touched), not by perceived complexity or diff size. Risk is determined by what you touch, not by how much you change.

---

## 1. Input Format

The user provides a change request as a natural language prompt. Examples:

- "Add a loading animation to the report page"
- "Fix the performance score showing NaN when PSI fails"
- "Add email capture CTA before showing the SEO report"

The Change Agent reads the request and proceeds automatically.

**Escalation rule:** If the request is ambiguous or requires subjective product judgment (e.g., "make the report look better"), the orchestrator adds `NEEDS_PRODUCT_DECISION` to the CHANGE_LOG entry and asks the user for clarification before proceeding.

---

## 2. The 8-Step Lifecycle

```
User Prompt
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 1: DECOMPOSE (7 sub-steps)                     │
│                                                     │
│ 1a. CONTEXT GATHER                                  │
│   - Read ARCHITECTURE.md (both repos)               │
│   - Read CONTRACTS.md + CHANGE_MANIFEST.json        │
│   - Identify affected modules/files                 │
│   - Determine: backend-only, frontend-only, or both │
│                                                     │
│ 1b. PRE-FLIGHT INVARIANT CHECK (reject early)       │
│   - Does this violate a core invariant?             │
│     (max 20 pages, no live crawl without consent,   │
│      no state without rollback, no auth in V1)      │
│   - Does this contradict a V1 non-goal?             │
│     (no auth, no snapshots, no scheduled emails,    │
│      no GA/GSC, no rankings promises)               │
│   - Does this create permanent state without a      │
│     rollback path?                                  │
│   → If yes: NEEDS_PRODUCT_DECISION before stories   │
│                                                     │
│ 1c. OUTCOME FRAMING (silent unless risky)           │
│   - What metric does this affect?                   │
│     (conversion, reliability, speed, trust)         │
│   - Is this request a means or an end?              │
│   - Is there a cheaper/safer way to get the same    │
│     outcome?                                        │
│   → Escalate only if: the requested change          │
│     optimizes the wrong metric or adds complexity   │
│     with low outcome impact                         │
│                                                     │
│ 1d. STORY FORMATION                                 │
│   - Create stories with acceptance criteria         │
│   - If AC can't be objective →                      │
│     NEEDS_PRODUCT_DECISION                          │
│   - Assign Risk Level: LOW / MEDIUM / HIGH          │
│   - Require at least 1 Out of Scope item per story  │
│   - Optionally add "Unlocks Later" field            │
│                                                     │
│ 1e. CONFIDENCE SIGNAL                               │
│   - Rate: HIGH / MEDIUM / LOW                       │
│   - If LOW: bias toward smaller stories,            │
│     conservative approach, more review iterations   │
│                                                     │
│ 1f. LOG + ALLOCATE                                  │
│   - Assign Change ID via ./scripts/new_change_id.sh │
│   - Write stories to CHANGE_LOG.md                  │
│   - Report decomposition to user (brief summary)    │
│                                                     │
│ 1g. SELECT EXECUTION MODE (see §2.1)                │
│   - Evaluate surface-type criteria                  │
│   - Result: INLINE or STANDARD                      │
│   - Record mode in CHANGE_LOG.md entry              │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 2: BRANCH                                      │
│ - Create branch in affected repos:                  │
│   change/CHG-NNN-short-description                  │
│ - Both repos use the SAME branch name               │
│ - Example: change/CHG-001-pdf-export                │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 3: DEVELOP                                     │
│                                                     │
│ STANDARD mode:                                      │
│ - Spawn Agent A (backend) + Agent B (frontend)      │
│ - If only one repo affected, spawn only one agent   │
│                                                     │
│ INLINE mode:                                        │
│ - Orchestrator executes directly (no agent spawn)   │
│                                                     │
│ Both modes — TDD is mandatory:                      │
│   1. Write test → must fail                         │
│   2. Implement → test must pass                     │
│   3. Run `make check` → all green                   │
│ - Contract-First if schema changes:                 │
│   Bump contract_version → update CONTRACTS.md       │
│   → types → golden fixtures → CHANGE_MANIFEST.json  │
│ - IO boundary enforced: only fetch modules do HTTP  │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 4: DOCUMENT (part of each agent's task)        │
│ - ARCHITECTURE.md — new files, changed interfaces   │
│ - PROGRESS.md — change entry with test counts       │
│ - CURRENT_TASKS.md — claim/release cycle            │
│ - CONTRACTS.md — if schema changed + version bump   │
│ - CHANGE_MANIFEST.json — update commit SHAs         │
│ - ENGINEERING_PLAN.md — every 5 changes or on       │
│   significant architecture/stats change             │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 5: DEFINITION OF DONE (agent self-check)       │
│ - Run `make dod` — automated enforcement checks     │
│ - Run DEFINITION_OF_DONE.md manual checklist         │
│ - If any item fails → fix before committing         │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 6: REVIEW                                      │
│                                                     │
│ STANDARD mode:                                      │
│ - Spawn Review Agent (separate sub-agent)           │
│                                                     │
│ INLINE mode:                                        │
│ - Orchestrator reviews inline (no agent spawn)      │
│                                                     │
│ Both modes — same checks are mandatory:             │
│ - Runs `make check` in affected repo(s)             │
│ - Runs `make dod` in affected repo(s)               │
│ - Runs DoD checklist (DEFINITION_OF_DONE.md)        │
│ - Checks auto-reject triggers (reject immediately   │
│   if any trigger fires — see DoD)                   │
│ - Inspects `git diff main` for scope/drift          │
│ - Auto-fixes small issues (lint, format, logs)      │
│ - Rejects architectural issues to REVIEW_LOG.md     │
│ - Checks for flaky tests (FLAKY_TESTS.md protocol)  │
│ - Appends findings to REVIEW_LOG.md                 │
│ - If approved: APPROVE status (does NOT merge)      │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 7: MERGE GATE (Atomic Cross-Repo Protocol)     │
│ - Review Agent reports APPROVED status               │
│ - Orchestrator verifies:                            │
│   1. `make check` green in both repos               │
│   2. `make dod` green in both repos                 │
│   3. `./scripts/validate_change.sh CHG-NNN` passes  │
│   4. CHANGE_LOG.md entry is complete                 │
│   5. No NEEDS_PRODUCT_DECISION items unresolved     │
│ - Merge strategy: ALWAYS merge commit (--no-ff)     │
│   No squash merges. No rebases onto main.           │
│   This ensures every merge is revertible with a     │
│   single `git revert`.                              │
│ - Atomic Merge Sequence:                            │
│   a. Log STARTED in MERGE_TRANSACTIONS.md           │
│   b. Merge backend branch to main (if changed)     │
│   c. Merge frontend branch to main (if changed)    │
│   d. If step (c) fails → revert step (b), log      │
│      ROLLED_BACK in MERGE_TRANSACTIONS.md, mark     │
│      PARTIAL_MERGE_BLOCKED in CHANGE_LOG.md         │
│   e. Only after both merges succeed:                │
│      Update CHANGE_MANIFEST.json with BOTH merge    │
│      commit SHAs in a dedicated manifest commit     │
│   f. Log COMPLETED in MERGE_TRANSACTIONS.md         │
│ - No force pushes                                   │
│ - Commit: merge(CHG-NNN): [description]             │
│ - Manifest commit: chore(CHG-NNN): update manifest  │
│                                                     │
│ NOTE: When remote CI is configured, merge requires  │
│ CI green on the remote. Local `make check` + `make  │
│ dod` is the minimum gate until CI is set up.        │
│                                                     │
│ SHA semantics: `backend_commit` / `frontend_commit` │
│ always point to the MERGE COMMIT on main, not the   │
│ feature branch tip.                                 │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 8: REPORT                                      │
│ - Update CHANGE_LOG.md status to COMPLETE           │
│ - Summarize to user:                                │
│   - What changed (files, modules)                   │
│   - Tests added/modified                            │
│   - Contract version (if bumped)                    │
│   - Docs updated                                    │
│   - Any warnings or follow-ups                      │
└─────────────────────────────────────────────────────┘
```

---

## 2.1 Execution Mode Selection

At the end of DECOMPOSE (sub-step 1g), the orchestrator selects **INLINE** or **STANDARD** mode. This determines *how* steps 3–6 execute — not whether they execute. All 8 steps always run.

**Risk is determined by what you touch, not by how much you change.**

### INLINE mode — ALL of these must be true:

| Criterion | Rationale |
|-----------|-----------|
| No contract/schema change (`schemas.py`, `api.ts`, `CONTRACTS.md` untouched) | Schema changes need cross-repo coordination |
| No new files or modules created | New modules need architectural review |
| No IO-boundary module touched (see IO Boundary lists in §7) | IO modules affect security and external integrations |
| No security/crawling/pipeline module touched | These affect data correctness and abuse prevention |
| Single-repo only (backend OR frontend, not both) | Cross-repo changes need parallel agents |
| Changes are: config values, copy text, CSS/styles, or non-logic fixes only | Logic changes need dedicated agent focus |

If **all** criteria are met → **INLINE**. The orchestrator develops and reviews directly.

### STANDARD mode — ANY ONE of these triggers it:

- Schema or contract touched
- New modules or files created
- Security, crawling, IO-boundary, or pipeline module touched
- Both repos need changes
- Logic or API behavior changes
- New dependencies added
- Confidence signal is LOW

### How mode affects each step:

| Step | INLINE | STANDARD |
|------|--------|----------|
| 1. DECOMPOSE | Brief inline (decisions only, no sub-step headers) | Full 6-sub-step format |
| 2. BRANCH | Same | Same |
| 3. DEVELOP | Orchestrator executes directly (TDD still required) | Spawn dev agent(s) |
| 4. DOCUMENT | Same (ARCHITECTURE.md, PROGRESS.md, etc.) | Same |
| 5. DoD | `make check` + `make dod` (same) | Same |
| 6. REVIEW | Orchestrator reviews inline (run gates + inspect diff) | Spawn review agent |
| 7. MERGE GATE | Same (`--no-ff`, transaction log, manifest) | Same |
| 8. REPORT | Same | Same |

### Mode escalation

If during INLINE execution the orchestrator discovers the change unexpectedly touches a sensitive surface (schema, IO module, security, cross-repo), it **must**:
1. Stop INLINE execution
2. Add `[MODE_ESCALATION]` label to the CHANGE_LOG entry
3. Continue in STANDARD mode (spawn appropriate agents)

This is not a failure — it's the process working correctly.

**INLINE mode is single-brain execution, not a quick hack. All gates still apply.**

---

## 2.2 Periodic Documentation Sync (Every 5 Changes)

**Rule:** Every 5th change (CHG-005, CHG-010, CHG-015, CHG-020, CHG-025, ...) **must** include a full documentation sync as part of Step 4 (DOCUMENT). This is in addition to the per-change documentation updates.

**What to update during a periodic sync:**

| Document | Action |
|----------|--------|
| `ENGINEERING_PLAN.md` | Add version history rows for all changes since last update. Refresh Current Statistics (test counts, endpoints, components, contract version, post-V1 count). Update Architecture Overview diagram if new modules/services were added. |
| `CHANGE_LOG.md` | Verify all entries CHG-001 through current are present and have correct status |
| `backend/ARCHITECTURE.md` | Verify file tree, interfaces, and change log are current |
| `frontend/ARCHITECTURE.md` | Verify file tree, components, and change log are current |
| `backend/CONTRACTS.md` + `frontend/CONTRACTS.md` | Verify version sync with `CHANGE_MANIFEST.json` |
| `CHANGE_MANIFEST.json` | Verify commit SHAs, contract version, and last_change_id are accurate |

**Trigger:** The `validate_change.sh` script already WARNs when ENGINEERING_PLAN.md is stale. During a periodic sync change, this WARN becomes a blocking requirement.

**If a sync is overdue** (>5 changes since last ENGINEERING_PLAN.md update), the next change **must** include the sync regardless of whether it falls on a 5th boundary.

---

## 3. DECOMPOSE Details

### 3.1 Pre-flight Invariant Check

Before writing any stories, verify the request does not violate these hard constraints:

| Invariant | Source |
|-----------|--------|
| Max 20 pages per analysis | PRD §9, Security §10 |
| No authentication in V1 | PRD §2 (non-goal) |
| No report history / snapshots in V1 | PRD §2 (non-goal) |
| No scheduled emails in V1 | PRD §2 (non-goal) |
| No GA/GSC connection in V1 | PRD §2 (non-goal) |
| No SEO execution or rankings promises | PRD §2 (non-goal) |
| No PDF export (web-only, print-friendly OK) | PRD §2 (non-goal) |
| No permanent state without rollback path | §16 (Data Migration) |
| Deterministic reasoning only — no free-form LLM "analysis" | PRD §6 |
| No live crawling of disallowed paths (robots.txt) | Security §10 |

If a request touches any of these, escalate as `NEEDS_PRODUCT_DECISION` with:
- Which invariant is affected
- Whether it should be moved to a future phase
- Recommended approach if the invariant should be relaxed

### 3.2 Outcome Framing

This step runs silently. The orchestrator asks internally:

1. **What metric does this affect?**
   Map to one of the success metrics from the PRD:
   - Report completion rate (≥ 80%)
   - Time-to-report (p50 < 45s, p90 < 120s)
   - Saved/Shared clicks (≥ 10%)
   - "Request help" CTA click (≥ 3-5%)
   - SEO report completion after competitor step (≥ 50%)

2. **Is this request a means or an end?**
   - "Add a retry button" → means (the end is reliability)
   - "Reduce report failures" → end (retry is one possible means)
   - If it's a means: verify the end is correct before building the means

3. **Is there a cheaper/safer way to reach the same outcome?**
   - Can this be solved with config instead of code?
   - Can this be solved with copy changes instead of new UI?
   - Can this be solved in one repo instead of both?

**Escalate only if:** the requested change optimizes the wrong metric, or adds complexity with low outcome impact. Otherwise, proceed silently.

### 3.3 Story Template

```markdown
### Story: [Title]
**Change ID:** CHG-NNN
**Repo:** backend / frontend / both
**Type:** feature / fix / refactor

**Risk Level:** LOW | MEDIUM | HIGH
  - LOW: UI-only, copy, non-critical logic
  - MEDIUM: API changes, error handling, retry logic, new components
  - HIGH: crawling, security, billing, data correctness, external API integration

**Description:** [1-2 sentences of what and why]

**Acceptance Criteria:**
- [ ] [Observable, testable outcome 1]
- [ ] [Observable, testable outcome 2]
- [ ] [Observable, testable outcome 3]

**Out of Scope:** (mandatory — at least 1 item)
- [What this story does NOT do]
- [Boundary that prevents scope creep]

**Contract Impact:** None / Additive (MINOR) / Breaking (MAJOR)
**Security Impact:** None / Needs SSRF tests / Needs redirect tests
**Files Likely Touched:** [list based on ARCHITECTURE.md]

**Unlocks Later:** (optional)
- [Future capability this enables]
- [Effort this reduces for a future change]
```

**Rules:**
- Every acceptance criterion must be testable — if you can't write a test for it, it's too vague
- At least 1 "Out of Scope" item is mandatory. Review Agent rejects stories missing it.
- "Unlocks Later" is optional but encouraged — it creates institutional memory

### 3.4 Risk Level Effects

| Risk Level | Review Strictness | Approach Bias | Rollback Readiness |
|------------|------------------|---------------|-------------------|
| **LOW** | Standard review | Ship fast, iterate | Standard (`git revert`) |
| **MEDIUM** | Full DoD + extra schema/contract review | Prefer additive changes | Verify revert path before merge |
| **HIGH** | Full DoD + security tests + manual spot-check | Be conservative, smaller stories | Test rollback scenario before merge |

### 3.5 Confidence Signal

Before spawning agents, the orchestrator outputs:

```
Confidence: HIGH | MEDIUM | LOW
Reason: [1-line explanation]
```

| Confidence | Meaning | Behavior Adjustment |
|-----------|---------|-------------------|
| **HIGH** | Clear AC, known patterns, LOW/MEDIUM risk | Execute normally |
| **MEDIUM** | Some AC ambiguity, or MEDIUM risk, or unfamiliar module | Prefer smaller stories, expect 1 review cycle |
| **LOW** | Unclear scope, HIGH risk, or novel territory | Split into smallest possible stories, expect 2+ review cycles, bias toward conservative approach |

### 3.6 Global Default Behavior Rules

When ambiguity arises during decomposition or development, apply these defaults:

| Principle | Default |
|-----------|---------|
| Additive vs breaking | **Prefer additive** — add new fields/endpoints, don't rename/remove |
| Readability vs novelty | **Prefer readability** — clear copy over clever UI |
| Safety vs speed | **Prefer safety** — validate inputs, cap resources, fail gracefully |
| Explicit vs automatic | **Prefer explicit user action** — show the user, let them decide |
| Simple vs complete | **Prefer simple first** — ship the 80% case, iterate on edge cases |
| One repo vs both | **Prefer one repo** — if the change can be contained, contain it |

These defaults are referenced in the structured escalation template:

```
**Default (per global defaults):** [Option X] — [which principle applies]
```

---

## 4. Naming Convention (Case-Stable, One Format Everywhere)

| Item | Format | Example |
|------|--------|---------|
| Change ID | `CHG-NNN` (uppercase) | `CHG-001` |
| Branch name | `change/CHG-NNN-short-description` | `change/CHG-001-pdf-export` |
| Commit (dev) | `feat(CHG-NNN): <description>` | `feat(CHG-001): add PDF export endpoint` |
| Commit (review fix) | `fix(CHG-NNN): <description>` | `fix(CHG-001): add missing timeout` |
| Commit (merge) | `merge(CHG-NNN): <description>` | `merge(CHG-001): PDF export feature` |
| CHANGE_LOG entry | `### CHG-NNN: <Title>` | `### CHG-001: PDF Export` |
| PROGRESS.md flag | `[CHG-NNN]` | `[CHG-001] +3 tests` |

**Rule:** `CHG-NNN` is ALWAYS uppercase. Branch uses `CHG-NNN` (uppercase) after the `change/` prefix. No exceptions.

---

## 5. Contract Versioning

Contracts use semantic versioning: `MAJOR.MINOR.PATCH`

| Change Type | Version Bump | Flag |
|------------|-------------|------|
| Additive field (new optional field) | MINOR | `[SCHEMA CHANGE]` |
| New endpoint | MINOR | `[SCHEMA CHANGE]` |
| Renamed/removed field | MAJOR | `[BREAKING SCHEMA CHANGE]` |
| Changed field type | MAJOR | `[BREAKING SCHEMA CHANGE]` |
| Bug fix to existing schema | PATCH | none |

**Current version:** stored in `CONTRACTS.md` header and `CHANGE_MANIFEST.json`.

When bumping:
1. Update `contract_version` in `CONTRACTS.md`
2. Update `contract_version` in `CHANGE_MANIFEST.json`
3. Update backend Pydantic models
4. Update frontend TypeScript types
5. Update golden fixtures in both repos
6. Flag in `PROGRESS.md`

---

## 6. Cross-Repo Compatibility Pin (CHANGE_MANIFEST.json)

Both repos reference a shared manifest at the workspace root:

```json
{
  "contract_version": "1.0.0",
  "last_change_id": "CHG-001",
  "backend_commit": "abc123",
  "frontend_commit": "def456",
  "compatibility": {
    "backend_min_contract": "1.0.0",
    "frontend_min_contract": "1.0.0"
  },
  "updated_at": "2026-02-07",
  "notes": "Added PDF export"
}
```

**Rules:**
- Updated after every merge (Step 7, specifically in the dedicated manifest commit)
- Backend and frontend commit SHAs point to the **merge commit** on `main` (not the feature branch tip)
- If only one repo changes, the other repo's SHA stays the same
- `compatibility` records the minimum `contract_version` each repo requires from the other
- When bumping `contract_version`, update `compatibility` if the change is breaking (MAJOR)
- Review Agent checks that `contract_version` matches between `CONTRACTS.md` and manifest
- `make contract-check` (available in both repos) verifies sync automatically

### CHG ID Allocation

Change IDs are allocated from `last_change_id` in `CHANGE_MANIFEST.json` (single source of truth).

**Process:**
1. Run `./scripts/new_change_id.sh` from the workspace root
2. The script atomically reads, increments, and writes the new ID
3. Output: the new `CHG-NNN` ID (e.g., `CHG-002`)
4. Never manually edit `last_change_id` — always use the script

This prevents duplicate IDs when multiple changes happen in sequence.

---

## 7. IO Boundary Rule

**Hard rule:** Only designated modules may perform HTTP, Playwright, or external API calls.

### Backend
| Allowed IO modules | Purpose |
|-------------------|---------|
| `app/crawlers/html_fetcher.py` | Fetch web pages |
| `app/crawlers/sitemap_parser.py` | Fetch/parse sitemaps |
| `app/services/psi_client.py` | PageSpeed Insights API |
| `app/services/places_client.py` | Google Places API |
| `app/reasoning/gemini_summarizer.py` | Gemini API (hybrid: lives in reasoning/ but does IO) |
| `app/services/competitor_analyzer.py` | Orchestrates IO calls |
| `app/services/pipeline.py` | Orchestrates IO calls |
| `app/services/seo_pipeline.py` | Orchestrates IO calls |

**Everything else (detectors, templates, issue builders, gap analyzers, action plan generators) MUST accept data as function arguments. No HTTP calls. No file reads. Pure functions.**

**Note on `gemini_summarizer.py`:** This module lives in `reasoning/` but performs external API calls (Gemini). It is classified as a **hybrid IO module** — exempt from BLE001 and bare-except checks, but subject to IO testing rules (mock all external calls). It stays in `reasoning/` because its purpose is rephrasing, not fetching. The layering test (`test_layering.py`) does not flag it because `google.generativeai` is not in the forbidden HTTP library list.

### Frontend

IO is allowed in three layers only:

| Layer | Modules | What they may do |
|-------|---------|-----------------|
| **Service layer** | `src/services/api-client.ts` | Define HTTP methods (get, post). The ONLY module that calls `fetch`. |
| **Hook layer** | `src/hooks/useJobPolling.ts`, `src/hooks/useSeoJobPolling.ts` | Call `api-client` methods. Manage polling lifecycle. |
| **Page layer** | `src/pages/LandingPage.tsx`, `src/pages/ReportPage.tsx` | Import and call `api-client` methods (e.g., `apiClient.post()`). Wire data into components via props. |

**What pages may NOT do:**
- Call `fetch()` or `axios` directly — always go through `api-client.ts`
- Import any module from `node_modules` that performs HTTP (e.g., `axios`, `ky`, `got`)

**Components (`src/components/`):**
- Receive ALL data via props. Zero imports from `src/services/`.
- No `fetch()`, no `axios`, no `api-client` imports.

In React, pages are technically components, but in this architecture they serve as
the **orchestration boundary** — the place where IO meets UI. This is why pages may
import `api-client` but components may not.

### Layering Rule (Transitive Import Prevention)
Non-IO modules cannot import IO modules, even transitively:
- Backend: `detectors/*`, `reasoning/*`, `seo/*`, `models/*` cannot import from `crawlers/*` or `services/*`
- Frontend: `components/*` cannot import from `services/*`
- Frontend pages may import `api-client.ts` but NOT call `fetch()` directly
- Only pipeline/orchestration modules (`services/pipeline.py`, `services/seo_pipeline.py`) import IO modules
- Only hooks and pages import `api-client.ts` — components never do
- Enforced by `make dod` and `make io-boundary-check` (grep-based)

### Test Enforcement
- Tests for detectors/analyzers/generators use fixtures ONLY (never live calls)
- Tests for IO modules mock the HTTP layer (httpx mock, vi.mock)
- Review Agent auto-rejects any Playwright/HTTP import in a non-IO module
- `make dod` automates these checks — no human interpretation needed

---

## 8. Kill Switch (Attempt Budget)

The kill switch is framed as an **attempt budget**, not a wall-clock timer (agents can't reliably track time).

| Task Type | Max Approaches | Max Failed Test Cycles | Action |
|-----------|---------------|----------------------|--------|
| Pure logic (normalizer, template, builder) | 3 distinct strategies | 2 consecutive full failures | BLOCKERS.md + release lock |
| Integration/IO (endpoint, pipeline, API client) | 3 distinct strategies | 3 consecutive full failures | BLOCKERS.md + release lock |
| External dependency failure (API quota, PSI down, DNS) | 1 attempt | 1 failure | BLOCKERS.md + immediate fallback plan |

**Definitions:**
- **"Approach"** = a distinct strategy (different algorithm, different library, different architecture). Repeated retries of the same approach do NOT count as separate approaches.
- **"Failed test cycle"** = running `make check` and getting test failures related to the current story. Lint-only failures don't count.

**When triggered:**
1. Write to `BLOCKERS.md`: what was attempted, what failed, proposed alternative
2. Log attempt count in `PROGRESS.md`: `[BLOCKED] CHG-NNN: 3/3 approaches exhausted`
3. Release lock in `CURRENT_TASKS.md`
4. Commit WIP: `wip(CHG-NNN): blocked — see BLOCKERS.md`
5. Report blocker to orchestrator

**Guideline times** (informational, not enforced):
- Pure logic: ~20 min typical
- Integration: ~45 min typical
- These are expectations, not hard gates. The attempt budget is the enforcement mechanism.

---

## 9. Observability Requirements

### Centralized Helper

All IO modules MUST use the `log_event()` helper from `app/observability/logging.py`:

```python
from app.observability.logging import log_event

# Usage in any IO module:
log_event(request_id=job_id, step="fetch_html", url=url, status="ok", duration_ms=142)
log_event(request_id=job_id, step="psi_api", url=url, status="error", error_code="TIMEOUT", duration_ms=15000)
```

**Rule:** Any new IO module that does not use `log_event()` is flagged by the Review Agent (DoD item [R]).

### Request ID
Every report generation job gets a `request_id` (the `job_id` from `JobManager`). All log entries for that job include the `request_id`.

### Structured Log Format
```
{request_id, url, step, duration_ms, status, error_code, error_message}
```

### Error Taxonomy
| Code | Meaning | Retry? |
|------|---------|--------|
| `TIMEOUT` | Request exceeded timeout | Yes (1x) |
| `DNS_FAILURE` | Domain not resolvable | No |
| `SSL_ERROR` | Certificate invalid/expired | No |
| `BLOCKED_403` | Site returned 403 Forbidden | No |
| `RATE_LIMITED_429` | Too many requests | Yes (backoff) |
| `PARSE_FAILURE` | HTML/XML could not be parsed | No |
| `CONNECTION_ERROR` | TCP connection failed | Yes (1x) |
| `NON_HTML` | Response is PDF/image/binary | No |
| `API_QUOTA` | External API quota exceeded | No (log + degrade) |
| `RESPONSE_TOO_LARGE` | Response body > 5 MB | No |

### Retry Policy
- Max 1 retry for retryable errors
- Exponential backoff: 2s base, max 10s
- Never retry non-retryable errors
- Log both the original error and the retry outcome

---

## 10. Security Constraints (Required Tests)

For any change that touches URL handling, crawling, or fetching:

| Constraint | Required Test |
|-----------|--------------|
| SSRF prevention | Private IPs (10.x, 172.16-31.x, 192.168.x), localhost, ::1 blocked |
| SSRF DNS rebinding | Resolve hostname → IP at request time, validate resolved IP is not private |
| Redirect re-validation | Each redirect hop re-resolves hostname and re-validates against SSRF rules |
| Redirect cap | Max 3 redirects; `TooManyRedirects` handled explicitly |
| Max response size | 5 MB per page (prevent memory exhaustion / zip bombs) |
| robots.txt respect | Disallowed paths not crawled (best effort) |
| Max pages cap | Hard limit of 20 pages per analysis (enforced + tested) |
| Per-domain rate limit | Max 2 concurrent requests per domain |
| URL scheme whitelist | Only `http://` and `https://` allowed (no `file://`, `ftp://`, `javascript:`) |
| Timeout enforcement | Per-fetch timeout of 15s, overall pipeline timeout of 90s |

### DNS Rebinding Protection

Classic SSRF bypass: a domain resolves to a public IP first, then to a private IP on the second resolution.

**Mitigation:**
1. Resolve the hostname to an IP address before making the request
2. Validate the resolved IP is not in private/reserved ranges
3. On redirects, re-validate the new target URL's resolved IP (httpx event hooks or manual follow)
4. Cap redirects to 3 maximum (`follow_redirects=True` with `max_redirects=3`)

### Redirect Policy

| Setting | Value |
|---------|-------|
| Follow redirects? | Yes |
| Max redirects | 3 |
| Validate redirect targets? | Yes (SSRF re-validation on each hop) |
| Cross-domain redirects? | Allowed (but each target validated) |
| Scheme changes on redirect? | Only http→https allowed; https→http blocked |

### Response Size Cap

| Setting | Value |
|---------|-------|
| Max response body | 5 MB (5,242,880 bytes) |
| Enforcement | Stream response, abort if `Content-Length` > limit or streamed bytes exceed limit |
| Error | Return `FetchResult` with error "Response too large" (do not raise) |

These tests must exist and pass. The Review Agent rejects if any are missing when relevant code is changed.

---

## 11. Escalation Paths

Not all requests can be handled autonomously. Escalation paths use **Labels** (not Status) in `CHANGE_LOG.md`. A change can be `IN_PROGRESS` with a `NEEDS_PRODUCT_DECISION` label.

### NEEDS_PRODUCT_DECISION

Add this **label** to the CHANGE_LOG entry when:
- Acceptance criteria cannot be written objectively ("make it look better")
- The change has UX trade-offs requiring human judgment
- The change affects sales/conversion copy tone
- Multiple valid approaches exist with significantly different user impact

**Action:** Orchestrator presents a **structured escalation** to the user using this template:

```
## Decision Needed: [CHG-NNN] [Short Title]

**What:** [1-sentence description of the decision]

**Options:**
  A. [Option A] — [trade-off summary]
  B. [Option B] — [trade-off summary]
  C. [Option C, if applicable]

**Recommendation:** [A/B/C] — [why]

**Impact on success metrics:** [which metric changes and directionally how]

**Default if no response:** [Option X after 24h]
```

Does NOT spawn agents until the user responds.

### NEEDS_ARCHITECTURE_REVIEW

Add this **label** when:
- The change requires a new external dependency
- The change restructures more than 3 modules
- The change introduces a new data store or caching layer

**Action:** Orchestrator presents options using the same structured template above, focused on architectural trade-offs (performance, complexity, dependency risk).

---

## 12. Agent Prompt Templates

### Backend Dev Agent

```
You are AGENT A (Backend Developer) for change CHG-NNN.

WORKSPACE: /Users/mayureshsoni/CascadeProjects/governance-seo-report/backend
BRANCH: change/CHG-NNN-short-description

## FIRST STEPS
1. git checkout -b change/CHG-NNN-short-description
2. Read AGENT_PROMPT.md, ARCHITECTURE.md, CONTRACTS.md
3. Run `make check` — must be green before starting

## STORIES
<generated stories with acceptance criteria>

## RULES
- TDD: write test first → fail → implement → pass → make check
- IO boundary: only fetch modules (crawlers/, services/*_client.py) may do HTTP
- Layering: detectors/reasoning/seo/models cannot import from crawlers/services
- Contract-First if schema changes: bump contract_version, update all artifacts
- Before committing: run `make dod` + DEFINITION_OF_DONE.md checklist
- Commit: feat(CHG-NNN): <description>
- Update: ARCHITECTURE.md, PROGRESS.md, CURRENT_TASKS.md

## KILL SWITCH (attempt budget)
- Pure logic: 3 approaches / 2 failed test cycles
- Integration: 3 approaches / 3 failed test cycles
- External failure: immediate → BLOCKERS.md

## WHEN DONE
Return: stories completed, test counts, files changed, contract_version (if bumped), blockers.
```

### Frontend Dev Agent

Same structure, adapted for frontend workspace and tools.

### Review Agent

```
You are the REVIEW AGENT for change CHG-NNN.

BACKEND: /Users/mayureshsoni/CascadeProjects/governance-seo-report/backend
FRONTEND: /Users/mayureshsoni/CascadeProjects/governance-seo-report/frontend

## PHASE 1: AUTOMATED GATES (run first, reject immediately on failure)
1. Run `make check` in both repos — if fail due to lint/format: auto-fix, re-run;
   if fail due to test/type errors → REJECT (those are dev agent's job)
2. Run `make dod` in both repos — if fail → REJECT (no fix attempt)
   `make dod` enforces these SOLID hard gates automatically:
   - H-SOLID-1 (SRP): Backend module ≤800 lines (exempt: __init__.py, templates.py)
   - H-SOLID-2 (SRP/ISP): Model file ≤12 classes per file
   - H-SOLID-3 (SRP): Frontend component ≤400 lines (exempt: test files)
   - H-SOLID-4 (DIP): No apiClient/api-client imports in src/components/
3. Check 11 auto-reject triggers below — if any fire → REJECT (no fix attempt)

## PHASE 2: MANUAL CHECKLIST (run only if Phase 1 passes)
4. Walk DEFINITION_OF_DONE.md [R]-tagged items:
   - Tests added for new functionality?
   - External calls have timeouts + use log_event() helper?
   - ARCHITECTURE.md, PROGRESS.md, CHANGE_LOG.md updated?
   - Scope: git diff touches only change-related files?
   - Contract version bumped if schema changed?
5. SOLID compliance review (DEFINITION_OF_DONE.md "SOLID Compliance" section):
   - R-SOLID-1: Functions >80 lines with 3+ section comments → must split or justify
   - R-SOLID-2: New detector/step/tab adds only a registration line to orchestration files
   - R-SOLID-3: Page growing >30 net lines → logic in hooks/sub-components
   - R-SOLID-4: New imports flow high→low; services depend on protocols not concrete impls
   - R-SOLID-5: Fields added to 10+ field dataclass → verify all consumers need it
   - R-SOLID-6: Optional props that switch rendering → split into single-contract variants
6. Review code quality: schema alignment, copy tone, accessibility
7. Check for flaky tests (FLAKY_TESTS.md protocol)

## PHASE 3: FIX OR REJECT (code-level issues found during Phase 2 review)
7. Auto-fix small code issues: missing log_event() calls, missing doc entries,
   missing ARCHITECTURE.md lines, minor test gaps
   - Commit fixes as: fix(CHG-NNN): [what was fixed per review]
   - Re-run `make check` + `make dod` after fixes
8. If architectural issue found → REJECT to REVIEW_LOG.md with explanation

## PHASE 4: REPORT
9. Append all findings to REVIEW_LOG.md
10. Report to orchestrator: APPROVED or REJECTED with reasons
    - If APPROVED: list any warnings, follow-ups, and auto-fixes applied
    - If REJECTED: list specific failing items + which dev agent should fix

## 12 AUTO-REJECT TRIGGERS (deterministic, no fix attempt)
1. Contract changed without contract_version bump + fixture updates
2. New dependency without ARCHITECTURE.md update
3. New endpoint/component without tests
4. Scope drift (diff touches files outside change scope — heuristic)
5. Live network call in test files
6. HTTP/Playwright import in non-IO module
7. Non-IO module importing an IO module (layering violation)
8. `make check` fails after review fixes
9. `make dod` fails after review fixes (includes SOLID hard gates H-SOLID-1 through H-SOLID-4)
10. CHANGE_LOG.md entry missing
11. Any of the 8 lifecycle steps was skipped — regardless of execution mode (INLINE or STANDARD)
12. SOLID review items (R-SOLID-1 through R-SOLID-6) violated — see DEFINITION_OF_DONE.md "SOLID Compliance"

Plus umbrella rule: reject if ANY DoD checklist item fails.

## CRITICAL CONSTRAINTS
- You do NOT merge. You report APPROVED/REJECTED status only.
- The orchestrator handles the merge gate.
- You never skip Phase 1. If automated gates fail, do not proceed to Phase 2.
```

---

## 13. Merge Strategy

**Always merge commit (`--no-ff`). No squash merges. No rebases onto main.**

| Rule | Reason |
|------|--------|
| `git merge --no-ff` | Every merge is a single commit, revertible with one `git revert` |
| No squash | Preserves full commit history; `merge(CHG-NNN)` format stays intact |
| No rebase onto main | Prevents rewriting shared history; keeps SHAs stable |

This is enforced in the merge gate. If an agent uses `--squash` or `rebase`, the Review Agent rejects.

---

## 14. Merge Transaction Log

Every cross-repo merge is logged in `MERGE_TRANSACTIONS.md` (workspace root, append-only).

### Entry Format

```markdown
### TX-YYYY-MM-DD-HH:MM — CHG-NNN
- **status:** STARTED | COMPLETED | ROLLED_BACK | FAILED
- **backend_branch:** change/CHG-NNN-...
- **frontend_branch:** change/CHG-NNN-... (or "n/a")
- **backend_merge_commit:** <sha> (or "n/a")
- **frontend_merge_commit:** <sha> (or "n/a")
- **manifest_commit:** <sha> (or "n/a")
- **notes:** <what happened, if rollback needed>
```

**Rules:**
- Append `STARTED` entry before any `git merge`
- Update to `COMPLETED` after manifest commit
- Update to `ROLLED_BACK` if partial merge recovery triggered
- Update to `FAILED` if merge is abandoned
- Never delete entries — this is an audit trail

---

## 15. Rollback

If a change breaks `main` after merge:
1. `git revert` the merge commit in the affected repo(s)
2. Update `CHANGE_MANIFEST.json` to reflect the revert (restore previous SHAs)
3. Create a new change request to fix the issue properly
4. Log the revert in `CHANGE_LOG.md` with status `REVERTED`
5. Update `MERGE_TRANSACTIONS.md` with `ROLLED_BACK` status

### Partial Merge Recovery

If backend merged but frontend merge fails (or vice versa):
1. Set CHANGE_LOG status to `PARTIAL_MERGE_BLOCKED`
2. Revert the successfully merged repo: `git revert <merge-commit-sha>`
3. DO NOT update `CHANGE_MANIFEST.json` (it should still reflect the pre-merge state)
4. Log `ROLLED_BACK` in `MERGE_TRANSACTIONS.md`
5. Fix the failing merge, then retry the full atomic sequence
6. Never leave repos in a mismatched state on `main`

---

## 16. Data Migration Rules (Future-Proofing)

V1 is stateless, but when persistence is added (database, cache, queue), these rules apply:

| Rule | Detail |
|------|--------|
| Reversibility | Every schema migration must have a corresponding rollback migration |
| Idempotency | Running a migration twice must produce the same result as running it once |
| Backfill strategy | If a new column/field is added, define how existing records get populated |
| Migration testing | Migrations are tested with fixture data in CI before deploy |
| Sequencing | Migrations must be numbered and applied in order |

**When to activate:** As soon as any of these are introduced: PostgreSQL, Redis, job queue (beyond in-memory `JobManager`), file-based cache, or any external state store.

Until then, these rules serve as placeholders so the Change Agent doesn't have to invent them under pressure.
