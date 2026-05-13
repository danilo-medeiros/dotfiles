# PR body template

If the repo has its own template (`.github/pull_request_template.md`, `docs/pull_request_template.md`), use it as the base and only add sections below that are missing — do not duplicate or reorder.

## First line: ticket link

```
Ticket: [TICKET-123](https://link-to-ticket)
```

Infer the ticket from the branch name (e.g. `abc-1361-...` → `ABC-1361`) or the latest commit message. If none can be inferred, ask before creating the PR — do not omit or guess.

## Sections (in order)

### Summary
One to two paragraphs on what changed and why. Intent and motivation — the diff covers mechanics. Avoid using lists.

### Notable decisions (optional)
Only include if there are technical decisions a reviewer should know about — trade-offs taken, alternatives rejected, non-obvious choices. Skip the section entirely when there's nothing worth flagging. Format: short bullets, each a decision followed by a one-line rationale. This is about *why this approach*; leave *what could break* to Risks.

### Key changes
Highlights only — the logical changes a reviewer needs to understand, not a file-by-file list (the diff covers that). Group by area or intent when it helps. Skip if the Summary already makes the changes obvious.

### Risks
What could break or regress: behavior changes for callers, performance, migrations, flags, rollback. If the risk is genuinely negligible, say so and why — don't leave it empty.

### Testing
Concrete, runnable steps with commands, URLs, inputs, and expected results — for both the author (who will self-review the PR) and the reviewer. Use `- [x]` for steps already performed and `- [ ]` for steps still to run, regardless of who runs them. Skip anything CI already enforces (lint, format, type checks, unit tests) — those are assumed; only list verification that goes beyond CI, like manual flows or integration runs. Only check off steps that were actually performed — don't pad with claims that weren't verified.

### Follow-ups (optional)
Only include if there's deferred work or out-of-scope items a reviewer genuinely needs to know about — to preempt "why didn't you also fix X?" questions. Skip entirely otherwise; don't pad with hypothetical future work.

## Invocation

Write the body to a temp file with the `Write` tool, then invoke `gh pr create --draft --title "..." --body-file /tmp/pr-body.md`. New PRs are always created as drafts. Do NOT pass the body inline via `--body "..."` or a `"$(cat <<EOF ... EOF)"` substitution — those routes mangle backticks (they get backslash-escaped and render as `` \` `` in the published PR, breaking code spans; see e.g. PR #488 on `superlistapp/onsen`). `--body-file` reads the file verbatim, so backticks, dollar signs, and quotes all pass through untouched.

When updating an existing PR, never convert it back to draft — even if the changes are substantial. Edit the title/body only (per the global CLAUDE.md rule) and leave the ready-for-review state alone.

Keep the title under 70 characters; defer details to the body.
