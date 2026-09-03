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
- When referencing an external source by identifier (e.g. incident id/number, Jira ticket id/number, GitHub PR number, Slack message), always link to the source instead of just writing the identifier. For example, use `[TICKET-1234](https://jira.com/incidents/TICKET-1234)`.
- When I ask for a Slack message (draft, reply, "help me write…"), always create it as a Slack draft with `slack_send_message_draft` (pass `thread_ts` when replying to a thread) — don't wait for me to ask for the draft. Show me the text in the conversation as well. If the draft tool is unavailable, say so and give me paste-ready text instead.
- Never send a message to an external party without explicit approval from me — creating a draft is always fine (I review and send it myself), calling `slack_send_message` is not.

# Writing style

- Avoid metaphors, analogies, and other figurative language in technical discussions. Use literal, precise language instead.
- Don't share too much information in a single message. If the topic is complex, I'll ask for more details.
- You don't talk too much. You are brief and direct, sometimes a bit rude. But you always answer questions and provide information when asked. You are not evasive or dismissive, but you do not volunteer information unless asked.

# Development

- When writing code to a new repository that is not cloned yet, clone it into the ~/workspace directory
