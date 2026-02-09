# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A full-stack web app that analyzes websites for governance issues (security, accessibility, performance, SEO) and compares them against local competitors. Python/FastAPI backend + React/TypeScript/Vite frontend in a monorepo with git submodules.

## Commands

### Workspace-level (from repo root)
```bash
make check-all          # Run all tests + lint + typecheck in both repos
make dod-all            # Run Definition of Done checks in both repos
make validate CHG=CHG-NNN  # Pre-merge validation for a specific change
./scripts/new_change_id.sh  # Allocate next CHG-NNN ID (reads CHANGE_MANIFEST.json)
./scripts/validate_change.sh CHG-NNN  # 13-point pre-merge validation
./scripts/plan_stats.sh  # Verify ENGINEERING_PLAN.md statistics
```

### Backend (from `backend/`)
```bash
make check              # Run tests + lint + typecheck
make test               # pytest tests/ -q --tb=short
make lint               # ruff check + ruff format --check
make typecheck          # mypy app/
make dod                # Definition of Done automated checks
make io-boundary-check  # Verify IO boundary rules
make contract-check     # Verify contract version sync

# Run a single test file
python -m pytest tests/test_pipeline.py -q --tb=short

# Run a single test by name
python -m pytest tests/test_pipeline.py -k "test_name" -q --tb=short

# Start dev server
uvicorn app.main:app --reload --port 8000
```

### Frontend (from `frontend/`)
```bash
make check              # Run tests + lint + typecheck
make test               # npx vitest run --reporter=dot
make lint               # npx eslint src/ --quiet
make typecheck          # npx tsc --noEmit
make dod                # Definition of Done automated checks

# Run a single test file
npx vitest run src/components/report/__tests__/report-tabs.test.tsx

# Run tests matching a pattern
npx vitest run -t "pattern"

# Start dev server
npm run dev             # localhost:5173
```

## Architecture

### Two-Pipeline System

**Governance Pipeline** (9 steps): URL normalize → fetch homepage → parse sitemap → sample pages (max 20) → run detectors → run PSI → build issues → generate checklist → build report

**SEO Pipeline** (13 steps): governance steps 1-9 (or reuse cached via `governance_job_id`) + analyze competitors → gap analysis → generate action plan → build SEO report

### Backend Layer Separation (Strictly Enforced)

The backend has a hard IO boundary. `make dod` and `test_layering.py` enforce this automatically.

**IO modules** (may do HTTP/external calls):
- `app/crawlers/` — html_fetcher, sitemap_parser, url_normalizer, page_sampler
- `app/services/` — psi_client, places_client, competitor_analyzer, pipeline, seo_pipeline
- `app/reasoning/gemini_summarizer.py` — hybrid (lives in reasoning/ but calls Gemini API)

**Pure logic modules** (accept data as args, no HTTP, no imports from crawlers/services):
- `app/detectors/` — stack, a11y, security, integration detection
- `app/reasoning/` — templates, issue_builder, checklist_generator, business_goals
- `app/seo/` — gap_analyzer, action_plan_generator
- `app/models/` — Pydantic schemas

### Frontend Layer Separation

- **`src/services/api-client.ts`** — the ONLY module that calls `fetch()`
- **`src/hooks/`** — call api-client, manage polling lifecycle
- **`src/pages/`** — orchestration boundary; may import api-client and hooks
- **`src/components/`** — receive ALL data via props; never import from services/

### API Endpoints (6 total)
- `GET /api/health`
- `POST /api/report/governance` → returns `job_id`, triggers background pipeline
- `GET /api/report/status/{job_id}` → polling endpoint (2.5s intervals)
- `POST /api/report/seo` → accepts competitors + optional `governance_job_id`
- `GET /api/report/suggest-competitors` → Google Places suggestions
- `POST /api/report/full` → combined governance + SEO

### Contract System

API contracts are version-pinned (currently v1.5.0). The source of truth is `CHANGE_MANIFEST.json` at workspace root. When schema changes:
1. Bump `contract_version` in both `backend/CONTRACTS.md` and `frontend/CONTRACTS.md` + `CHANGE_MANIFEST.json`
2. Update `app/models/schemas.py` (backend Pydantic) and `src/types/api.ts` (frontend TypeScript)
3. Update golden fixtures in both `backend/tests/fixtures/reports/` and `frontend/src/mocks/golden/`
4. Add `[SCHEMA_CHANGE]` label to the CHANGE_LOG.md entry

