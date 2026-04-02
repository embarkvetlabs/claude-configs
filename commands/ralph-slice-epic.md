# /ralph-slice-epic — Stacked PR Decomposer

Break the current branch into small, reviewable stacked PRs following trunk-based development principles. Claude handles all analysis and grouping — you just review and approve.

---

## What this command does

**First run (no plan file):**

1. Check for merge conflicts with main — stop immediately if any exist
2. Read every file changed on this branch vs main
3. Apply the decomposition rules below to group files into PRs
4. Save the plan to `scripts/plans/<branch-slug>.json`
5. Print the plan and ask for confirmation before opening any PRs

**Subsequent runs (plan file exists):**

1. Read the existing plan file
2. Show current status — which PRs are opened vs pending
3. Open the next batch of PRs (stop at 4 open at a time)
4. Update the plan file as each PR is opened

---

## Step 1 — Pre-flight checks

Run these before anything else:

```bash
# Check for merge conflicts
git fetch origin main
git merge-tree $(git merge-base HEAD origin/main) HEAD origin/main | grep -c "^<<<<<<" || true
```

If conflicts exist, stop and tell the user: "Resolve merge conflicts with main before running /ralph."

Get the current branch name and derive the plan file path:

```bash
git branch --show-current
```

Plan file: `scripts/plans/<branch-name-with-slashes-replaced-by-dashes>.json`
Example: branch `ralph/dog-of-the-day` → `scripts/plans/ralph-dog-of-the-day.json`

---

## Step 2 — Read the diff

```bash
git diff main...HEAD --name-only
git diff main...HEAD --stat
```

For each changed file, read its contents to understand what it does. You need this to make good grouping decisions — don't skip it.

---

## Step 3 — Apply decomposition rules

### The core rules

1. **200 LOC target, 400 LOC hard ceiling.** Above 400 lines reviewers switch to approval mode. If a PR must exceed 400, call it out explicitly in the description.

2. **One PR, one nameable concept.** If you can't describe it in one sentence, it's too big. Name it after the logical concept, not the files touched.

3. **Refactors are always a separate PR from features.** Mixing them makes it impossible to reason about functional changes.

4. **Every PR must leave CI green and the codebase deployable.** No exceptions.

5. **Tests ship in the same PR as the code they test.** Never defer tests to a follow-up.

6. **Never include development artifacts.** Files like `prd.json`, `progress.txt`, scratch files — exclude them from all PRs entirely.

### The walking skeleton order

Group files into PRs in this sequence. Each layer depends on the previous:

| Phase           | What belongs here                                                                                                                             |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Foundation      | Types, constants, shared utilities, global plumbing. Nothing else imports these yet.                                                          |
| Data            | Static data files — lookup tables, content copy, schedules. No component imports.                                                             |
| Logic           | Pure functions — scoring, option generation, storage/repository, mutations. Testable in isolation.                                            |
| GraphQL + Hooks | Queries, context providers, page-level hooks. No rendered UI.                                                                                 |
| UI Primitives   | Standalone atomic components with no page-level logic. Each one reviewable alone.                                                             |
| Complex UI      | Interactive components that own state or have non-trivial hooks.                                                                              |
| Assembly        | Page composition, layout wiring, route registration. First PR that renders anything end-to-end.                                               |
| Entry Points    | What makes the feature visible to users (e.g. rendering a banner, adding a nav link). Keep this separate so it can be reverted independently. |
| E2E             | Playwright/Cypress tests, test infrastructure setup.                                                                                          |

### Splitting guidelines

- A directory that maps cleanly to one concept = one PR (e.g. all of `components/celebration/`)
- A directory that mixes concepts = split it (e.g. `services/` might be 3 PRs: types, storage, mutations)
- Hook + component that can't be understood separately = keep together
- Hook + component that CAN stand alone = split them

---

## Step 4 — Generate the plan

Write the plan to `scripts/plans/<branch-slug>.json`. Format:

```json
{
  "source_branch": "<current branch name>",
  "stack_prefix": "<username>/no-ticket/<feature>-",
  "base_branch": "main",
  "created": "<today's date>",
  "prs": [
    {
      "slug": "01-foundation",
      "title": "One sentence describing what this PR does",
      "not_in_scope": "Explicit list of what is intentionally absent",
      "tests": "What test coverage ships in this PR",
      "files": ["src/path/to/file.ts"],
      "status": "pending"
    }
  ]
}
```

The `stack_prefix` should be derived from the current branch name. For example:

- `ralph/dog-of-the-day` → `ralph/no-ticket/dod-`

After writing the file, print the full plan for the user to review. Show each PR as:

```
PR 01  [~XXX lines]  01-foundation
  Add shared types, localStorage keys, and heap events
  Files: types.ts, localStorage.ts, tracking.ts
  Not in scope: No UI. No routing. No game logic.
```

Ask the user to confirm before proceeding to PR creation: "Does this plan look right? Type yes to start opening PRs, or describe any changes."

---

## Step 5 — Open PRs

Open PRs from the plan, stopping when 4 are open. For each pending PR:

### Find the stack tip

The tip is the open PR in this stack whose head branch is not used as the base of any other open PR:

```bash
gh pr list --state open --json headRefName,baseRefName \
  --jq '[.[] | select(.headRefName | startswith("<stack_prefix>"))]'
```

If no open PRs exist, the tip is `main`.

### Create the branch and apply files

```bash
git fetch origin <tip_branch>
git checkout -b <stack_prefix><slug> origin/<tip_branch>
git checkout origin/<source_branch> -- <file1> <file2> ...
git add <file1> <file2> ...
git commit -m "[no-ticket] <title>"
git push -u origin <stack_prefix><slug>
```

### Open the draft PR

Use this description template:

```
## What

<title>

## Stack

- #N: <previous PR title> [opened]
- **<title>** ← THIS PR
- (next PRs not yet open)

## Files

- `path/to/file.ts` — brief note on what it does
- `path/to/file.test.ts` — tests for the above

## Not in Scope

<not_in_scope>

## Tests

<tests>

---

_Targets `<tip_branch>`. Do not merge this PR until `<tip_branch>` is merged into main._
```

```bash
gh pr create \
  --draft \
  --base <tip_branch> \
  --title "<title>" \
  --body "<body>"
```

### After opening

Mark the PR as opened in the plan file:

```json
{ "status": "opened" }
```

Check how many PRs are now open. If 4 are open, stop and tell the user:
"4 PRs are open. Run /ralph again after some merge to continue."

---

## Step 6 — Report

After opening each batch, print:

```
Plan status:
  [opened]   01-foundation   Add shared types...
  [opened]   02-dog-data     Add dog photo data...
  [pending]  03-content-data Add static content...
  ...

Next: run /ralph again after PRs 01 and 02 merge to continue.
```
