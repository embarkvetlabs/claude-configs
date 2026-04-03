---
description: Spin up a feature implementation team — architect plans, workers build, reviewer checks
allowed-tools: Bash(git:*)
---

## Context

- Current directory: !`pwd`
- Current branch: !`git branch --show-current 2>/dev/null`
- Recent changes: !`git diff --stat HEAD 2>/dev/null | tail -5`

## Your task

Create a team to implement a feature. The user will describe what needs to be built.

### Team composition

Spin up a team with these agents (use criminal names per CLAUDE.md rules):

1. **Team Lead (you / Opus)** — Orchestrate, review plans, make architecture decisions, handle blockers. You stay in the main thread.

2. **Worker 1 (Sonnet)** — Handles the primary implementation work. Assign the core files and logic.

3. **Worker 2 (Sonnet)** — Handles secondary implementation. Assign tests, supporting files, or a parallel workstream if the feature is large enough. If the feature is small, skip this agent.

4. **Reviewer (Sonnet, code-reviewer agent)** — Reviews all changes after workers finish. Uses the code-reviewer agent definition. Runs last.

### How to orchestrate

1. First, run `/start` to gather context, ask questions, and create the plan
2. After plan approval, create the team and assign tasks:
   - Break the plan into parallel workstreams where possible
   - Assign each worker clear files and responsibilities
   - Workers should run tests for their own changes
3. After workers complete, have the reviewer check all changes
4. Address any review findings
5. Report the final state to the user

### Task assignment rules

- Each worker gets a clear, non-overlapping set of files
- Workers must not edit the same file (causes merge conflicts)
- If two changes must touch the same file, serialize them (worker 1 finishes, then worker 2)
- Every worker runs the relevant linter and tests before marking their task done
