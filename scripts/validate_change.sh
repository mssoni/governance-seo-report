#!/usr/bin/env bash
# =============================================================================
# Pre-Merge Validation Script
# =============================================================================
# Validates that the full 8-step change process was followed for a given CHG-NNN.
# Usage: ./scripts/validate_change.sh CHG-NNN
#
# Exit code 0 = all checks pass (safe to merge)
# Exit code 1 = violations found (DO NOT MERGE)
#
# This script is a HARD GATE. The change-agent rule requires running it before
# any merge. If it fails, the merge MUST NOT proceed.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

FAIL=0
WARN=0

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
if [ $# -lt 1 ]; then
  echo -e "${RED}Usage: ./scripts/validate_change.sh CHG-NNN${NC}"
  exit 1
fi

CHANGE_ID="$1"

# Validate format
if ! echo "$CHANGE_ID" | grep -qE '^CHG-[0-9]{3}$'; then
  echo -e "${RED}ERROR: Change ID must be in format CHG-NNN (e.g., CHG-011)${NC}"
  exit 1
fi

echo ""
echo -e "${BOLD}=== Pre-Merge Validation: ${CHANGE_ID} ===${NC}"
echo ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
check_pass() { echo -e "  ${GREEN}PASS${NC} — $1"; }
check_fail() { echo -e "  ${RED}FAIL${NC} — $1"; FAIL=1; }
check_warn() { echo -e "  ${YELLOW}WARN${NC} — $1"; WARN=1; }

# Extract the CHANGE_LOG section for this CHG-NNN into a temp file
# Handles both mid-file and last-entry cases
extract_changelog_section() {
  python3 -c "
import re, sys

with open('CHANGE_LOG.md') as f:
    content = f.read()

# Find the section for this change ID
pattern = r'### ${CHANGE_ID}:.*?(?=\n### CHG-|\Z)'
match = re.search(pattern, content, re.DOTALL)
if match:
    print(match.group(0))
else:
    print('NOT_FOUND')
"
}

# Extract a field value from the changelog section
extract_field() {
  local field_name="$1"
  local section="$2"
  echo "$section" | python3 -c "
import sys, re
text = sys.stdin.read()
m = re.search(r'\*\*${field_name}\*\*:\s*(.+)', text)
print(m.group(1).strip() if m else 'MISSING')
"
}

CHANGELOG_SECTION=$(extract_changelog_section)

# ---------------------------------------------------------------------------
# 1. CHANGE_LOG.md entry exists
# ---------------------------------------------------------------------------
echo -e "${BOLD}[1/13] CHANGE_LOG.md entry${NC}"
if [ "$CHANGELOG_SECTION" = "NOT_FOUND" ]; then
  check_fail "No entry for ${CHANGE_ID} in CHANGE_LOG.md"
  echo -e "${RED}Cannot continue — CHANGE_LOG entry is required.${NC}"
  exit 1
else
  check_pass "Entry found in CHANGE_LOG.md"
fi

# ---------------------------------------------------------------------------
# 2. CHANGE_LOG.md has required fields
# ---------------------------------------------------------------------------
echo -e "${BOLD}[2/13] CHANGE_LOG required fields${NC}"

for field in "Status" "Scope" "Mode" "Branch" "Stories" "Files Changed" "Tests" "Review" "DoD"; do
  if echo "$CHANGELOG_SECTION" | grep -qi "\\*\\*${field}\\*\\*"; then
    check_pass "Field '${field}' present"
  else
    check_fail "Missing required field '${field}' in CHANGE_LOG entry"
  fi
done

# Extract key fields
STATUS=$(extract_field "Status" "$CHANGELOG_SECTION")
MODE=$(extract_field "Mode" "$CHANGELOG_SECTION")
SCOPE=$(extract_field "Scope" "$CHANGELOG_SECTION")
BRANCH_NAME=$(extract_field "Branch" "$CHANGELOG_SECTION")

if [ "$STATUS" = "IN_PROGRESS" ] || [ "$STATUS" = "COMPLETE" ]; then
  check_pass "Status is ${STATUS}"
else
  check_fail "Status should be IN_PROGRESS or COMPLETE, got: ${STATUS}"
fi

if [ "$MODE" = "INLINE" ] || [ "$MODE" = "STANDARD" ]; then
  check_pass "Mode is ${MODE}"
else
  check_fail "Mode should be INLINE or STANDARD, got: ${MODE}"
fi

# ---------------------------------------------------------------------------
# 3. Scope detection
# ---------------------------------------------------------------------------
echo -e "${BOLD}[3/13] Scope detection${NC}"
HAS_BACKEND=false
HAS_FRONTEND=false

if echo "$SCOPE" | grep -qi "backend\|both"; then
  HAS_BACKEND=true
fi
if echo "$SCOPE" | grep -qi "frontend\|both"; then
  HAS_FRONTEND=true
fi

check_pass "Scope: ${SCOPE} (backend=${HAS_BACKEND}, frontend=${HAS_FRONTEND})"

# ---------------------------------------------------------------------------
# 4. Feature branch exists (not direct commit to main)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[4/13] Feature branch usage${NC}"

if echo "$BRANCH_NAME" | grep -qE '^change/CHG-[0-9]{3}'; then
  check_pass "Branch name follows convention: ${BRANCH_NAME}"
else
  check_fail "Branch name doesn't follow convention (expected change/CHG-NNN-*): ${BRANCH_NAME}"
fi

# Check if submodules used feature branches (look for merge commits)
if [ "$HAS_BACKEND" = true ]; then
  BACKEND_MERGE=$(cd backend && git log --oneline --all 2>/dev/null | grep -i "merge(${CHANGE_ID})" | head -1 || echo "")
  BACKEND_BRANCH=$(cd backend && git branch -a 2>/dev/null | grep "${BRANCH_NAME}" | head -1 || echo "")
  if [ -n "$BACKEND_MERGE" ]; then
    check_pass "Backend merge commit found: ${BACKEND_MERGE}"
  elif [ -n "$BACKEND_BRANCH" ]; then
    check_pass "Backend feature branch exists (not yet merged)"
  else
    check_fail "Backend: No feature branch or --no-ff merge commit found for ${CHANGE_ID}. Was committed directly to main."
  fi
fi

if [ "$HAS_FRONTEND" = true ]; then
  FRONTEND_MERGE=$(cd frontend && git log --oneline --all 2>/dev/null | grep -i "merge(${CHANGE_ID})" | head -1 || echo "")
  FRONTEND_BRANCH=$(cd frontend && git branch -a 2>/dev/null | grep "${BRANCH_NAME}" | head -1 || echo "")
  if [ -n "$FRONTEND_MERGE" ]; then
    check_pass "Frontend merge commit found: ${FRONTEND_MERGE}"
  elif [ -n "$FRONTEND_BRANCH" ]; then
    check_pass "Frontend feature branch exists (not yet merged)"
  else
    check_fail "Frontend: No feature branch or --no-ff merge commit found for ${CHANGE_ID}. Was committed directly to main."
  fi
fi

# ---------------------------------------------------------------------------
# 5. MERGE_TRANSACTIONS.md entry
# ---------------------------------------------------------------------------
echo -e "${BOLD}[5/13] MERGE_TRANSACTIONS.md entry${NC}"
if grep -q "${CHANGE_ID}" MERGE_TRANSACTIONS.md 2>/dev/null; then
  check_pass "Entry found in MERGE_TRANSACTIONS.md"

  TX_SECTION=$(python3 -c "
import re
with open('MERGE_TRANSACTIONS.md') as f:
    content = f.read()
m = re.search(r'### TX-.*?${CHANGE_ID}.*?(?=\n### TX-|\Z)', content, re.DOTALL)
print(m.group(0) if m else '')
")
  if echo "$TX_SECTION" | grep -qi "COMPLETED"; then
    check_pass "Transaction status is COMPLETED"
  elif echo "$TX_SECTION" | grep -qi "STARTED"; then
    check_warn "Transaction status is STARTED (not yet COMPLETED)"
  else
    check_warn "Transaction status unclear"
  fi
else
  check_fail "No entry for ${CHANGE_ID} in MERGE_TRANSACTIONS.md"
fi

# ---------------------------------------------------------------------------
# 6. ARCHITECTURE.md updated in affected repos
# ---------------------------------------------------------------------------
echo -e "${BOLD}[6/13] ARCHITECTURE.md updated${NC}"
if [ "$HAS_BACKEND" = true ]; then
  if grep -q "${CHANGE_ID}" backend/ARCHITECTURE.md 2>/dev/null; then
    check_pass "Backend ARCHITECTURE.md mentions ${CHANGE_ID}"
  else
    check_fail "Backend ARCHITECTURE.md does NOT mention ${CHANGE_ID}"
  fi
fi

if [ "$HAS_FRONTEND" = true ]; then
  if grep -q "${CHANGE_ID}" frontend/ARCHITECTURE.md 2>/dev/null; then
    check_pass "Frontend ARCHITECTURE.md mentions ${CHANGE_ID}"
  else
    check_fail "Frontend ARCHITECTURE.md does NOT mention ${CHANGE_ID}"
  fi
fi

# ---------------------------------------------------------------------------
# 7. CONTRACTS.md updated (if SCHEMA_CHANGE label present)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[7/13] CONTRACTS.md (if schema change)${NC}"
if echo "$CHANGELOG_SECTION" | grep -qi "SCHEMA_CHANGE"; then
  check_pass "SCHEMA_CHANGE label detected — checking CONTRACTS.md"

  if [ "$HAS_BACKEND" = true ]; then
    if grep -q "${CHANGE_ID}" backend/CONTRACTS.md 2>/dev/null; then
      check_pass "Backend CONTRACTS.md mentions ${CHANGE_ID}"
    else
      check_fail "Backend CONTRACTS.md does NOT mention ${CHANGE_ID} (schema change requires it)"
    fi
  fi

  if [ "$HAS_FRONTEND" = true ]; then
    if grep -q "${CHANGE_ID}" frontend/CONTRACTS.md 2>/dev/null; then
      check_pass "Frontend CONTRACTS.md mentions ${CHANGE_ID}"
    else
      check_fail "Frontend CONTRACTS.md does NOT mention ${CHANGE_ID} (schema change requires it)"
    fi
  fi
else
  check_pass "No SCHEMA_CHANGE label — CONTRACTS.md update not required"
fi

# ---------------------------------------------------------------------------
# 8. CHANGE_MANIFEST.json updated
# ---------------------------------------------------------------------------
echo -e "${BOLD}[8/13] CHANGE_MANIFEST.json${NC}"
python3 -c "
import json, sys

m = json.load(open('CHANGE_MANIFEST.json'))
chg = '${CHANGE_ID}'
notes = m.get('notes', '')
last = m.get('last_change_id', '')

if chg in notes or last == chg:
    print('PASS:CHANGE_MANIFEST.json references ' + chg)
else:
    print('WARN:CHANGE_MANIFEST.json may not be updated for ' + chg + ' (last_change_id=' + last + ')')

be_sha = m.get('backend_commit', '')
fe_sha = m.get('frontend_commit', '')
print('BE_SHA:' + be_sha)
print('FE_SHA:' + fe_sha)
" | while IFS= read -r line; do
  case "$line" in
    PASS:*) check_pass "${line#PASS:}" ;;
    WARN:*) check_warn "${line#WARN:}" ;;
    BE_SHA:*)
      sha="${line#BE_SHA:}"
      if [ "$HAS_BACKEND" = true ] && [ -n "$sha" ] && [ ${#sha} -ge 7 ]; then
        check_pass "Backend commit SHA recorded: ${sha:0:7}"
      elif [ "$HAS_BACKEND" = true ]; then
        check_fail "Backend commit SHA missing in CHANGE_MANIFEST.json"
      fi
      ;;
    FE_SHA:*)
      sha="${line#FE_SHA:}"
      if [ "$HAS_FRONTEND" = true ] && [ -n "$sha" ] && [ ${#sha} -ge 7 ]; then
        check_pass "Frontend commit SHA recorded: ${sha:0:7}"
      elif [ "$HAS_FRONTEND" = true ]; then
        check_fail "Frontend commit SHA missing in CHANGE_MANIFEST.json"
      fi
      ;;
  esac
done

# ---------------------------------------------------------------------------
# 9. make check passes (backend)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[9/13] make check — backend${NC}"
if [ "$HAS_BACKEND" = true ]; then
  if (cd backend && make check > /dev/null 2>&1); then
    check_pass "Backend make check passed"
  else
    check_fail "Backend make check FAILED"
  fi
else
  check_pass "Backend not in scope — skipped"
fi

# ---------------------------------------------------------------------------
# 10. make check passes (frontend)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[10/13] make check — frontend${NC}"
if [ "$HAS_FRONTEND" = true ]; then
  if (cd frontend && make check > /dev/null 2>&1); then
    check_pass "Frontend make check passed"
  else
    check_fail "Frontend make check FAILED"
  fi
else
  check_pass "Frontend not in scope — skipped"
fi

# ---------------------------------------------------------------------------
# 11. make dod passes (backend)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[11/13] make dod — backend${NC}"
if [ "$HAS_BACKEND" = true ]; then
  if (cd backend && make dod > /dev/null 2>&1); then
    check_pass "Backend make dod passed"
  else
    check_fail "Backend make dod FAILED"
  fi
else
  check_pass "Backend not in scope — skipped"
fi

# ---------------------------------------------------------------------------
# 12. make dod passes (frontend)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[12/13] make dod — frontend${NC}"
if [ "$HAS_FRONTEND" = true ]; then
  if (cd frontend && make dod > /dev/null 2>&1); then
    check_pass "Frontend make dod passed"
  else
    check_fail "Frontend make dod FAILED"
  fi
else
  check_pass "Frontend not in scope — skipped"
fi

# ---------------------------------------------------------------------------
# 13. ENGINEERING_PLAN.md version history (WARN only)
# ---------------------------------------------------------------------------
echo -e "${BOLD}[13/13] ENGINEERING_PLAN.md version history${NC}"
if [ -f ENGINEERING_PLAN.md ]; then
  if grep -q "${CHANGE_ID}" ENGINEERING_PLAN.md 2>/dev/null; then
    check_pass "ENGINEERING_PLAN.md Version History mentions ${CHANGE_ID}"
  else
    check_warn "ENGINEERING_PLAN.md Version History does NOT mention ${CHANGE_ID} — update Current Statistics and add a version row"
  fi
else
  check_warn "ENGINEERING_PLAN.md not found"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "================================================================"
if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}ALL CHECKS PASSED — safe to merge ${CHANGE_ID}${NC}"
  echo "================================================================"
  exit 0
elif [ "$FAIL" -eq 0 ]; then
  echo -e "${YELLOW}${BOLD}WARNINGS present but no hard failures — review before merging ${CHANGE_ID}${NC}"
  echo "================================================================"
  exit 0
else
  echo -e "${RED}${BOLD}VALIDATION FAILED — DO NOT MERGE ${CHANGE_ID}${NC}"
  echo -e "${RED}Fix all FAIL items above before proceeding.${NC}"
  echo "================================================================"
  exit 1
fi
