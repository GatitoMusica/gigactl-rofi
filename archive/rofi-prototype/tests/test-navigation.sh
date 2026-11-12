#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SEQUENCE_FILE="$(mktemp)"

cleanup() {
    rm -f "$SEQUENCE_FILE" "${SEQUENCE_FILE}.tmp."*
}
trap cleanup EXIT

cat > "$SEQUENCE_FILE" <<'SELECTIONS'
Cooling
Monitor fan status
Back
RGB Keyboard
Preset colors
Back
Settings
Appearance
Back
Exit
SELECTIONS

export ROFI_MOCK_SEQUENCE_FILE="$SEQUENCE_FILE"
export GIGACTL_ROFI_THEME="$PROJECT_ROOT/src/themes/tokyo-midnight.rasi"
export PATH="$PROJECT_ROOT/tests/mocks:$PATH"

"$PROJECT_ROOT/src/main.sh"

if [[ -s "$SEQUENCE_FILE" ]]; then
    printf 'Navigation test failed: unused selections remain.\n' >&2
    cat "$SEQUENCE_FILE" >&2
    exit 1
fi

printf 'Navigation test passed.\n'
