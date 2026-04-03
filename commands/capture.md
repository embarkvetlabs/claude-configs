---
description: Capture session context, decisions, and learnings to ~/dev/ai/ for future sessions
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(ls:*), Bash(date:*)
---

## Context

- Current directory: !`pwd`
- Repo name: !`basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)`
- Current branch: !`git branch --show-current 2>/dev/null`
- Recent commits this session: !`git log --oneline -10 2>/dev/null`

## Your task

Write a summary of this session's work to `~/dev/ai/<repo-name>/` for future Claude sessions to reference.

### Step 1 — Create the directory structure

```bash
mkdir -p ~/dev/ai/<repo-name>/documents
```

### Step 2 — Write a session capture file

Create or append to `~/dev/ai/<repo-name>/documents/<date>-<branch-or-topic>.md` with:

```markdown
# Session: <brief description of what was worked on>
Date: <today's date>
Branch: <branch name>

## What was done
- <bullet points summarizing changes made>

## Decisions made
- <decisions and their reasoning — the "why" matters most>

## Codebase learnings
- <things discovered about the codebase that aren't obvious from reading the code>
- <gotchas, quirks, or patterns that would help the next session>

## Open questions / Next steps
- <unresolved questions>
- <what should be done next>
```

### Step 3 — Be selective

Don't dump everything. Capture only what would be non-obvious to a fresh Claude session reading the code:
- Why a particular approach was chosen over alternatives
- Constraints or requirements that aren't in the code
- Codebase quirks or undocumented behavior discovered
- Context from conversations with the user that informed decisions

Skip anything that's already in the code, commit messages, or PR description.

### Step 4 — Confirm

Show the user what was written and where.
