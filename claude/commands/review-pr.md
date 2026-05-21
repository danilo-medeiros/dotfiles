---
description: "Walk through a PR description iteratively, then record per-hunk review notes via the notetaker agent."
argument-hint: "<PR URL or number>"
allowed-tools: ["Bash", "Read", "Grep", "Task"]
---

# Review a PR (iterative walk-through + notetaker annotations)

Help the user review the pull request referenced by `$ARGUMENTS` (a GitHub PR URL or number). Source files are **never** modified — per-change notes are recorded by delegating to the `notetaker` agent, which appends to `.codenotes` at the repo root.

## Workflow

### 1. Fetch PR details

- Resolve `$ARGUMENTS` to a PR. Accept either a full URL (`https://github.com/owner/repo/pull/N`) or a bare number (in which case use the current repo).
- Run `gh pr view <pr> --json number,title,url,body,headRefName,baseRefName,changedFiles,additions,deletions,files,author,state` to fetch metadata.
- Store the result; you'll reference it throughout.

### 2. Split the PR description into parts and walk through iteratively

- Parse the PR body (`.body` from step 1).
- **Omit** any section titled "Changes", "Changelog", "What changed", or similar — those will be covered when annotating hunks in step 4. Also omit obvious boilerplate (empty PR template checkboxes, "Generated with Claude Code" footers, etc.).
- Split the remaining content into logical parts. Use markdown headings (`##` / `###`) as the natural boundary. If the body has no headings, split by blank-line-separated paragraphs/sections.
- **Show one section at a time**, then **stop and wait for the user's reply** before moving to the next. Do not dump all sections at once.
- For each section: render it verbatim (preserving formatting), then add a brief one-line gloss of what the section is establishing. End your turn — the user will respond with "next", a question, or a comment. Treat any question as a request to discuss the section before moving on.
- When all description sections have been walked through, say so explicitly and proceed to step 3.

### 3. Decide whether to check out locally

- Read `changedFiles` from step 1.
- **If > 1 file changed**: check out the branch locally.
  - Confirm the current working directory is the right repo (compare PR's `url` host/owner/repo to `git remote get-url origin`). If not, tell the user and stop — don't `cd` elsewhere or clone without confirmation.
  - Check for uncommitted changes (`git status --porcelain`). If the tree is dirty, stop and ask the user how to proceed.
  - Run `gh pr checkout <pr-number>`.
- **If exactly 1 file changed**: skip checkout. Fetch the diff with `gh pr diff <pr-number> -- <file>` and still proceed to step 4 — the notetaker will key notes against the file path at the PR's head SHA, even without a local checkout. (You can pass the base-branch line numbers as a fallback if the file doesn't exist locally; mention this caveat to the user.)

### 4. Record a note per hunk via the notetaker agent

For each file in the PR's changed file list:

- Skip files that are:
  - Binary (images, fonts, archives, etc.)
  - Lockfiles (`package-lock.json`, `yarn.lock`, `Cargo.lock`, `go.sum`, `Gemfile.lock`, `poetry.lock`, `pnpm-lock.yaml`, etc.)
  - Generated files (anything with a `@generated` or `DO NOT EDIT` marker near the top)
  - Pure deletions (file no longer exists in the PR's head — note these once in step 5's wrap-up instead)
- For each remaining file:
  - Read the per-file diff: `gh pr diff <pr-number> -- <file>` to see the hunks.
  - For each hunk in that file:
    - Pick an **anchor line**: the first added or modified line of the hunk in the file as it exists on the PR branch (the `+c` in the `@@ -a,b +c,d @@` header, advanced to the first `+` or context-changed line). For a pure-deletion hunk inside an otherwise-modified file, anchor at the line immediately before the deletion site.
    - Form an understanding of what the hunk does and why, drawing on the PR description context from step 2.
    - Compose the note text:
      - 1–2 sentence summary of what this hunk changes and why.
      - If you have a concern (possible bug, missed edge case, surprising choice, question for the author), add a second paragraph (no blank line — use a single newline) starting with `concern:` and being specific. Omit when you have none — do not invent concerns.
      - Match the terse style the notetaker examples use (lowercase start is fine; em-dashes fine; no blank lines within the note).
    - Delegate to the notetaker via the Task tool with `subagent_type=notetaker`. The prompt should give the agent the repo-relative path, the anchor line, and the note text verbatim — e.g.:

      > Add a note on `<path>:<line>`:
      > <note text>

    - If two hunks in the same file are adjacent or so closely related that two notes would be redundant, anchor a single note at the first hunk's line and cover both in its text.

- Process files one at a time and report each delegation as you go (one line per note: file:line plus a short paraphrase). Don't batch silently. If the notetaker reports a duplicate or asks for resolution, surface that to the user.

### 5. Wrap up

When all hunks are noted, print:

- A list of `path:line` keys you recorded notes against.
- The list of files you skipped and why (binary, lockfile, generated, pure deletion — name each deleted file in this list).
- Point the user at `.codenotes` at the repo root for the full set of notes, and offer to run `cat .codenotes` or `grep -n 'concern:' .codenotes` to focus on flagged hunks.

## Notes

- Don't post anything to GitHub.
- Don't modify any source file — all output goes through the notetaker agent into `.codenotes`.
- Don't `git add`, `git commit`, or `git push` anything. Don't rebase. Don't force-push.
- If `gh pr checkout` would overwrite local work, stop and ask.
- If the PR is closed or merged, still proceed — the user may be reviewing historically.
- Keep your prose tight. The point is to surface the PR's substance, not to pad it.
