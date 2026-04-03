# Workflow

## Ask questions first

After receiving a prompt, pause and identify any ambiguities, missing context, or decisions that could go multiple ways. Ask clarifying questions **before** starting work. Continue asking along the way when you encounter decision points — don't guess, ask.

## Plan before doing

For any non-trivial task (more than a simple fix or single-file change), enter plan mode first. Explore the codebase, design the approach, and present the plan for approval. After approval, execute the plan without stopping to re-confirm each step.

## Opus orchestrates, Sonnet executes

Use the orchestrator/worker pattern: the main conversation (Opus) handles planning, architecture decisions, and coordination. Spawn Sonnet sub-agents for multi-file execution, research, and parallel work. Delegate liberally — don't do grunt work in the main thread.

## Use skills and hooks

Activate configured skills (git, owasp, etc.) for domain-specific work. The post-edit hook runs linting automatically — trust it and fix issues it catches.

## Write things down

Use `~/dev/ai/` as persistent storage for context, decisions, and working documents. Organize by repo name:

```
~/dev/ai/
├── {repo-name}/
│   ├── stories/       # user stories, feature specs, requirements
│   ├── documents/     # ADRs, RFCs, technical docs, research notes
│   ├── plans/         # implementation plans, migration strategies
│   └── ...            # create whatever folders make sense
```

Write to this folder proactively — capture context that would help future sessions: decisions made and why, architecture notes, things learned about the codebase, open questions, investigation findings. This persists across conversations and helps Claude (and Paul) pick up where things left off.

## Cross-repo references

All repos live under `~/dev/`. When Paul mentions a repo by name or alias, read files directly from its local path — don't ask for a GitHub link. You can read, grep, and glob any repo without switching the working directory.

| Alias | Repo path | Description |
|-------|-----------|-------------|
| app | ~/dev/embarkvet-app/ | Main web application (TypeScript/React) |
| aussie | ~/dev/projectaussie.com/ | Project Aussie frontend |
| admin | ~/dev/customer-admin/ | Internal admin tool |
| CRS | ~/dev/customer-results-service/ | Customer results API |
| PRS | ~/dev/pawsit-results-service/ | Pawsit results API |
| emailer | ~/dev/emailer-service/ | Email service |
| logistics | ~/dev/logistics-service/ | Logistics service |
| MMS | ~/dev/mammal-management-service/ | Mammal management API |
| samples | ~/dev/sample-service/ | Sample processing service |
| dogchat | ~/dev/dogChatApi/ | Dog chat API |
| careplan | ~/dev/care-plan-generator/ | Care plan generation |
| epi | ~/dev/epigenetics-backend/ | Epigenetics API |
| flags | ~/dev/feature-flags/ | Feature flag service |
| secrets | ~/dev/secrets-manager/ | Secrets management |
| mesh | ~/dev/pets-mesh/ | Service mesh |
| tooling | ~/dev/scale-common-tooling/ | Shared tooling/libraries |
| airflow | ~/dev/airflow-platform/ | Airflow data pipelines |
| dbsync | ~/dev/web-platform-database-sync/ | DB sync tooling |
| mobile | ~/dev/embark-mobile-app/ | Mobile app |
| puppy | ~/dev/puppy-express/ | Puppy Express service |

Example: "check how MMS handles auth" → read from `~/dev/mammal-management-service/`. "compare CRS and PRS routes" → read from both.

Example: "check how auth works in customer-results-service" → read files from `~/dev/customer-results-service/` directly.

---

# Rules

1. Read the `AGENTS.md` file in repos you work in BEFORE starting any tasks. It contains repo-specific instructions for linting, typechecks, DB migration naming conventions, etc.

2. When spinning teams of new agents, give each new agent a funny name. Use the names of American criminals from the 1800s and 1900s (e.g. Butch Cassidy, Sundance Kid, etc).

3. When creating a new branch, use the default repo branch (e.g. main) as the base unless specifically asked to use the current branch.

4. Unless explicitly allowed, never commit directly to the default branch. Create a new branch first.

5. Use the user skills available to you when doing new work.

6. Avoid using the word `skedaddle` or its derivatives.
