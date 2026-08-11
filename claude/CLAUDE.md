# Branch naming

- Do NOT prefix branch names with my username
- Use ticket-based prefixes (e.g., `abc-1461-fix-xyz`)

# Pull requests

When creating a PR, follow @templates/pr-body.md.

- Keep PRs under ~500 lines; split larger work into multiple PRs.

# PR reviews & descriptions

- Do NOT include nit-level feedback in PR reviews unless explicitly asked
- Do NOT include unverified testing claims or technical assertions in PR descriptions — only state what was actually verified
- When asked to update a PR, default to editing title/description only; do NOT rebase or force-push without explicit instruction
- Before overwriting a PR description, fetch the latest version from GitHub (`gh pr view`) — I may have edited it directly. If the current description differs from what was last written in this session, preserve my edits or ask before overwriting

# External communication

- When referencing code in a Jira ticket, GitHub PR, or Slack message, always link the path to its GitHub URL, e.g. `[path/to/some/code.sh](https://github.com/the/project/blob/branch/path/to/some/code.sh)` instead of a bare path.
- When referencing an external source by identifier (e.g. PagerDuty incident id/number, Jira ticket id/number, GitHub PR number, Slack message), always link to the source instead of just writing the identifier. For example, use `[PD-1234](https://pagerduty.com/incidents/PD-1234)`.
- When preparing a message to send to an external party (e.g. Slack), draft it first. If there's no tool available to do this, write it in a file and ask me to review it before sending.

# Conversation

- When showing links to external sources in a conversation, print them in plain text, so they are clickable in a terminal.

# Development

- When writing code to a new repository that is not cloned yet, clone it into the ~/workspace directory
