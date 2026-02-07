# Definition of Done

> Binary, machine-checkable checklist. Every item is pass/fail.
> The Review Agent MUST reject if ANY item fails.

## Per-Story Checklist (ALL must pass)

### Code

- [ ] Tests added or updated for new/changed functionality
- [ ] `make check` passes in affected repo(s) (tests + lint + types)
- [ ] No live network calls in test files (all external calls mocked)
- [ ] IO only in allowed modules (`app/crawlers/`, `app/services/*_client.py`) — detectors accept inputs, never fetch
- [ ] No `print()` / `console.log()` in production code
- [ ] No bare `except Exception` — catch specific exceptions
- [ ] All new external calls have explicit timeouts and structured logging

### Contracts (if schema touched)

- [ ] `contract_version` bumped in `CONTRACTS.md` (minor for additive, major for breaking)
- [ ] Backend Pydantic models updated in `app/models/schemas.py`
- [ ] Frontend TypeScript types updated in `src/types/api.ts`
- [ ] Golden fixtures updated: `tests/fixtures/reports/` + `src/mocks/golden/`
- [ ] `[SCHEMA CHANGE]` flagged in `PROGRESS.md`
- [ ] `CHANGE_MANIFEST.json` updated with new `contract_version`

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
- [ ] `robots.txt` disallow respected (test exists)
- [ ] Max pages cap enforced (hard limit, test exists)
- [ ] Per-domain rate limit / concurrency cap enforced

## Auto-Reject Triggers

If ANY of these are true, the Review Agent MUST reject immediately:

1. Contract changed without `contract_version` bump + fixture updates
2. New dependency added without `ARCHITECTURE.md` update
3. New endpoint added without tests
4. `git diff` includes files outside the change's allowed scope
5. Any live network call found in test files (no mocks)
6. Any Playwright/HTTP call in a detector module (IO boundary violation)
7. `make check` fails after review fixes
8. `CHANGE_LOG.md` entry missing for the Change ID
