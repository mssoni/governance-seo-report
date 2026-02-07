#!/usr/bin/env bash
# Atomically allocate the next CHG-NNN Change ID.
# Reads last_change_id from CHANGE_MANIFEST.json, increments, writes back.
# Usage: ./scripts/new_change_id.sh
# Output: prints the new Change ID (e.g., CHG-002)

set -euo pipefail

MANIFEST="CHANGE_MANIFEST.json"

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: $MANIFEST not found. Run from workspace root." >&2
  exit 1
fi

# Extract current last_change_id
CURRENT=$(python3 -c "
import json
m = json.load(open('$MANIFEST'))
cid = m.get('last_change_id')
print(cid if cid else 'CHG-000')
")

# Parse the numeric part
NUM=$(echo "$CURRENT" | grep -oE '[0-9]+' || echo "0")

# Increment
NEXT_NUM=$((10#$NUM + 1))

# Format with zero-padding (3 digits)
NEXT_ID=$(printf "CHG-%03d" "$NEXT_NUM")

# Update manifest atomically (read → modify → write)
python3 -c "
import json
from datetime import date

with open('$MANIFEST', 'r') as f:
    m = json.load(f)

m['last_change_id'] = '$NEXT_ID'
m['updated_at'] = str(date.today())

with open('$MANIFEST', 'w') as f:
    json.dump(m, f, indent=2)
    f.write('\n')
"

echo "$NEXT_ID"
