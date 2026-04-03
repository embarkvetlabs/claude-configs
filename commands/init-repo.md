---
description: Generate a CLAUDE.md and AGENTS.md for the current repo by inspecting its structure
allowed-tools: Bash(git:*), Bash(npm:*), Bash(cat:*), Bash(ls:*), Bash(find:*), Bash(grep:*), Bash(jq:*)
---

## Context

- Current directory: !`pwd`
- Repo: !`gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || basename $(pwd)`
- Project type: !`if [ -f "tsconfig.json" ]; then echo "TypeScript"; elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then echo "Python"; elif [ -f "package.json" ]; then echo "JavaScript"; else echo "Unknown"; fi`
- Has CLAUDE.md: !`test -f CLAUDE.md && echo "yes" || echo "no"`
- Has AGENTS.md: !`test -f AGENTS.md && echo "yes" || echo "no"`

## Your task

Generate a repo-specific CLAUDE.md (and AGENTS.md if useful) by inspecting the project. Don't guess — read the actual config files.

### Step 1 — Inspect the project

Read these files if they exist to understand the project:
- `package.json` — scripts, dependencies, test runner, linter
- `tsconfig.json` — TypeScript config, strictness, paths
- `pyproject.toml` — Python config, dependencies, tool settings
- `.eslintrc*` / `eslint.config.*` / `biome.json` — linter config
- `vitest.config.*` / `jest.config.*` / `pytest.ini` / `conftest.py` — test config
- `Makefile` / `Justfile` — build commands
- `docker-compose.yml` — service dependencies
- `.github/workflows/` — CI configuration (what does CI check?)
- `README.md` — project overview
- `src/` or `app/` structure — understand the module layout

### Step 2 — Generate CLAUDE.md

Write a CLAUDE.md file for the repo covering:

```markdown
# {Project Name}

{One-line description of what this project is}

## Commands

- **Run tests:** `{exact command}`
- **Run linter:** `{exact command}`
- **Type check:** `{exact command}`
- **Build:** `{exact command}`
- **Dev server:** `{exact command}` (if applicable)

## Architecture

{Brief overview of the module structure — what lives where}

- `src/components/` — React components
- `src/services/` — API client and business logic
- etc.

## Conventions

- {Naming conventions found in the code}
- {Import patterns — absolute vs relative, barrel files}
- {Testing patterns — where tests live, naming convention}
- {Any patterns visible in the existing code}

## Before Committing

1. Run `{lint command}`
2. Run `{typecheck command}`
3. Run `{test command}`
4. Ensure CI would pass with the above
```

### Step 3 — Generate AGENTS.md (if useful)

If the project has distinct subsystems (frontend/backend, multiple services, etc.), create an AGENTS.md with:
- Subsystem-specific commands
- Migration conventions (if there's a DB)
- Deployment notes
- Environment setup

### Step 4 — Review with the user

Show the generated file(s) and ask if anything needs adjusting before writing them. Don't write until the user confirms.
