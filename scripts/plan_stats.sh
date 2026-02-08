#!/usr/bin/env bash
# =============================================================================
# Engineering Plan Statistics
# =============================================================================
# Computes current project statistics from the codebase.
# Usage: ./scripts/plan_stats.sh
#
# Output is informational — use it to update the "Current Statistics" table
# in ENGINEERING_PLAN.md. This script does NOT modify any files.
# =============================================================================

set -euo pipefail

BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}=== Engineering Plan Statistics ===${NC}"
echo ""

# ---------------------------------------------------------------------------
# Backend tests
# ---------------------------------------------------------------------------
BE_TESTS=$( (
  cd backend
  if [ -x .venv/bin/python ]; then
    .venv/bin/python -m pytest tests/ --tb=no 2>&1
  elif command -v uv >/dev/null 2>&1; then
    uv run pytest tests/ --tb=no 2>&1
  else
    python3 -m pytest tests/ --tb=no 2>&1
  fi
) | grep -oE '[0-9]+ passed' | grep -oE '^[0-9]+' || echo "?")
echo "Backend tests:      ${BE_TESTS}"

# ---------------------------------------------------------------------------
# Frontend tests
# ---------------------------------------------------------------------------
FE_TESTS=$(cd frontend && npx vitest run --reporter=dot 2>&1 | grep "Tests" | grep -oE '[0-9]+ passed' | grep -oE '^[0-9]+' || echo "?")
echo "Frontend tests:     ${FE_TESTS}"

# ---------------------------------------------------------------------------
# Total
# ---------------------------------------------------------------------------
if [ "$BE_TESTS" != "?" ] && [ "$FE_TESTS" != "?" ]; then
  TOTAL=$((BE_TESTS + FE_TESTS))
  echo "Total tests:        ${TOTAL}"
else
  echo "Total tests:        ? (could not compute)"
fi

# ---------------------------------------------------------------------------
# API endpoints
# ---------------------------------------------------------------------------
ENDPOINTS=$(grep -rn '@router\.\(get\|post\|put\|delete\|patch\)' backend/app/api/*.py 2>/dev/null | grep -v "__" | wc -l | tr -d ' ')
echo "API endpoints:      ${ENDPOINTS}"

# ---------------------------------------------------------------------------
# Frontend components
# ---------------------------------------------------------------------------
COMPONENTS=$(find frontend/src/components -name "*.tsx" -not -path "*__tests__*" -not -path "*test*" 2>/dev/null | wc -l | tr -d ' ')
echo "Frontend components: ${COMPONENTS}"

# ---------------------------------------------------------------------------
# Post-V1 changes
# ---------------------------------------------------------------------------
CHANGES=$(grep -c '^### CHG-[0-9]' CHANGE_LOG.md 2>/dev/null || echo "?")
echo "Post-V1 changes:    ${CHANGES}"

# ---------------------------------------------------------------------------
# Contract version
# ---------------------------------------------------------------------------
CONTRACT=$(python3 -c "import json; print(json.load(open('CHANGE_MANIFEST.json'))['contract_version'])" 2>/dev/null || echo "?")
echo "Contract version:   ${CONTRACT}"

# ---------------------------------------------------------------------------
# Summary table (copy-paste into ENGINEERING_PLAN.md)
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}--- Markdown table (copy into ENGINEERING_PLAN.md) ---${NC}"
echo ""
echo "| Metric | Count |"
echo "|--------|-------|"
echo "| Backend tests | ${BE_TESTS} |"
echo "| Frontend tests | ${FE_TESTS} |"
if [ "$BE_TESTS" != "?" ] && [ "$FE_TESTS" != "?" ]; then
  echo "| **Total tests** | **${TOTAL}** |"
fi
echo "| API endpoints | ${ENDPOINTS} |"
echo "| Frontend components | ${COMPONENTS} |"
echo "| V1 user stories | 23 |"
echo "| Post-V1 changes | ${CHANGES} |"
echo "| Contract version | ${CONTRACT} |"
