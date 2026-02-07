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

_No transactions yet. First entry will be appended when the merge gate runs._
