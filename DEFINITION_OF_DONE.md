# Definition of Done

> Checklist with hard gates and deterministic heuristics. Every item is pass/fail.
> The Review Agent MUST reject if ANY item fails.
>
> **Automated enforcement:** Run `make dod` in each affected repo. This script
> checks items marked **[H]** automatically. Items marked **[R]** require
> Review Agent judgment. Items marked **[A]** are enforced by lint rules at edit time.
>
> Legend: **[H]** = hard gate (script-enforced) | **[A]** = automated at lint time |
> **[R]** = Review Agent judgment (deterministic heuristic, not subjective)

## Per-Story Checklist (ALL must pass)

### Code

- [ ] Tests added or updated for new/changed functionality **[R]**
- [ ] `make check` passes in affected repo(s) (tests + lint + types) **[H]**
- [ ] `make dod` passes in affected repo(s) (automated DoD enforcement) **[H]**
- [ ] No live network calls in test files (all external calls mocked) **[H]** _(make dod)_
- [ ] IO only in allowed modules — detectors/analyzers accept inputs, never fetch **[H]** _(make dod)_
- [ ] Layering: non-IO modules do not import IO modules **[H]** _(make dod + test_layering.py)_
- [ ] No `print()` / `console.log()` in production code **[A]** _(ruff T201 / eslint no-console)_
- [ ] No bare `except Exception` in pure modules **[A]** _(ruff BLE001)_
- [ ] All new external calls have explicit timeouts and structured logging **[R]**
- [ ] All new IO calls use `log_event()` helper from `app/observability/logging.py` **[R]**

### Contracts (if schema touched)

- [ ] `contract_version` bumped in `CONTRACTS.md` (minor for additive, major for breaking) **[R]**
- [ ] Backend Pydantic models updated in `app/models/schemas.py` **[R]**
- [ ] Frontend TypeScript types updated in `src/types/api.ts` **[R]**
- [ ] Golden fixtures updated: `tests/fixtures/reports/` + `src/mocks/golden/` **[R]**
- [ ] `[SCHEMA_CHANGE]` label added to `CHANGE_LOG.md` **[R]**
- [ ] `CHANGE_MANIFEST.json` updated: `contract_version` + `compatibility` if breaking **[R]**
- [ ] `make contract-check` passes (version sync verified) **[H]**

### Documentation

- [ ] `ARCHITECTURE.md` updated (new files, changed interfaces, dependency changes) **[R]**
- [ ] `PROGRESS.md` updated with change entry and test counts **[R]**
- [ ] `CURRENT_TASKS.md` lock released **[R]**
- [ ] `CHANGE_LOG.md` entry exists with correct Change ID **[R]**

### Scope

- [ ] `git diff main` touches ONLY files related to the change **[R]** _(heuristic: Review Agent inspects diff)_
- [ ] No drive-by refactors of unrelated code **[R]**
- [ ] No new dependencies without `ARCHITECTURE.md` documentation **[R]**
- [ ] Commit messages follow format: `feat(CHG-NNN): <description>` **[R]**
- [ ] Every story has at least 1 "Out of Scope" item **[R]**

### Security (if URL/crawling changes)

- [ ] SSRF test cases pass (private IPs, localhost, internal ranges blocked) **[H]** _(test suite)_
- [ ] DNS rebinding protection: resolved IP validated before request **[H]** _(test suite)_
- [ ] Redirect cap enforced (max 3 hops, each hop re-validated) **[H]** _(test suite)_
- [ ] Max response size enforced (5 MB cap per page) **[H]** _(test suite)_
- [ ] `robots.txt` disallow respected (test exists) **[H]** _(test suite)_
- [ ] Max pages cap enforced (hard limit, test exists) **[H]** _(test suite)_
- [ ] Per-domain rate limit / concurrency cap enforced **[R]**

## Auto-Reject Triggers (11 deterministic rules)

If ANY of these are true, the Review Agent MUST reject immediately:

1. Contract changed without `contract_version` bump + fixture updates
2. New dependency added without `ARCHITECTURE.md` update
3. New endpoint/component added without tests
4. `git diff` includes files outside the change's allowed scope _(heuristic)_
5. Any live network call found in test files (no mocks)
6. Any HTTP/Playwright import in a non-IO module (IO boundary violation)
7. Any non-IO module importing an IO module (layering violation)
8. `make check` fails after review fixes
9. `make dod` fails after review fixes
10. `CHANGE_LOG.md` entry missing for the Change ID
11. Any of the 8 lifecycle steps was skipped — regardless of execution mode (INLINE or STANDARD) **[H]**

## Execution Modes

Changes run in one of two modes, selected during DECOMPOSE (see `CHANGE_PROCESS.md` §2.1):

- **INLINE**: Orchestrator develops and reviews directly (no agent spawn). All gates still apply.
- **STANDARD**: Dev agent(s) + Review Agent spawned as separate sub-agents.

Mode is determined by **surface-type criteria** (what files/modules are touched), never by perceived complexity or diff size. If INLINE execution discovers the change touches a sensitive surface, it escalates to STANDARD and adds `[MODE_ESCALATION]` label to `CHANGE_LOG.md`.

Both modes execute all 8 steps. Mode only controls *who* runs steps 3–6.

## Umbrella Reject Rule

In addition to the 11 triggers above: **reject if any DoD checklist item fails**, even if
it is not covered by a specific auto-reject trigger. The triggers catch the most common
failures deterministically; the checklist catches everything else.
