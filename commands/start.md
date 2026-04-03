---
description: Start a new feature or task — gather context, ask questions, create branch, plan the work
allowed-tools: Bash(git:*), Bash(gh:*), Bash(jq:*)
---

## Context

- Current directory: !`pwd`
- Current branch: !`git branch --show-current`
- Default branch: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main"`
- Repo: !`gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || basename $(pwd)`

## Your task

You are starting a new piece of work. The user may provide a ticket ID, a description, or just a general idea.

### Step 1 — Gather context

If a Jira ticket ID or GitHub issue number was provided:
- Fetch the ticket details using the appropriate MCP tool or `gh issue view`
- Read the description, acceptance criteria, and any linked documents

If no ticket was provided, work with whatever description the user gave.

Read the repo's `AGENTS.md`, `CLAUDE.md`, or `README.md` to understand repo conventions.

Check `~/dev/ai/<repo-name>/` for any existing context, plans, or documents related to this work.

### Step 2 — Ask clarifying questions

Before doing anything else, ask questions. Think about:

- **Scope:** What exactly is in scope? What's explicitly NOT in scope?
- **Approach:** Are there existing patterns in the codebase to follow? Multiple valid approaches?
- **Dependencies:** Does this depend on or block other work?
- **Testing:** What test coverage is expected? Integration tests? E2E?
- **Unknowns:** What don't you understand yet about the codebase or requirements?

Ask all questions at once in a numbered list. Wait for answers before proceeding.

### Step 3 — Create branch and explore

After questions are answered:

1. Fetch latest and create a branch from the default branch:
   ```
   git fetch origin <default-branch>
   git checkout -b <branch-name> origin/<default-branch>
   ```
   Branch format: use the convention in the git skill (e.g., `kinano/{ticket-id}-{short-description}`). If no ticket, ask for a ticket ID per the git skill.

2. Explore the relevant code. Read the files you'll need to modify. Understand the existing patterns.

3. Write initial context to `~/dev/ai/<repo-name>/stories/` — capture the ticket details, decisions from Q&A, and relevant code paths found during exploration.

### Step 4 — Plan

Enter plan mode. Present a concrete implementation plan covering:

- **What changes** — files to create/modify, with brief descriptions
- **Approach** — the pattern or architecture you'll follow
- **Testing** — what tests you'll write
- **Risks** — anything that could go wrong or needs extra care
- **Order of operations** — what to build first

Wait for plan approval before writing any code.
