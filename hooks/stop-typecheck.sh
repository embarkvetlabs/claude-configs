#!/usr/bin/env bash
# stop-typecheck.sh — Full project typecheck after Claude finishes a sequence of edits.
# Runs tsc for TypeScript projects, mypy/pyright for Python projects.
# This catches cross-file type errors that per-file linting misses.

set -uo pipefail

INPUT=$(cat 2>/dev/null) || true
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || true

if [[ -z "$CWD" ]]; then
  exit 0
fi

# ── Walk up to find the project root ────────────────────────────
find_project_root() {
  local dir="$1"
  dir=$(cd "$dir" 2>/dev/null && pwd) || return 1
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" ]] || [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/setup.py" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

PROJECT_ROOT=$(find_project_root "$CWD" 2>/dev/null) || PROJECT_ROOT="$CWD"
cd "$PROJECT_ROOT" 2>/dev/null || exit 0

ERRORS=""

# ── TypeScript — full project typecheck ─────────────────────────
if [[ -f "tsconfig.json" ]]; then
  TSC="${PROJECT_ROOT}/node_modules/.bin/tsc"
  if [[ -x "$TSC" ]]; then
    echo "▶ Running tsc --noEmit..."
    TSC_OUT=$($TSC --noEmit 2>&1) || true
    TSC_ERRORS=$(echo "$TSC_OUT" | grep -c "error TS" 2>/dev/null) || TSC_ERRORS=0
    if [[ "$TSC_ERRORS" -gt 0 ]]; then
      ERRORS="${ERRORS}\n── TypeScript errors (${TSC_ERRORS}) ──\n$(echo "$TSC_OUT" | grep "error TS" | head -20)"
    else
      echo "✓ TypeScript: no type errors"
    fi
  fi
fi

# ── Python — full project typecheck ─────────────────────────────
if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
  has_pyproject_tool() { grep -q "\[tool\.${1}" pyproject.toml 2>/dev/null; }

  if command -v mypy &>/dev/null && { [[ -f "mypy.ini" ]] || [[ -f ".mypy.ini" ]] || has_pyproject_tool "mypy"; }; then
    echo "▶ Running mypy..."
    MYPY_OUT=$(mypy . 2>&1) || true
    MYPY_ERRORS=$(echo "$MYPY_OUT" | grep -c ": error:" 2>/dev/null) || MYPY_ERRORS=0
    if [[ "$MYPY_ERRORS" -gt 0 ]]; then
      ERRORS="${ERRORS}\n── mypy errors (${MYPY_ERRORS}) ──\n$(echo "$MYPY_OUT" | grep ": error:" | head -20)"
    else
      echo "✓ mypy: no type errors"
    fi
  elif command -v pyright &>/dev/null && { [[ -f "pyrightconfig.json" ]] || has_pyproject_tool "pyright"; }; then
    echo "▶ Running pyright..."
    PYRIGHT_OUT=$(pyright 2>&1) || true
    PYRIGHT_ERRORS=$(echo "$PYRIGHT_OUT" | grep -c "error:" 2>/dev/null) || PYRIGHT_ERRORS=0
    if [[ "$PYRIGHT_ERRORS" -gt 0 ]]; then
      ERRORS="${ERRORS}\n── pyright errors (${PYRIGHT_ERRORS}) ──\n$(echo "$PYRIGHT_OUT" | grep "error:" | head -20)"
    else
      echo "✓ pyright: no type errors"
    fi
  fi
fi

# ── Report ──────────────────────────────────────────────────────
if [[ -n "$ERRORS" ]]; then
  printf "\n⚠️  Type errors found after edits:\n"
  printf "%b\n" "$ERRORS"
  exit 1
fi

exit 0
