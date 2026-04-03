---
description: Spin up a debugging team — parallel investigation across code, logs, and history
allowed-tools: Bash(git:*)
---

## Context

- Current directory: !`pwd`
- Current branch: !`git branch --show-current 2>/dev/null`
- Recent commits: !`git log --oneline -5 2>/dev/null`

## Your task

Create a team to investigate a bug or production issue. The user will describe the symptoms.

### Team composition

Spin up a team with these agents (use criminal names per CLAUDE.md rules):

1. **Team Lead (you / Opus)** — Coordinate the investigation, synthesize findings, form hypotheses.

2. **Code Investigator (Sonnet, debugger agent)** — Reads the relevant code paths, traces the logic, identifies where things could go wrong. Uses the debugger agent definition.

3. **History Investigator (Sonnet, Explore agent)** — Checks git history: what changed recently? Who touched these files? Are there related issues or PRs? Checks `~/dev/ai/<repo>/` for prior context.

4. **Test Writer (Sonnet)** — Once the root cause is identified, writes a failing test that reproduces the bug, then writes the fix to make it pass.

### Investigation flow

1. Gather symptoms from the user — error messages, stack traces, when it started, what changed
2. Launch Code Investigator and History Investigator in parallel
3. Synthesize their findings — form a root cause hypothesis
4. Present the hypothesis to the user for confirmation
5. If confirmed, assign Test Writer to write a regression test and fix
6. Run full test suite to verify no regressions
7. Report the fix and root cause
