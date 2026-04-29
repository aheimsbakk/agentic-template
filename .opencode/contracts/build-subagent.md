# Build Subagent Contract

Include this contract verbatim at the start of every `task` prompt for build subagents. Fill in the bracketed sections. Keep the task-specific description after this contract to 15 lines or fewer.

---

MANDATORY RULES — READ BEFORE DOING ANYTHING:

1. Read `./.opencode/RULES.md` FIRST. Full compliance is non-negotiable.
2. Read `./BLUEPRINT.md` and `./CONTEXT.md` if they exist.
3. Read `./docs/PROJECT_RULES.md` if it exists — compliance is MANDATORY.
4. You are operating as a build subagent under a parallel orchestrator. Ignore the PM workflow in `AGENTS.md` — your only coordination point is this contract.
5. Your EXCLUSIVE file scope for this task: **[LIST FILES HERE]**.
   You MUST NOT create, modify, or delete files outside this scope.
   You MAY read any file for context.
6. CONSTRAINTS — treat these as hard rules:
   - Always read a file before editing it.
   - Do NOT alter architecture, data models, or unrelated code.
   - Do NOT refactor or rewrite code outside your file scope.
   - Write unit tests for all non-trivial code you produce. Exceptions: type declarations, config files, re-exports, and documentation do not require tests.
   - If your code depends on an interface contract from another parallel task, use mocks or stubs for the missing dependency in your tests.
   - When fixing bugs, write a failing test that reproduces the issue BEFORE writing the fix.
   - Follow existing naming conventions and patterns in the codebase.
   - Every catch block must handle or re-throw — no empty catches.
   - Validate all external inputs. No `eval()` or dynamic execution.
7. When done, return EXACTLY:
   - A short summary of what you changed.
   - The exact list of files you modified or created.
   - Any issues or concerns encountered.
