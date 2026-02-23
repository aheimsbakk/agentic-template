# Agent Protocol & Master Rules

## 0. Operating Modes
This project is maintained by specialized AI agents and supports two distinct workflows:

**Mode A: The Multi-Agent Workflow (Agentic)**
Orchestrated by the Project Manager (`pm`). Used for autonomous, multi-step feature development.
- **Architect:** Plans features, deduces project rules, and updates `BLUEPRINT.md` and `PROJECT_RULES.md`. NEVER writes code.
- **Builder:** Implements code strictly according to plans and rules, bumps versions, and writes the worklog.
- **QA:** Runs tests, validates code against `RULES.md` and `PROJECT_RULES.md`, and performs the final Git commit.

**Mode B: Interactive Copilot (Vibe Mode)**
Driven by the Vibe Agent (`vibe`). Used for fast, interactive pair-programming directly with the user.
- Executes changes, tests, and debugging directly.
- MUST strictly adhere to overarching project rules in `agents/RULES.md` and `docs/PROJECT_RULES.md`.
- MUST update `BLUEPRINT.md` and `CONTEXT.md` to keep the Architect informed for future Agentic workflows.

## 1. Worklogs (Long-term memory)
- **Responsibility:** The **BUILDER** (Mode A) or **Vibe Agent** (Mode B, upon user wrap-up) must generate the worklog file after finishing the code.
- **Path:** `docs/worklogs/YYYY-MM-DD-HH-mm-{short-desc}.md`
- **Date and time:** Use `date` command to fetch date and time.
- **Front Matter (Strict):** Must contain ONLY these keys:
  ```yaml
  ---
  when: 2026-02-14T12:00:00Z  # ISO 8601 UTC
  why: one-sentence reason
  what: one-line summary
  model: model-id (e.g. github-copilot/gpt-4)
  tags: [list, of, tags]
  ---
  ```
- **Body:** 1–4 sentences summarizing changes and files touched. NO redundant info.
- **Safety:** NO secrets, API keys, or prompt text.
- **Template:** `agents/WORKLOG_TEMPLATE.md`

## 2. Versioning & Scripts
- **Responsibility:** The **BUILDER** (Mode A) or **Vibe Agent** (Mode B, upon user wrap-up) must execute version bumping.
- **Rule:** Every finalized feature/bugfix MUST bump the version.
  - **Patch (0.0.x):** Bug fixes, refactors
  - **Minor (0.x.0):** New features, enhancements
  - **Major (x.0.0):** Breaking changes
- **Tool:** Run `scripts/bump-version.sh [patch|minor|major]`. 
- *(If the script does not exist, the agent is authorized to create it).*
- **Action:** The new version must be mentioned in the worklog body.

## 3. Testing & Validation
- **Responsibility Split (Mode A):** The **BUILDER** writes tests. The **QA Engineer** executes them.
- **Responsibility (Mode B):** The **Vibe Agent** handles both writing and running tests interactively.
- Tests and validation scripts (`scripts/validate-worklog.sh`) must be executed before committing.
- Test scripts must exit with `0` on success and `>0` on error to avoid unnecessary wait times.
- If a test fails in Mode A, QA MUST NOT fix the code. QA returns the failure to the PM.

## 4. Committing (End of Workflow)
- **Responsibility:** The **QA Engineer** (Mode A) or **Vibe Agent** (Mode B, upon user wrap-up) performs the final Git commit (`git add .` and `git commit -m "..."`) ONLY after all tests and validations pass.
- **Commit message:** Must follow Conventional Commits format and reference the new version.
- Do not create Github Actions, or any CI/CD under `.github`.
