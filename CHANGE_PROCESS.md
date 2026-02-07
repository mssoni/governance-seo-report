# Change Process

> How changes are requested, developed, reviewed, and merged after V1 is complete.

## Overview

Every change to the application follows a **7-step lifecycle**. The assistant acts as a **Change Agent** (orchestrator) — the user provides a plain-English change request and the agent handles everything else: decomposition, branching, parallel development, testing, review, documentation, and merge.

**Zero manual routing required.** The user's only role is to describe the change.

---

## 1. Input Format

The user provides a change request as a natural language prompt. Examples:

- "Add PDF export to the governance report"
- "Add a dark mode toggle to the report page"
- "Fix the performance score showing NaN when PSI fails"
- "Add email capture CTA before showing the SEO report"

The Change Agent reads the request and proceeds automatically.

---

## 2. The 7-Step Lifecycle

```
User Prompt
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 1: DECOMPOSE                                   │
│ - Read ARCHITECTURE.md (both repos)                 │
│ - Read CONTRACTS.md for current schemas             │
│ - Identify affected modules/files                   │
│ - Create user stories with acceptance criteria      │
│ - Determine: backend-only, frontend-only, or both   │
│ - Assign Change ID (CHG-NNN)                        │
│ - Write stories to CHANGE_LOG.md                    │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 2: BRANCH                                      │
│ - Create branch in affected repos:                  │
│   change/<change-id>-<short-description>            │
│ - Both repos use the SAME branch name               │
│ - Example: change/chg-001-pdf-export                │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 3: DEVELOP (parallel agents)                   │
│ - Spawn Agent A (backend) + Agent B (frontend)      │
│   using the Task tool, on feature branches          │
│ - Each agent follows TDD:                           │
│   1. Write test → must fail                         │
│   2. Implement → test must pass                     │
│   3. Run `make check` → all green                   │
│ - Contract-First if schema changes:                 │
│   Update CONTRACTS.md → types → golden fixtures     │
│ - If only one repo affected, spawn only one agent   │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 4: DOCUMENT (part of each agent's task)        │
│ - ARCHITECTURE.md — new files, changed interfaces   │
│ - PROGRESS.md — change entry with test counts       │
│ - CURRENT_TASKS.md — claim/release cycle            │
│ - CONTRACTS.md — if any schema changed              │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 5: REVIEW                                      │
│ - Spawn Review Agent (separate sub-agent)           │
│ - Runs `make check` in both repos                   │
│ - Reviews: code quality, schema alignment,          │
│   copy tone, accessibility, test coverage           │
│ - Auto-fixes small issues (lint, format, logs)      │
│ - Rejects architectural issues to REVIEW_LOG.md     │
│ - Appends findings to REVIEW_LOG.md                 │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 6: MERGE                                       │
│ - Merge feature branch to main (both repos)         │
│ - No force pushes                                   │
│ - Commit message: merge(CHG-NNN): [description]     │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Step 7: REPORT                                      │
│ - Update CHANGE_LOG.md status to COMPLETE           │
│ - Summarize to user:                                │
│   - What changed (files, modules)                   │
│   - Tests added/modified                            │
│   - Docs updated                                    │
│   - Any warnings or follow-ups                      │
└─────────────────────────────────────────────────────┘
```

---

## 3. Agent Prompts

### Backend Dev Agent Prompt Template

```
You are AGENT A (Backend Developer) for a change to the Website Governance + SEO Report tool.

WORKSPACE: /Users/mayureshsoni/CascadeProjects/governance-seo-report/backend
BRANCH: change/<change-id>-<short-description>

## FIRST STEPS
1. Run `git checkout -b <branch-name>` (or switch to it if it exists)
2. Read AGENT_PROMPT.md for workflow rules
3. Read ARCHITECTURE.md for current codebase
4. Run `make check` to verify green baseline

## CHANGE REQUEST
Change ID: CHG-NNN
Description: <user's change request>

## STORIES
<generated stories with acceptance criteria and test cases>

## TDD WORKFLOW
1. Write test file FIRST
2. Run test → MUST FAIL
3. Implement
4. Run test → MUST PASS
5. Run `make check` → ALL must pass
6. Update ARCHITECTURE.md, PROGRESS.md, CURRENT_TASKS.md
7. Commit: `feat(CHG-NNN): <description>`

## WHEN DONE
Return: stories completed, test counts, files changed, any blockers.
```

### Frontend Dev Agent Prompt Template

