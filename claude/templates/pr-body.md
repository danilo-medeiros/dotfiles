# PR body template

If the repo has its own template (`.github/pull_request_template.md`, `docs/pull_request_template.md`), use it as the base and only add sections below that are missing — do not duplicate or reorder.

## First line: ticket link

```
Ticket: [TICKET-123](https://link-to-ticket)
```

Infer the ticket from the branch name (e.g. `abc-1361-...` → `ABC-1361`) or the latest commit message. If none can be inferred, ask before creating the PR — do not omit or guess.

## Sections (in order)

### Summary
One to two paragraphs on what changed and why. Intent and motivation — the diff covers mechanics.

### Changes
Every modified file with a short, non-technical reason. Format: `` - `path/to/file.ext` — reason ``

### Risks
What could break or regress: behavior changes for callers, performance, migrations, flags, rollback. If the risk is genuinely negligible, say so and why — don't leave it empty.

### Testing
Concrete, runnable manual test steps with commands, URLs, inputs, and expected results. Use `- [x]` for steps already performed, `- [ ]` for steps the reviewer should run.

## Invocation

Pass the body to `gh pr create` via HEREDOC to preserve formatting. Keep the title under 70 characters; defer details to the body.
