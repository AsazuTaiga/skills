---
name: gh-repo-task-list
description: List GitHub PR tasks for the current repository using gh CLI. Use when asked to enumerate what the user must handle in a repo, such as PRs with review requested from the user, the user's draft PRs, and the user's open PRs that are approved by others but not merged.
---

# Gh Repo Task List

## Overview

List PR-related tasks in the current GitHub repository using `gh` and present them in interactive console output with PR number and link.

## Quick Start

1. Ensure `gh auth status -h github.com` is clean.
2. Run the script from the target repository:

```bash
/Users/asazu/.codex/skills/gh-repo-task-list/scripts/list_repo_pr_tasks.sh
```

3. Paste the console output back to the user.

## Default Sections (implemented by the script)

- Review requested from the user
- Draft PRs authored by the user
- Open PRs authored by the user that have at least one approval and are not merged

## Query Details (for changes or extensions)

The script uses GitHub search qualifiers via `gh pr list --search`:

- Review requested: `review-requested:<login> state:open`
- Draft PRs: `author:<login> is:draft state:open`
- Approved, not merged: `author:<login> review:approved state:open`

If the user asks for more categories, add new sections with the same pattern and explain the new queries in the response.

## Output Format

Each section prints a count and lines in this format:

```
#123 PR title - https://github.com/owner/repo/pull/123
```

Always include the PR number and URL as requested.

## Resources

### scripts/

- `list_repo_pr_tasks.sh` - main entry point for listing tasks in the current repository.
