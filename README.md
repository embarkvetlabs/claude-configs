# Claude Code Configs

Shared configuration files for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Clone this repo and symlink the files into `~/.claude/` to set up a new machine quickly.

## Philosophy

**Opus orchestrates, Sonnet executes.** The main conversation (Opus) handles planning, architecture decisions, and coordination. Sub-agents (Sonnet) handle multi-file execution, research, and parallel work. CLAUDE.md encodes this: ask questions first, plan before doing, then delegate.

**Wide permissions, smart guardrails.** Most dev operations auto-approve. Dangerous operations (prod AWS writes, GitHub mutations, destructive git) prompt for review. Secrets are blocked entirely.

## Repo Structure

```
├── CLAUDE.md            # Global user instructions (workflow + rules)
├── settings.json        # Permissions, hooks, statusline, plugins
├── agents/
│   ├── ai-production-specialist.md
│   ├── architect.md
│   ├── aws-devops-specialist.md
│   ├── code-reviewer.md
│   ├── database-specialist.md
│   ├── debugger.md
│   ├── mui-frontend-specialist.md
│   ├── tech-research-specialist.md
│   └── writer.md
├── commands/
│   ├── ralph-slice-epic.md
│   ├── review-pr.md
│   └── statusline-command.sh
├── hooks/
│   ├── post-edit-check.sh
│   └── README.md
└── skills/
    ├── git/SKILL.md
    └── owasp/SKILL.md
```

## Setup on a New Machine

1. **Clone the repo**

   ```sh
   git clone <repo-url> ~/dev/claude-configs
   ```

2. **Create the `~/.claude` directory** (if it doesn't exist)

   ```sh
   mkdir -p ~/.claude
   ```

3. **Symlink config files and directories**

   ```sh
   # Adjust to fit your local setup
   export REPO_DIRECTORY_PATH=~/dev/claude-configs

   # Settings
   ln -sf $REPO_DIRECTORY_PATH/settings.json ~/.claude/settings.json

   # CLAUDE.md (global user instructions)
   ln -sf $REPO_DIRECTORY_PATH/CLAUDE.md ~/.claude/CLAUDE.md

   # Commands
   ln -sfn $REPO_DIRECTORY_PATH/commands ~/.claude/commands

   # Hooks
   ln -sfn $REPO_DIRECTORY_PATH/hooks ~/.claude/hooks

   # Skills
   ln -sfn $REPO_DIRECTORY_PATH/skills ~/.claude/skills

   # Agents
   ln -sfn $REPO_DIRECTORY_PATH/agents ~/.claude/agents
   ```

   > **Note:** `ln -sfn` is used for directories so the symlink replaces any existing directory symlink cleanly.

4. **Verify**

   ```sh
   ls -la ~/.claude/settings.json ~/.claude/CLAUDE.md ~/.claude/commands ~/.claude/hooks ~/.claude/skills ~/.claude/agents
   ```

   Each entry should show `->` pointing to the repo paths.

## Machine-Specific Overrides

To override settings on a single machine without affecting the repo, use `~/.claude/settings.local.json`. This file is not tracked by the repo and merges with the symlinked `settings.json`. Useful for adding machine-specific domain permissions or local tool paths.

## Customization

- Edit files in this repo, then `git commit` and `git push` — changes propagate to every machine via `git pull`.
- To override settings on a single machine without affecting the repo, remove the symlink for that file and create a local copy instead.