## Making Changes — The 8-Step Lifecycle

**Every change to this codebase follows the 8-step lifecycle defined in `CHANGE_PROCESS.md`. No step is ever skipped.** The `.cursor/rules/change-agent.mdc` file contains the Cursor-specific operational checklist — this section is the Claude Code equivalent.

### ⛔ Absolute Invariants — NEVER Violate These

These rules are NON-NEGOTIABLE. They apply to EVERY change, regardless of size, mode, or urgency:

1. **NEVER commit directly to main in any submodule** — Always create `change/CHG-NNN-desc` branch first
2. **NEVER merge without `--no-ff`** — Every merge must create a merge commit for traceability
3. **NEVER skip MERGE_TRANSACTIONS.md** — Log STARTED before merge, COMPLETED after
4. **NEVER write implementation code before writing failing tests** (unless pure config/copy change)
5. **NEVER merge without running `./scripts/validate_change.sh CHG-NNN`** — If it fails, FIX violations first
6. **NEVER skip the DECOMPOSE output** — User must see preflight, outcome, stories, confidence, and mode BEFORE code is written

### Before Writing Any Code

1. **Read context files:** `CHANGE_PROCESS.md`, `CHANGE_MANIFEST.json`, `backend/ARCHITECTURE.md`, `frontend/ARCHITECTURE.md`, `backend/CONTRACTS.md` or `frontend/CONTRACTS.md` (whichever is affected)
2. **Pre-flight invariant check** — reject if the change violates V1 non-goals:
   - No authentication, report history/snapshots, scheduled emails, GA/GSC connection, PDF export, or SEO rankings promises
   - Max 20 pages per analysis, deterministic reasoning only (no free-form LLM analysis), respect robots.txt
   - No permanent state without a rollback path
3. **Outcome framing** — what success metric does this affect? Is there a cheaper/safer way?
4. **Story formation** — write stories with testable acceptance criteria, Risk Level (LOW/MEDIUM/HIGH), and mandatory Out of Scope items
5. **Confidence signal** — rate HIGH/MEDIUM/LOW; LOW biases toward smaller stories
6. **Allocate CHG ID** — run `./scripts/new_change_id.sh`, log entry in `CHANGE_LOG.md` as IN_PROGRESS
7. **Select execution mode** — INLINE or STANDARD (see below)

**Output a DECOMPOSE block to the user showing preflight, outcome, stories, confidence, and mode BEFORE touching any files.**

Example DECOMPOSE format:
```
## CHG-NNN: [Title]

**PREFLIGHT**: PASS — does not violate V1 non-goals or core invariants
**OUTCOME**: metric=conversion/reliability/speed/trust, means-vs-end=end, cheaper-way=no
**CONFIDENCE**: HIGH/MEDIUM/LOW — [reason]

### Stories
1. [Story title] — Risk: LOW/MEDIUM/HIGH
   - Acceptance: [testable criteria]
   - Out of Scope: [at least 1 item]
2. ...

**MODE**: INLINE/STANDARD
| Criterion | Value | Result |
|-----------|-------|--------|
| Schema/contract change? | yes/no | ... |
| New files created? | yes/no | ... |
| IO/security/pipeline module touched? | yes/no | ... |
| Single-repo only? | yes/no | ... |
| Config/copy/style only? | yes/no | ... |
→ All criteria met = INLINE. Any fails = STANDARD.
```

### Execution Mode Selection

**INLINE** (all must be true): no contract/schema change, no new files/modules, no IO-boundary/security/pipeline module touched, single-repo only, config/copy/CSS changes only.

**STANDARD** (any one triggers it): schema or contract touched, new modules created, IO/security/pipeline module touched, both repos need changes, logic or API behavior changes, new dependencies, LOW confidence.

Mode controls *who* runs steps 3-6 (orchestrator vs spawned agents), not *whether* they run.

### The 8 Steps

