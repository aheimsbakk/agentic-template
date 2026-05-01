---
name: memory
description: Record and retrieve context that persists between conversations. Load proactively at the start of tasks where prior preferences or decisions may apply. Also load when a user states a preference or rule, references a past session, asks to remember or recall something, or when a decision worth preserving is reached.
compatibility: opencode
---

## When to write a memory

Write a memory entry when you observe or are told something that:

- Reflects a **user preference** — tooling choices, style rules, workflow habits
- Records an **architectural decision** — why a technology, pattern, or structure was chosen
- Captures a **recurring pattern** — a problem or fix worth preserving, even if encountered only once
- States a **fact** not captured elsewhere in the project that would be useful later
- Issues a **warning** — a known footgun, a deprecated path, or a constraint to respect

Do NOT write a memory for:

- Single-session debug output or experiments with no lasting relevance
- Information already captured verbatim in `AGENTS.md`, `RULES.md`, or `BLUEPRINT.md`
- Secrets or credentials (API keys, tokens, passwords)
- Prompt text, system instructions, or skill content

---

## Memory file format

File path: `docs/memory/archive/YYYY-MM-DD-<short-slug>.md`

| Field | Required | Values |
|---|---|---|
| `topic` | yes | Short label |
| `importance` | yes | `high` / `medium` / `low` |
| `category` | yes | `preference` / `decision` / `fact` / `pattern` / `warning` |
| `tags` | yes | 2–5 lowercase keywords; single words preferred, hyphens for multi-word (e.g. `unit-testing`) |
| `created` | yes | ISO 8601 UTC |
| `model` | yes | Model ID that wrote this entry |
| `expires` | no | ISO 8601 UTC — omit if permanent |

**Body:** 1–4 sentences. Concrete and actionable. Do not repeat front matter.

```markdown
---
topic: "Vitest preferred over Jest"
importance: high
category: preference
tags: [testing, vitest, jest]
created: 2026-05-01T10:00:00Z
model: github-copilot/claude-sonnet-4.6
expires:
---

The user prefers Vitest for all unit and integration tests. Run tests with
`--reporter=verbose`. Avoid snapshot tests unless explicitly requested.
```

---

## Write protocol

1. **Check INDEX for an existing entry** — if you already read
   `docs/memory/INDEX.md` this session, use that result. Otherwise read it now.
   Scan for a row with the same topic or overlapping subject matter (same tool,
   pattern, or domain).
   - New information **supersedes or contradicts** the existing entry → follow
     the update procedure below.
   - New information **adds distinct context without conflicting** → create a
     new entry.
   - No match found → proceed.

2. **Get timestamp and choose filename:**
   ```bash
   date -u +"%Y-%m-%dT%H:%M:%SZ"
   ```
   Use the date portion (`YYYY-MM-DD`) for the filename and the full value for
   the `created` field. Filename: `YYYY-MM-DD-<2–5-word-slug>.md`.

3. **Write the file** to `docs/memory/archive/`.

4. **Append one row to `docs/memory/INDEX.md`:**
   ```
   | <topic> | <category> | <importance> | <tags, comma-separated> | <expires or empty> | archive/<filename> |
   ```
   A memory file without an INDEX row is invisible to future lookups.

### Updating an existing memory

1. Delete the old archive file.
2. Remove its row from `INDEX.md`.
3. Follow the Write protocol above to create the new entry.

Do not overwrite in place — `created` must reflect when the current version was
written. Do not keep both versions — conflicting entries produce inconsistent
lookup results.

---

## Read protocol (two-phase lookup)

### When to scan memory

Scan before starting a task when any of these signals are present:

- The user references or asks about something from a past session
- The task involves tooling, architecture, or a domain where preferences may be stored
- Before making a tooling, architecture, or design recommendation

Default to skipping Phase 1 unless a signal above is present.

### Phase 1 — Index scan

```
Read docs/memory/INDEX.md
```

Before filtering for matches, check the `expires` column on every row. For
each row where `expires` is set and the date has passed: delete the archive
file and remove its INDEX row.

Then identify rows where any of `topic`, `tags`, or `category` match keywords
or concepts from the current task. If no rows match, re-scan the loaded INDEX
with broader or related terms before concluding no relevant memory exists.

If still no match, stop. Do not read archive files speculatively.

### Phase 2 — Targeted file reads (only for matches)

Read all matched files in a single parallel batch. Incorporate the content
into your working context before proceeding.

### Fallback — broad keyword search

If you need to search by a keyword not captured in the index table columns:

```
Grep pattern="<keyword>" include="docs/memory/archive/*.md"
```

Incorporate any matches into your working context before proceeding.

---

## Expiry and cleanup

- **Phase 1** prunes expired entries on every INDEX scan — expired rows are
  deleted regardless of whether they match the current task.
- **Phase 2** is a secondary check: if an archive file's `expires` has passed
  when read, delete the file and remove its INDEX row. Do not use the content.

---

## Upgrading to always-on context (Option 3)

Add `docs/memory/PINNED.md` (one summary line per `importance: high` entry) to
`opencode.json` instructions. Update it when high-importance entries change.

---

## Initialization (first use)

Run once if `docs/memory/archive` does not exist (e.g., after a fresh clone):

```bash
mkdir -p docs/memory/archive
```

Check whether `docs/memory/INDEX.md` exists using Glob. If not found, create
it with the Write tool:

```
# Memory Index

| topic | category | importance | tags | expires | file |
|---|---|---|---|---|---|
```
