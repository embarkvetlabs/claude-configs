---
description: Review the open PR on the current branch with staff, security, and QA perspectives
allowed-tools: Bash(gh pr view:*), Bash(gh api:*), Bash(gh pr diff:*), Bash(gh repo view:*)
---

## Context

- Current branch: !`git branch --show-current`
- PR details (includes comments and reviews): !`gh pr view --json title,body,url,reviews,comments,number`
- Changed files: !`gh pr diff --name-only 2>/dev/null`

## Your task

First, use the PR number from the context above to fetch inline review comments:
`gh api repos/PROJECT_REPO/pulls/PR_NUMBER/comments` — get the repo with `gh repo view --json nameWithOwner --jq .nameWithOwner`, then use the PR number from the context.

Then give me a five-minute read of this PR covering:

1. **What it does** — 2-3 sentence summary of the changes

2. **What reviewers think** — summarize all human reviewer comments and bot findings (LinearB, Copilot, Cursor, etc.), noting which issues are resolved vs still open

3. **Open issues** — a prioritized list of unresolved bugs, security concerns, and performance problems with `file:line` references where available. Flag anything that could cause silent data corruption or incorrect behavior even if it doesn't throw.

4. **My recommendations** — three perspectives:
   - **Staff Engineer**: architecture, maintainability, scalability concerns
   - **Security Engineer**: auth, input validation, data exposure, silent failures
   - **QA Engineer**: test coverage gaps, silent correctness bugs, what needs integration tests

Be specific. Reference file paths and line numbers.
