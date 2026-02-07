# Change Process v2.0

> How changes are requested, developed, reviewed, and merged after V1 is complete.
> Revised based on swarm reliability review — addresses merge safety, contract versioning,
> IO boundaries, flaky test protocol, and deterministic rejection.

## Overview

Every change follows an **8-step lifecycle**. The assistant acts as a **Change Agent** (orchestrator) — the user provides a plain-English change request and the agent handles everything autonomously.

**Minimal manual routing.** The user's only role is to describe the change. If acceptance criteria cannot be written objectively, the orchestrator escalates with a `NEEDS_PRODUCT_DECISION` label.

---

## 1. Input Format

The user provides a change request as a natural language prompt. Examples:

- "Add PDF export to the governance report"
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
│ Step 1: DECOMPOSE                                   │
│ - Read ARCHITECTURE.md (both repos)                 │
│ - Read CONTRACTS.md + CHANGE_MANIFEST.json          │
│ - Identify affected modules/files                   │
│ - Create user stories with acceptance criteria      │
│ - If AC can't be objective → NEEDS_PRODUCT_DECISION │
│ - Determine: backend-only, frontend-only, or both   │
│ - Assign Change ID (CHG-NNN)                        │
│ - Write stories to CHANGE_LOG.md                    │
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
│ Step 3: DEVELOP (parallel agents)                   │
│ - Spawn Agent A (backend) + Agent B (frontend)      │
│ - Each agent follows TDD:                           │
│   1. Write test → must fail                         │
│   2. Implement → test must pass                     │
│   3. Run `make check` → all green                   │
│ - Contract-First if schema changes:                 │
│   Bump contract_version → update CONTRACTS.md       │
│   → types → golden fixtures → CHANGE_MANIFEST.json  │
│ - IO boundary enforced: only fetch modules do HTTP  │
│ - If only one repo affected, spawn only one agent   │
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
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 5: DEFINITION OF DONE (agent self-check)       │
│ - Each agent runs the DoD checklist before commit   │
│ - See DEFINITION_OF_DONE.md for the full list       │
│ - If any item fails → fix before committing         │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 6: REVIEW                                      │
│ - Spawn Review Agent (separate sub-agent)           │
│ - Runs `make check` in both repos                   │
│ - Runs DoD checklist (DEFINITION_OF_DONE.md)        │
│ - Checks auto-reject triggers (reject immediately   │
│   if any trigger fires — see DoD)                   │
│ - Auto-fixes small issues (lint, format, logs)      │
│ - Rejects architectural issues to REVIEW_LOG.md     │
│ - Checks for flaky tests (FLAKY_TESTS.md protocol)  │
│ - Appends findings to REVIEW_LOG.md                 │
│ - If approved: APPROVE status (does NOT merge)      │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 7: MERGE GATE                                  │
│ - Review Agent reports APPROVED status               │
│ - Orchestrator verifies:                            │
│   1. `make check` green in both repos               │
│   2. CHANGE_MANIFEST.json updated with commit SHAs  │
│   3. CHANGE_LOG.md entry is complete                 │
│   4. No NEEDS_PRODUCT_DECISION items unresolved     │
│ - Merge feature branch to main (both repos)         │
│ - Update CHANGE_MANIFEST.json with final SHAs       │
│ - No force pushes                                   │
│ - Commit: merge(CHG-NNN): [description]             │
│                                                     │
│ NOTE: When remote CI is configured, merge requires  │
│ CI green on the remote. Local make check is the     │
│ minimum gate until CI is set up.                    │
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

## 3. Naming Convention (Case-Stable, One Format Everywhere)

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

## 4. Contract Versioning

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

## 5. Cross-Repo Compatibility Pin (CHANGE_MANIFEST.json)

Both repos reference a shared manifest at the workspace root:

```json
{
  "contract_version": "1.0.0",
  "last_change_id": "CHG-001",
  "backend_commit": "abc123",
  "frontend_commit": "def456",
  "updated_at": "2026-02-07",
  "notes": "Added PDF export"
}
```

**Rules:**
- Updated after every merge (Step 7)
- Backend and frontend commit SHAs must both be recorded
- If only one repo changes, the other repo's SHA stays the same
- Review Agent checks that `contract_version` matches between CONTRACTS.md and manifest

---

## 6. IO Boundary Rule

**Hard rule:** Only designated modules may perform HTTP, Playwright, or external API calls.

### Backend
| Allowed IO modules | Purpose |
|-------------------|---------|
| `app/crawlers/html_fetcher.py` | Fetch web pages |
| `app/crawlers/sitemap_parser.py` | Fetch/parse sitemaps |
| `app/services/psi_client.py` | PageSpeed Insights API |
| `app/services/places_client.py` | Google Places API |
| `app/services/gemini_summarizer.py` | Gemini API |
| `app/services/competitor_analyzer.py` | Orchestrates IO calls |
| `app/services/pipeline.py` | Orchestrates IO calls |
| `app/services/seo_pipeline.py` | Orchestrates IO calls |

**Everything else (detectors, templates, issue builders, gap analyzers, action plan generators) MUST accept data as function arguments. No HTTP calls. No file reads. Pure functions.**