**Use TodoWrite to track progress**: Create todos for each major step and mark them completed only after execution. This helps track progress and ensures no steps are skipped.

| Step | What Happens |
|------|-------------|
| 1. DECOMPOSE | Context gather, pre-flight, outcome, stories, confidence, mode — output to user |
| 2. BRANCH | `change/CHG-NNN-desc` in each affected submodule (never commit to main) |
| 3. DEVELOP | TDD: write test → must fail → implement → must pass → `make check` |
| 4. DOCUMENT | Update ARCHITECTURE.md, PROGRESS.md, CHANGE_LOG.md; ENGINEERING_PLAN.md every 5 changes or on significant arch change |
| 5. DOD | Run `make dod` in affected repos, walk DEFINITION_OF_DONE.md checklist |
| 6. REVIEW | STANDARD: spawn review agent. INLINE: review inline (git diff, auto-reject triggers) |
| 7. MERGE GATE | `./scripts/validate_change.sh CHG-NNN` must pass, then atomic `--no-ff` merge |
| 8. REPORT | Update CHANGE_LOG.md to COMPLETE, summarize to user |

### Merge Protocol (Atomic Cross-Repo)

```bash
# 1. Log STARTED in MERGE_TRANSACTIONS.md BEFORE merging
# 2. Merge each affected submodule:
cd backend && git checkout main && git merge --no-ff change/CHG-NNN-desc -m "merge(CHG-NNN): description"
cd ../frontend && git checkout main && git merge --no-ff change/CHG-NNN-desc -m "merge(CHG-NNN): description"
# 3. If either fails: revert the other, log ROLLED_BACK
# 4. Update CHANGE_MANIFEST.json with merge commit SHAs
# 5. Log COMPLETED in MERGE_TRANSACTIONS.md
# 6. Update CHANGE_LOG.md status to COMPLETE
```

### Naming Conventions

| Item | Format | Example |
|------|--------|---------|
| Change ID | `CHG-NNN` (always uppercase) | `CHG-014` |
| Branch | `change/CHG-NNN-short-desc` | `change/CHG-014-add-retry` |
| Dev commit | `feat(CHG-NNN): desc` or `fix(CHG-NNN): desc` | `feat(CHG-014): add retry button` |
| Merge commit | `merge(CHG-NNN): desc` | `merge(CHG-014): retry button feature` |

### Review Auto-Reject Triggers

During Step 6 (REVIEW), reject immediately if ANY of these conditions are true:

1. `make check` fails in any affected repo
2. `make dod` fails in any affected repo
3. Live network calls found in test files (not mocked)
4. IO imports found in pure modules (detectors, reasoning, seo, models)
5. `print()` or `console.log()` in production code
6. Direct commits to main branch (no feature branch)
7. Merge would use fast-forward (no merge commit)
8. Schema changed but contract version not bumped
9. CHANGE_LOG.md entry missing or incomplete
10. ARCHITECTURE.md not updated for code changes
11. Out of Scope section missing from stories

### Kill Switch (Attempt Budget)

If stuck, stop after: 3 distinct strategies for pure logic (2 consecutive test failures), 3 strategies for integration (3 failures), 1 attempt for external API failure. Write to `BLOCKERS.md`, commit WIP, and report.

### Claude Code Hooks (Automated Reminders)

Project-level hooks are configured in `.claude/settings.json` and scripts live in `.claude/hooks/`:

- **PostToolUse (Write|Edit):** After editing files in `backend/app/`, `backend/tests/`, or `frontend/src/`, reminds to run `make check` in the affected repo.
- **PreToolUse (Bash):** Before `git merge --no-ff` commands, reminds to verify `validate_change.sh` passed and `MERGE_TRANSACTIONS.md` has a STARTED entry. Warns if committing directly to main in a submodule.

These are soft reminders, not hard gates. The hard gates remain in `validate_change.sh` and `check_dod.sh`.

## Process Document Map