```
You are AGENT B (Frontend Developer) for a change to the Website Governance + SEO Report tool.

WORKSPACE: /Users/mayureshsoni/CascadeProjects/governance-seo-report/frontend
BRANCH: change/<change-id>-<short-description>

## FIRST STEPS
1. Run `git checkout -b <branch-name>` (or switch to it if it exists)
2. Read AGENT_PROMPT.md for workflow rules
3. Read ARCHITECTURE.md for current codebase
4. Run `make check` to verify green baseline

## CHANGE REQUEST
Change ID: CHG-NNN
Description: <user's change request>

## STORIES
<generated stories with acceptance criteria and test cases>

## TDD WORKFLOW
1. Write test file FIRST
2. Run test → MUST FAIL
3. Implement
4. Run test → MUST PASS
5. Run `make check` → ALL must pass
6. Update ARCHITECTURE.md, PROGRESS.md, CURRENT_TASKS.md
7. Commit: `feat(CHG-NNN): <description>`

## WHEN DONE
Return: stories completed, test counts, files changed, any blockers.
```

### Review Agent Prompt Template

```
You are the REVIEW AGENT for change CHG-NNN.

BACKEND: /Users/mayureshsoni/CascadeProjects/governance-seo-report/backend
FRONTEND: /Users/mayureshsoni/CascadeProjects/governance-seo-report/frontend

## REVIEW STEPS
1. Run `make check` in BOTH repos — all must pass
2. Review code changes on the feature branch (git diff main)
3. Check: schema alignment, copy tone, accessibility, test coverage
4. Check: ARCHITECTURE.md and PROGRESS.md updated
5. Auto-fix small issues (lint, format, missing logs)
6. Reject architectural issues to REVIEW_LOG.md
7. Append review entry to REVIEW_LOG.md
8. If approved: report approval status

## CHANGE REVIEW CHECKLIST (in addition to standard checklist)
- [ ] No regressions: all pre-existing tests still pass
- [ ] No breaking schema changes without [BREAKING] flag
- [ ] No unrelated files modified (scope discipline)
- [ ] New functionality has tests
- [ ] Docs updated (ARCHITECTURE.md, PROGRESS.md)

## RETURN FORMAT
- Stories: status per story
- Issues found and fixed
- Test counts (both repos)
- Approval status
```

---

## 4. Git Branching Convention

| Item | Convention |
|------|-----------|
| Branch naming | `change/<change-id>-<short-description>` |
| Example | `change/chg-001-pdf-export` |
| Both repos | Use the SAME branch name for traceability |
| Base branch | Always branch from `main` |
| Merge strategy | Merge to `main` after review passes |
| Force push | Never |
| Commit format (dev) | `feat(CHG-NNN): <what was built>` |
| Commit format (review fix) | `fix(CHG-NNN): <what was fixed per review>` |
| Commit format (merge) | `merge(CHG-NNN): <change description>` |

---

## 5. Contract-First Rule

If a change modifies any API request/response schema:

1. Update `CONTRACTS.md` FIRST (both repos share this file in backend)
2. Update backend Pydantic models in `app/models/schemas.py`
3. Update frontend TypeScript types in `src/types/api.ts`
4. Update golden fixtures: `tests/fixtures/reports/` (backend), `src/mocks/golden/` (frontend)
5. Flag in `PROGRESS.md`: `[SCHEMA CHANGE] CHG-NNN: description`

---

## 6. Quality Gates

### Before Development Starts
- `make check` must pass in both repos (green baseline)

### After Development
- `make check` must pass in both repos
- Backend: pytest + ruff + mypy
- Frontend: vitest + eslint + tsc --noEmit

### After Review
- `make check` must pass after any review fixes
- REVIEW_LOG.md entry appended

---

## 7. Kill Switch

If an agent is stuck > 20 minutes or > 3 failing approaches:
1. Write to `BLOCKERS.md` with: what was attempted, what failed, proposed alternative
2. Release lock in `CURRENT_TASKS.md`
3. Commit WIP with message: `wip(CHG-NNN): blocked — see BLOCKERS.md`
4. Report blocker to orchestrator for reassignment or user input

---

## 8. Change ID Assignment

Change IDs are sequential: `CHG-001`, `CHG-002`, etc.

The Change Agent reads `CHANGE_LOG.md` to determine the next available ID.

---

## 9. When Only One Repo Is Affected

Not every change requires both agents:

- **Backend-only** (new API endpoint, pipeline fix): spawn only Agent A
- **Frontend-only** (UI tweak, new component): spawn only Agent B
- **Both** (new feature end-to-end, schema change): spawn both in parallel

The Change Agent determines this during Step 1 (Decompose).

---

## 10. Rollback

If a change breaks `main` after merge:
1. `git revert` the merge commit in the affected repo(s)
2. Create a new change request to fix the issue properly
3. Log the revert in `CHANGE_LOG.md`
