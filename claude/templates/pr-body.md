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
Manual verification steps only — flows a human runs by hand, ideally in a test/staging environment against a real build. Do NOT list automated tests of any kind (unit, integration, e2e, snapshot, etc.); CI runs those and they don't belong here. Concrete, runnable steps with URLs, inputs, and expected results — for both the author (who will self-review the PR) and the reviewer. Use `- [x]` for steps already performed and `- [ ]` for steps still to run, regardless of who runs them. Only check off steps that were actually performed — don't pad with claims that weren't verified.

### Follow-ups (optional)
Only include if there's deferred work or out-of-scope items a reviewer genuinely needs to know about — to preempt "why didn't you also fix X?" questions. Skip entirely otherwise; don't pad with hypothetical future work.

## Iterative drafting

For new PRs and full rewrites of an existing PR body, draft the body one section at a time and get approval before moving on. (Skip this flow for small targeted edits to an existing PR — go straight to the edit.)

For each section in the order listed above:

1. Draft the section's content.
2. Present it via `AskUserQuestion` with options `Approve`, `Revise`, and `Skip section` (use `Skip section` only for sections marked optional). Include the drafted content in the question text so it's reviewable in place.
3. On `Approve`, move to the next section. On `Revise`, incorporate the feedback and re-present. On `Skip section`, drop it and move on.
4. Also propose the PR title the same way (Approve / Revise) before invoking `gh`.

Only after every section is approved, assemble the final body and create or update the PR.

## Invocation

Write the body to a temp file with the `Write` tool, then invoke `gh pr create --draft --title "..." --body-file /tmp/pr-body.md`. New PRs are always created as drafts. Do NOT pass the body inline via `--body "..."` or a `"$(cat <<EOF ... EOF)"` substitution — those routes mangle backticks (they get backslash-escaped and render as `` \` `` in the published PR, breaking code spans; see e.g. PR #488 on `superlistapp/onsen`). `--body-file` reads the file verbatim, so backticks, dollar signs, and quotes all pass through untouched.

When updating an existing PR, never convert it back to draft — even if the changes are substantial. Edit the title/body only (per the global CLAUDE.md rule) and leave the ready-for-review state alone.

Keep the title under 70 characters; defer details to the body.