### Frontend
| Allowed IO modules | Purpose |
|-------------------|---------|
| `src/services/api-client.ts` | Backend API calls |
| `src/hooks/useJobPolling.ts` | Polling via api-client |
| `src/hooks/useSeoJobPolling.ts` | Polling via api-client |

**All components receive data via props. No direct fetch/axios calls in components.**

### Test Enforcement
- Tests for detectors/analyzers/generators use fixtures ONLY (never live calls)
- Tests for IO modules mock the HTTP layer (httpx mock, vi.mock)
- Review Agent auto-rejects any Playwright/HTTP import in a non-IO module

---

## 7. Kill Switch (Conditional Thresholds)

| Task Type | Time Limit | Approach Limit | Action |
|-----------|-----------|---------------|--------|
| Pure logic (normalizer, template, builder) | 20 min | 3 distinct strategies | BLOCKERS.md + release lock |
| Integration/IO (endpoint, pipeline, API client) | 45 min | 3 distinct strategies | BLOCKERS.md + release lock |
| External dependency failure (API quota, PSI down, DNS) | Immediate | 1 attempt | BLOCKERS.md + fallback plan |

**"Approach"** = a distinct strategy (different algorithm, different library, different architecture). Repeated retries of the same approach do NOT count as separate approaches.

When triggered:
1. Write to `BLOCKERS.md`: what was attempted, what failed, proposed alternative
2. Release lock in `CURRENT_TASKS.md`
3. Commit WIP: `wip(CHG-NNN): blocked — see BLOCKERS.md`
4. Report blocker to orchestrator

---

## 8. Observability Requirements

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

### Retry Policy
- Max 1 retry for retryable errors
- Exponential backoff: 2s base, max 10s
- Never retry non-retryable errors
- Log both the original error and the retry outcome

---

## 9. Security Constraints (Required Tests)

For any change that touches URL handling, crawling, or fetching:

| Constraint | Required Test |
|-----------|--------------|
| SSRF prevention | Private IPs (10.x, 172.16-31.x, 192.168.x), localhost, ::1 blocked |
| robots.txt respect | Disallowed paths not crawled (best effort) |
| Max pages cap | Hard limit of 12 pages per analysis (enforced + tested) |
| Per-domain rate limit | Max 2 concurrent requests per domain |
| URL scheme whitelist | Only `http://` and `https://` allowed (no `file://`, `ftp://`, `javascript:`) |
| Timeout enforcement | Per-fetch timeout of 15s, overall pipeline timeout of 90s |

These tests must exist and pass. The Review Agent rejects if any are missing when relevant code is changed.

---

## 10. Escalation Paths

Not all requests can be handled autonomously.

### NEEDS_PRODUCT_DECISION

Add this label to the CHANGE_LOG entry when:
- Acceptance criteria cannot be written objectively ("make it look better")
- The change has UX trade-offs requiring human judgment
- The change affects sales/conversion copy tone
- Multiple valid approaches exist with significantly different user impact

**Action:** Orchestrator asks the user for clarification before proceeding. Does NOT spawn agents.

### NEEDS_ARCHITECTURE_REVIEW

Add this label when:
- The change requires a new external dependency
- The change restructures more than 3 modules
- The change introduces a new data store or caching layer

**Action:** Orchestrator describes the architectural options and asks the user to choose before proceeding.

---

## 11. Agent Prompt Templates

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
- Contract-First if schema changes: bump contract_version, update all artifacts
- Before committing: run DEFINITION_OF_DONE.md checklist
- Commit: feat(CHG-NNN): <description>
- Update: ARCHITECTURE.md, PROGRESS.md, CURRENT_TASKS.md

## KILL SWITCH
- Pure logic: 20 min / 3 approaches
- Integration: 45 min / 3 approaches
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

## STEPS
1. Run `make check` in both repos
2. Run DEFINITION_OF_DONE.md checklist — reject if any item fails
3. Check auto-reject triggers — reject immediately if any fire
4. Review code: schema alignment, copy tone, accessibility, test coverage
5. Check IO boundary: no HTTP in detector/analyzer/template modules
6. Check for flaky tests (FLAKY_TESTS.md protocol)
7. Auto-fix small issues (lint, format, missing logs)
8. Append findings to REVIEW_LOG.md
9. Report: APPROVED or REJECTED with reasons

## AUTO-REJECT TRIGGERS (immediate reject, no fix attempt)
1. Contract changed without contract_version bump + fixture updates
2. New dependency without ARCHITECTURE.md update
3. New endpoint without tests
4. Scope drift (diff touches files outside change scope)
5. Live network call in test files
6. HTTP/Playwright import in non-IO module
7. make check fails after review fixes
8. CHANGE_LOG.md entry missing

## IMPORTANT
You do NOT merge. You report APPROVED/REJECTED status.
The orchestrator handles the merge gate.
```

---

## 12. Rollback

If a change breaks `main` after merge:
1. `git revert` the merge commit in the affected repo(s)
2. Update `CHANGE_MANIFEST.json` to reflect the revert
3. Create a new change request to fix the issue properly
4. Log the revert in `CHANGE_LOG.md` with status `REVERTED`
