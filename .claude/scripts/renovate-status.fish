#!/usr/bin/env fish
#
# renovate-status.fish — Condensed state dump of open Renovate PRs for the current repo.
#
# Fetches in a single GraphQL call: CI rollup, review decision, mergeStateStatus,
# mergeable, autoMergeRequest, isInMergeQueue, labels. Prints a compact table so
# the bot can read whole-repo state in one turn rather than 1 + N `gh pr checks`
# calls across the PR list.
#
# Usage:
#   renovate-status.fish [--json] [--all-authors] [--history N]
#
# Options:
#   --json          Emit {open, recent} as JSON instead of the formatted table.
#   --all-authors   Include all open PRs, not only those authored by renovate-bot-service.
#   --history N     Number of recently-merged Renovate PRs to show (default 3, pass 0 to skip).
#
# Repo selection:
#   Uses $GH_REPO if set, otherwise the current git repo (via `gh repo view`).
#
# Output columns:
#   #<num>  kind  state:<X>  ci:<X>  review:<X>  auto:<X>  queue:<X>  labels:<X>  title
#
#   kind         sec | prod | dev | -
#                  sec   = [SECURITY] in title (urgent per merge policy)
#                  prod  = fix(deps): — runtime deps (more risk surface)
#                  dev   = chore(deps): — devDeps only (lower risk)
#                  -     = title doesn't match a known prefix
#                Note: semver major/minor/patch is NOT classified — Renovate groups multiple
#                updates into one PR, so the title can lie. Check the PR body if exact bumps matter.
#   state        CLEAN | BEHIND | BLOCKED | DIRTY | UNSTABLE | HAS_HOOKS | DRAFT | UNKNOWN
#   ci           pass | red | err | run | wait | -           (statusCheckRollup on last commit)
#   review       approved | changes | required | none
#   auto         on | -                                       (autoMergeRequest: `gh pr merge --auto` was called)
#   queue        YES | -                                      (isInMergeQueue: synthetic merge commit is running CI NOW)
#   labels       compact label summary (do-not-merge / needs-work / +N for other labels)
#
# After the open-PR table, a "Recently merged" section lists the last N merged Renovate PRs
# with kind + relative age ("2h ago", "3d ago"). A long gap (weeks without a merge) is a
# signal that the repo has stalled — usually because every open PR needs human action.
#
# State→stage map (what the bot should do next for each common combo):
#   DIRTY                             — merge conflicts;           rebase (skill Phase 3 "If there are merge conflicts")
#   BEHIND        + ci:pass           — needs rebase on current main; rebase + force-push
#   UNSTABLE      + ci:run            — CI in progress;            wait-for-ci.fish
#   UNSTABLE      + ci:red            — CI failed;                 classify flaky vs real (skill Phase 3 "If CI is red")
#   BLOCKED       + ci:pass + review:none     — approval required; gh pr review --approve (skill Phase 5 step 1)
#   BLOCKED       + ci:pass + review:approved — branch protection gate beyond approval; investigate required checks
#   CLEAN + review:approved + auto:-          — ready to queue;     gh pr merge --squash --auto
#   CLEAN + auto:on + queue:-                 — auto-merge armed, waiting for slot; wait
#   CLEAN + auto:on + queue:YES               — IN the merge queue; wait-for-merge.fish, do NOT queue another PR
#   any           + queue:YES (different PR)  — queue busy;         prepare-ahead only (skill Phase 6)
#
# Exit codes:
#   0  Dumped successfully (even if zero PRs)
#   3  Usage error or gh CLI failure

set -x CLICOLOR_FORCE 0

argparse --name=renovate-status 'json' 'all-authors' 'history=' -- $argv
or begin
    echo "Usage: renovate-status.fish [--json] [--all-authors] [--history N]" >&2
    exit 3
end

set -l history_n 3
if set -q _flag_history
    set history_n $_flag_history
end

# Determine repo
set -l repo
if set -q GH_REPO; and test -n "$GH_REPO"
    set repo $GH_REPO
else
    set repo (gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)
end

if test -z "$repo"
    echo "ERROR: could not determine repo (set \$GH_REPO or run inside a git checkout with a gh-accessible remote)" >&2
    exit 3
end

set -l author_filter "author:app/renovate-bot-service"
if set -q _flag_all_authors
    set author_filter ""
end

set -l open_query "repo:$repo is:pr is:open $author_filter"
set -l merged_query "repo:$repo is:pr is:merged $author_filter sort:updated-desc"

