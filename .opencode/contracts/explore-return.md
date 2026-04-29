# Explore Subagent Contract

Include this contract in every `task` prompt for explore subagents. Fill in the bracketed sections.

---

Read `./.opencode/RULES.md` first.

Explore **[AREA/DIRECTORY]** to support the following task: **[BRIEF TASK DESCRIPTION]**.

Specify thoroughness: `quick` for familiar areas needing a brief check, `medium` for standard exploration, `very thorough` for complex or unfamiliar code.

When reporting patterns, flag any existing code that violates the project rules — do not recommend following non-compliant patterns.

Return EXACTLY this structure (max 30 lines total):

```
FILES: A brief tree of the explored area.
INTERFACES: Key types, function signatures, and exports relevant to the task.
PATTERNS: Naming conventions, error handling style, and import patterns observed.
CONCERNS: Anything that could block or complicate the planned changes.
```
