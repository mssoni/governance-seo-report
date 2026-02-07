# Definition of Done

> Binary, machine-checkable checklist. Every item is pass/fail.
> The Review Agent MUST reject if ANY item fails.
>
> **Automated enforcement:** Run `make dod` in each affected repo. This script
> checks items 3-6 in "Code" and contract version sync automatically.
> Items not covered by the script require manual (Review Agent) verification.

## Per-Story Checklist (ALL must pass)

### Code

- [ ] Tests added or updated for new/changed functionality
- [ ] `make check` passes in affected repo(s) (tests + lint + types)
- [ ] `make dod` passes in affected repo(s) (automated DoD enforcement)
- [ ] No live network calls in test files (all external calls mocked) _(automated: `make dod`)_
- [ ] IO only in allowed modules — detectors/analyzers accept inputs, never fetch _(automated: `make dod`)_
- [ ] Layering: non-IO modules do not import IO modules _(automated: `make dod`)_
- [ ] No `print()` / `console.log()` in production code _(automated: ruff T201 / eslint no-console)_
- [ ] No bare `except Exception` — catch specific exceptions _(automated: ruff BLE001)_
- [ ] All new external calls have explicit timeouts and structured logging

### Contracts (if schema touched)

- [ ] `contract_version` bumped in `CONTRACTS.md` (minor for additive, major for breaking)
- [ ] Backend Pydantic models updated in `app/models/schemas.py`
- [ ] Frontend TypeScript types updated in `src/types/api.ts`
- [ ] Golden fixtures updated: `tests/fixtures/reports/` + `src/mocks/golden/`
- [ ] `[SCHEMA_CHANGE]` label added to `CHANGE_LOG.md`
- [ ] `CHANGE_MANIFEST.json` updated: `contract_version` + `compatibility` if breaking
- [ ] `make contract-check` passes (version sync verified) _(automated)_

### Documentation

- [ ] `ARCHITECTURE.md` updated (new files, changed interfaces, dependency changes)
- [ ] `PROGRESS.md` updated with change entry and test counts
- [ ] `CURRENT_TASKS.md` lock released
- [ ] `CHANGE_LOG.md` entry exists with correct Change ID

### Scope

- [ ] `git diff main` touches ONLY files related to the change
- [ ] No drive-by refactors of unrelated code
- [ ] No new dependencies without `ARCHITECTURE.md` documentation
- [ ] Commit messages follow format: `feat(CHG-NNN): <description>`

### Security (if URL/crawling changes)

- [ ] SSRF test cases pass (private IPs, localhost, internal ranges blocked)
- [ ] DNS rebinding protection: resolved IP validated before request
- [ ] Redirect cap enforced (max 3 hops, each validated)
- [ ] `robots.txt` disallow respected (test exists)
- [ ] Max pages cap enforced (hard limit, test exists)
- [ ] Per-domain rate limit / concurrency cap enforced

## Auto-Reject Triggers

If ANY of these are true, the Review Agent MUST reject immediately:

1. Contract changed without `contract_version` bump + fixture updates
2. New dependency added without `ARCHITECTURE.md` update
3. New endpoint/component added without tests
4. `git diff` includes files outside the change's allowed scope
5. Any live network call found in test files (no mocks)
6. Any HTTP/Playwright import in a non-IO module (IO boundary violation)
7. Any non-IO module importing an IO module (layering violation)
8. `make check` fails after review fixes
9. `make dod` fails after review fixes
10. `CHANGE_LOG.md` entry missing for the Change ID