set -l gql_query 'query($open: String!, $merged: String!, $n: Int!) {
  open: search(query: $open, type: ISSUE, first: 50) {
    nodes {
      ... on PullRequest {
        number
        title
        mergeStateStatus
        mergeable
        isInMergeQueue
        reviewDecision
        autoMergeRequest { enabledAt }
        labels(first: 20) { nodes { name } }
        commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
      }
    }
  }
  recent: search(query: $merged, type: ISSUE, first: $n) {
    nodes {
      ... on PullRequest {
        number
        title
        mergedAt
        mergedBy { login }
      }
    }
  }
}'

set -l result (gh api graphql -F open="$open_query" -F merged="$merged_query" -F n=$history_n -f query="$gql_query" 2>&1)
if test $status -ne 0
    echo "ERROR: gh api graphql failed: $result" >&2
    exit 3
end

if set -q _flag_json
    echo $result | jq '{open: .data.open.nodes, recent: .data.recent.nodes}'
    exit 0
end

set -l count (echo $result | jq '.data.open.nodes | length')
if test "$count" -eq 0
    echo "# $repo — 0 open PRs matching search"
else
    echo "# $repo — $count open PR(s)"
    echo $result | jq -r '
  .data.open.nodes[]
  | . as $pr
  | (.labels.nodes | map(.name)) as $labels
  | (
      # Kind: security beats everything (Renovate marks these with [SECURITY] in title).
      # Otherwise use the conventional-commit prefix as a proxy for dep-set: `fix(deps):` =
      # runtime deps (more risk), `chore(deps):` = devDeps only (less risk).
      # Semver major/minor/patch is intentionally NOT classified — Renovate PRs can bundle
      # multiple updates and the title only reflects one; details live in the PR body.
      if   ($pr.title | test("\\\\[security\\\\]"; "i")) then "sec"
      elif ($pr.title | test("^fix\\\\(deps"; "i"))      then "prod"
      elif ($pr.title | test("^chore\\\\(deps"; "i"))    then "dev"
      else "-"
      end
    ) as $kind
  | (.commits.nodes[0].commit.statusCheckRollup.state // "none") as $ci_state
  | (
      if   $ci_state == "SUCCESS"  then "pass"
      elif $ci_state == "FAILURE"  then "red"
      elif $ci_state == "ERROR"    then "err"
      elif $ci_state == "PENDING"  then "run"
      elif $ci_state == "EXPECTED" then "wait"
      else "-"
      end
    ) as $ci
  | (
      (.reviewDecision // "none")
      | if   . == "APPROVED"          then "approved"
        elif . == "CHANGES_REQUESTED" then "changes"
        elif . == "REVIEW_REQUIRED"   then "required"
        else "none"
        end
    ) as $review
  | (if .autoMergeRequest then "on"  else "-" end) as $auto
  | (if .isInMergeQueue   then "YES" else "-" end) as $queue
  | (
      [
        (if $labels | index("do-not-merge")            then "do-not-merge"     else empty end),
        (if $labels | index("renovate-bot:needs-work") then "needs-work"       else empty end)
      ] as $special
      | ($labels | map(select(. != "do-not-merge" and . != "renovate-bot:needs-work")) | length) as $other
      | if   ($special | length) == 0 and $other == 0 then "-"
        elif ($special | length) == 0                 then "+\($other)"
        elif $other == 0                              then ($special | join(","))
        else "\($special | join(",")) +\($other)"
        end
    ) as $label_col
  | (if (.title | length) > 70 then (.title[0:67] + "...") else .title end) as $title
  | "#\(.number)\t\($kind)\tstate:\(.mergeStateStatus)\tci:\($ci)\treview:\($review)\tauto:\($auto)\tqueue:\($queue)\tlabels:\($label_col)\t\($title)"
' | column -t -s \t
end

set -l recent_count (echo $result | jq '.data.recent.nodes | length')
if test "$recent_count" -gt 0
    echo ""
    echo "# Recently merged (last $recent_count):"
    echo $result | jq -r '
      .data.recent.nodes[]
      | . as $pr
      | (
          if   ($pr.title | test("\\\\[security\\\\]"; "i")) then "sec"
          elif ($pr.title | test("^fix\\\\(deps"; "i"))      then "prod"
          elif ($pr.title | test("^chore\\\\(deps"; "i"))    then "dev"
          else "-"
          end
        ) as $kind
      | (now - (.mergedAt | fromdateiso8601)) as $age
      | (
          if   $age < 3600   then "\($age/60|floor)m ago"
          elif $age < 86400  then "\($age/3600|floor)h ago"
          else "\($age/86400|floor)d ago"
          end
        ) as $age_str
      | (if (.title | length) > 70 then (.title[0:67] + "...") else .title end) as $title
      | "#\(.number)\t\($kind)\t\($age_str)\t\($title)"
    ' | column -t -s \t
end