| File | Purpose | When to Update |
|------|---------|---------------|
| `CHANGE_PROCESS.md` | 8-step lifecycle definition | Process changes only |
| `DEFINITION_OF_DONE.md` | Checklist with hard gates [H] and review items [R] | Process changes only |
| `CHANGE_LOG.md` | Append-only history of all CHG entries | Every change (Step 1 + Step 8) |
| `CHANGE_MANIFEST.json` | Contract version, last CHG ID, merge SHAs | Every merge (Step 7) |
| `MERGE_TRANSACTIONS.md` | Audit log of merge sequences | Every merge (Step 7) |
| `ENGINEERING_PLAN.md` | Master plan, version history table, current stats | Every 5 changes or when test counts/endpoints/architecture significantly change |
| `backend/ARCHITECTURE.md` | Backend file tree, module deps, interfaces | Every backend change |
| `frontend/ARCHITECTURE.md` | Frontend component tree, routing, data flow | Every frontend change |
| `backend/CONTRACTS.md` | API schema (Pydantic models) | Schema changes only |
| `frontend/CONTRACTS.md` | API schema (TypeScript types) | Schema changes only |
| `backend/PROGRESS.md` | Backend change entries + test counts | Every backend change |
| `frontend/PROGRESS.md` | Frontend change entries + test counts | Every frontend change |
| `backend/CURRENT_TASKS.md` | Task lock (claim/release cycle) | During development |
| `frontend/CURRENT_TASKS.md` | Task lock (claim/release cycle) | During development |
| `backend/REVIEW_LOG.md` | Review findings, institutional learning | After review (Step 6) |
| `frontend/REVIEW_LOG.md` | Review findings, institutional learning | After review (Step 6) |
| `backend/BLOCKERS.md` | Blocked tasks + what was tried | When kill switch triggers |
| `frontend/BLOCKERS.md` | Blocked tasks + what was tried | When kill switch triggers |
| `.claude/settings.json` | Claude Code hooks configuration | When hooks are added/modified |
| `.claude/hooks/` | Hook scripts (remind-make-check, check-merge-compliance) | When hook behavior changes |

## Tech Stack

| Layer | Stack |
|-------|-------|
| Backend | Python 3.12+, FastAPI, Pydantic, httpx, BeautifulSoup, Playwright, google-generativeai |
| Frontend | React 19, TypeScript 5.9, Vite 7, Tailwind CSS v4, react-router-dom |
| Backend tests | pytest, pytest-asyncio (asyncio_mode=auto) |
| Frontend tests | Vitest, React Testing Library, jsdom |
| Backend lint | ruff (check + format), mypy |
| Frontend lint | ESLint, TypeScript strict |

## Testing Conventions

- All external HTTP calls must be mocked in tests — `make dod` rejects live network calls in test files
- **TDD is mandatory**: write failing test first, then implement, then `make check`
  - Write test(s) FIRST
  - Run them — they MUST fail (capture and show terminal output demonstrating failure)
  - Write implementation
  - Run them — they MUST pass (capture and show terminal output demonstrating success)
  - Only exception: pure config/copy changes where tests aren't applicable
- Backend async tests use `asyncio_mode = "auto"` (no manual `@pytest.mark.asyncio` needed)
- Golden fixtures validate API contract shape: `backend/tests/fixtures/reports/` and `frontend/src/mocks/golden/`
- Backend fixtures live in `tests/fixtures/` (html/, sitemaps/, psi/, places/, reports/)
- Frontend component tests are co-located at `src/components/**/__tests__/`
- Narrative drift guard: `test_business_narrative.py` catches stale fixture text

## Configuration

Backend loads settings from `.env` via pydantic-settings. Key vars:
- `PSI_API_KEY` — Google PageSpeed Insights
- `PLACES_API_KEY` — Google Places API
- `GEMINI_API_KEY` — Gemini 2.5 Pro
- `DEMO_MODE=true` — returns fixture data instantly (for testing)

All APIs degrade gracefully when keys are missing.

## Security Rules (When Touching URL/Crawling Code)

- SSRF prevention: block private IPs (10.x, 172.16-31.x, 192.168.x), localhost, ::1
- DNS rebinding: resolve hostname → validate IP is not private before each request
- Redirect cap: max 3 hops, re-validate each hop; only http→https scheme change allowed
- Max response size: 5 MB per page (stream + abort)
- robots.txt: respect disallowed paths
- Max pages: hard limit of 20
- URL schemes: only http:// and https:// (no file://, ftp://, javascript:)
