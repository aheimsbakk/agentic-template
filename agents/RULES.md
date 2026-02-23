# Master Project Rules

## I. Workflow & Scoping
1. **Protocol Alignment:** Project-specific protocols (`AGENTS.md`, `BLUEPRINT.md`) are the absolute source of truth. Read them first and NEVER bypass their defined workflows.
2. **English-Only Artifacts:** All code, variables, comments, commits, and documentation MUST be in professional English, regardless of the chat language used.
3. **Strict Scoping:** Make surgical edits only. Do NOT perform "drive-by" refactoring or change existing logic outside the immediate scope of the task.

## II. Security & Data Hygiene
4. **Secrets & Logging:** NEVER hardcode secrets; always use environment variables. Do not log sensitive user data or tokens. Use obviously fake data (e.g., `test-token-123`) for tests.
5. **Zero Trust & Execution:** Validate and sanitize ALL external inputs. Prevent injection by using parameterized queries. NEVER use `eval()` or dynamically execute raw strings.
6. **Authorization:** Assume all endpoints are private by default. Always verify ownership/authorization, not just authentication. Never store sensitive state in plain text.

## III. Architecture & Reliability
7. **Strict Boundaries:** Maintain clear separation of concerns. Do not mix client-side and server-side execution logic.
8. **Error Handling:** NO silent failures (empty `catch` blocks). Isolate faults to prevent app crashes, and ensure graceful degradation with clear error handling.
9. **Resource Management:** Implement rate-limiting, debouncing, and strict timeouts for network requests and async tasks. Validate asynchronous state to prevent race conditions.

## IV. Development & Maintenance
10. **Test-Driven Fixes:** When fixing bugs, you MUST write a failing unit test that reproduces the issue BEFORE modifying application code.
11. **Backward Compatibility:** Do not break existing callers; use fallbacks for changed signatures. Flag major component replacements with `@deprecated` instead of instant deletion.
12. **Dependencies:** Use explicit, stable package versions (no `latest` or wildcards). Always sync manifests and lockfiles. Prefer native code over adding small, unnecessary dependencies.

## V. Documentation & Formatting
13. **Strict Templating:** Strictly adhere to required formats (e.g., YAML front-matter in worklogs). Do not invent new fields, change key casing, or exceed length limits.
14. **Synchronized Docs:** Code and docs must match. Immediately update inline comments, `README.md`, developer guides, and `.env.example` when changing logic or adding variables.
