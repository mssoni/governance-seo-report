# Change Log

> Append-only history of all change requests after V1 completion.
> See [CHANGE_PROCESS.md](CHANGE_PROCESS.md) for the full lifecycle.

## How to Read This File

Each entry follows this format:

```
### CHG-NNN: <Short Title>

- **Date**: YYYY-MM-DD
- **Status**: IN_PROGRESS | COMPLETE | REVERTED | NEEDS_PRODUCT_DECISION | NEEDS_ARCHITECTURE_REVIEW
- **Request**: <User's original prompt>
- **Scope**: backend-only | frontend-only | both
- **Branch**: change/CHG-NNN-short-description
- **Contract Version**: v1.0.0 → v1.1.0 (if changed)
- **Stories**:
  - [ ] Story 1: description (backend/frontend)
  - [ ] Story 2: description (backend/frontend)
- **Files Changed**:
  - Backend: list of files
  - Frontend: list of files
- **Tests**: +N added, M modified
- **Review**: APPROVED | APPROVED_WITH_FIXES | REJECTED
- **DoD**: PASSED | FAILED (with failing items)
- **Notes**: any follow-ups or warnings
```

---

## Changes

_No changes yet. The first change request will be logged as CHG-001._
