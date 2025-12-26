#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required. Install from https://cli.github.com/" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to format output." >&2
  exit 1
fi

if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

repo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)"
if [[ -z "$repo" ]]; then
  echo "Unable to determine repository. Run inside a GitHub repo with a configured remote." >&2
  exit 1
fi

user="$(gh api user -q .login)"
if [[ -z "$user" ]]; then
  echo "Unable to determine GitHub user login." >&2
  exit 1
fi

print_section() {
  local title="$1"
  local query="$2"
  local prs_json
  if ! prs_json="$(gh pr list --repo "$repo" --search "$query" --json number,title,url)"; then
    echo "Failed to query PRs for: $title" >&2
    return 1
  fi

  local count
  count="$(echo "$prs_json" | jq 'length')"
  echo "== $title ($count)"
  if [[ "$count" -eq 0 ]]; then
    echo "(none)"
  else
    echo "$prs_json" | jq -r '.[] | "#\(.number) \(.title) - \(.url)"'
  fi
  echo ""
}

echo "Repo: $repo"
echo "User: $user"
echo ""

print_section "Review requested" "review-requested:$user state:open"
print_section "My draft PRs" "author:$user is:draft state:open"
print_section "My approved PRs (open)" "author:$user review:approved state:open"
