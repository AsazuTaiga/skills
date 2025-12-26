---
name: gh-pr
description: Create or update GitHub pull requests with the gh CLI. Use when the user asks to create/update PRs, draft PRs, or generate PR text. Generate Japanese PR title/body from git diffs, default base branch to next_release (configurable), detect UI changes for screenshots, extract Linear ticket IDs (generic format, e.g., XXX-1234), and require explicit user confirmation before any git push/gh pr create/edit.
---

# Gh Pr

Automate GitHub PR creation/update. Analyze diffs on the current branch, generate a Japanese PR title/body, and apply via gh after explicit user confirmation.

## Workflow

### 1) Interpret the request
Extract the intent:
- Create new PR or update existing PR (`update <PR number>`)
- Base branch override via `--base <branch>` (default `next_release` if unspecified)
- `--draft` flag

If anything is unclear, ask first (PR number, base branch, etc.).

### 2) Pre-checks
Perform minimal safety checks:
- gh auth status (suggest `gh auth status` if needed)
- Base branch exists (`git show-ref --verify refs/heads/<base>`)
- Local changes are committed (`git status -sb`)

### 3) Collect diff context
Gather and summarize (focus on key parts for large diffs):
- `git diff <base>...HEAD`
- `git diff <base>...HEAD --stat`
- `git log --oneline <base>..HEAD`
- Relevant file contents (only what is necessary)

Exclude binaries, generated files, or huge files unless explicitly requested.

### 4) Extract additional signals
- **Ticket IDs**: Extract Linear ticket IDs from commit messages and branch names. Treat any project prefix like `AME-` as a Linear ticket format, and normalize examples/output to `XXX-1234` (do not hardcode project prefixes).
- **UI change detection**: If `*.tsx`, `components/`, or style-related files changed, treat as UI changes.

If UI changes are detected, prompt for screenshots/videos in the PR body.

### 5) Generate PR body (Japanese)
Use the template in `assets/pr-body-template.md` (trim sections when unnecessary). Do not inline the template in the skill body; load and follow the asset file when generating.

### 6) Preview and revise
Always show and confirm:
- Base branch
- Draft/regular
- Proposed PR title
- Full PR body
- Extracted ticket IDs
- UI change detection result

Apply user edits and finalize.

### 7) Explicit confirmation before execution (required)
**Follow the global policy** and present the following before execution, then ask for explicit `y/N`:
- Repo absolute path
- Current branch
- `git status -sb`
- `git diff --staged`
- `git diff`
- Full list of commands to run (one command per line)

Do not run git push or gh commands until the user explicitly says yes.

### 8) Execute (one-time only)
After approval, run once only (no retries or loops).

**Create**
- If needed: `git push -u origin <branch>`
- `gh pr create --title "<title>" --body "<body>" --base <base>`
- Add `--draft` when requested

**Update**
- `gh pr edit <PR number> --body "<body>"`

Report the result briefly (success/failure, `gh pr view` summary, etc.).

## Output quality guide
- Write PR title/body in Japanese with clear bullet points
- Make changes concrete: what changed and how
- Limit reviewer asks to 1-2 items
- Prefer concise, high-signal content
