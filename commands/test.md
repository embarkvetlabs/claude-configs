---
description: Run tests scoped to recent changes — detects project type automatically
allowed-tools: Bash(npm:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(pytest:*), Bash(uv:*), Bash(python:*), Bash(git:*)
---

## Context

- Current directory: !`pwd`
- Project type: !`if [ -f "tsconfig.json" ]; then echo "TypeScript"; elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then echo "Python"; elif [ -f "package.json" ]; then echo "JavaScript"; else echo "Unknown"; fi`
- Changed files since last commit: !`git diff --name-only HEAD 2>/dev/null || echo "not a git repo"`
- Recently staged files: !`git diff --cached --name-only 2>/dev/null`

## Your task

Run the tests most relevant to the recent changes. Be smart about scope.

### Step 1 — Detect the test runner

**TypeScript / JavaScript:**
Check `package.json` for test scripts and detect the runner:
- `vitest` — look for `vitest` in devDependencies or a `vitest.config` file
- `jest` — look for `jest` in devDependencies or a `jest.config` file
- `npm test` — fallback to whatever `test` script is defined

**Python:**
- `pytest` — look for `pytest` in pyproject.toml or a `conftest.py`
- Check if `uv` is available and use `uv run pytest` if there's a `uv.lock`

### Step 2 — Scope the tests

Look at the changed files and determine the right scope:

- If test files were changed, run those specific test files
- If source files were changed, find related test files (same directory, `__tests__/`, `tests/`, or matching `*.test.*` / `test_*.py` pattern) and run those
- If no related tests are found, run the full test suite
- If the user provided arguments to this command (e.g., `/test src/auth`), use those as the scope

### Step 3 — Run and report

Run the tests. If they fail:
1. Read the failure output carefully
2. Identify which tests failed and why
3. Suggest specific fixes with file:line references
4. Ask if the user wants you to fix the failures

If they pass, report the result concisely (number of tests, time taken).
