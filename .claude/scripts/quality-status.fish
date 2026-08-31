#!/usr/bin/env fish
#
# quality-status.fish — Quality bot verdict for a single PR.
#
# Inspects two quality bots (Qodo + DangerJS) on a Renovate-style PR and emits
# a compact verdict so the merge-renovate skill's Phase 4 can decide in one
# script call instead of fetching+parsing large HTML comment bodies.
#
# Primary signals (chosen for stability over template-version drift):
#   - Qodo:     presence of `<img alt="Action required">` in the latest persistent
#               review comment, gated by a freshness check (review reflects head SHA).
#   - DangerJS: failure count parsed from the `<!-- N failure: ... N warning: ... -->`
#               header in DangerJS's PR comment.
#
# Counts are also extracted (Qodo bugs/violations/gaps, DangerJS warnings) for the
# bot's run summary, but the merge decision uses only the binary signals above —
# they're less likely to break if Qodo's template changes.
#
# Usage:
#   quality-status.fish <pr> [--repo OWNER/REPO]
#
# Repo selection: $GH_REPO if set, else --repo flag, else gh's current-repo inference.
#
# Output (key=value lines, easy to grep/parse):
#   pr=<num>
#   head_sha=<40-hex>
#   qodo=none|stale|current|missing-update|error
#   qodo_action_required=yes|no|na
#   qodo_bugs=<N>           # only meaningful when qodo=current
#   qodo_violations=<N>
#   qodo_gaps=<N>
#   dangerjs=none|present|error
#   dangerjs_failures=<N>
#   dangerjs_warnings=<N>
#   verdict=BLOCK|PROCEED|WAIT
#   reason=<short text>     # only present when verdict != PROCEED
#
# Exit codes:
#   0  verdict=PROCEED  — quality gate clear, merge may proceed
#   1  verdict=BLOCK    — quality bot flagged something, do not merge
#   2  verdict=WAIT     — quality bot result not yet current (re-check next wake)
#   3  Usage / gh CLI error

set -x CLICOLOR_FORCE 0

argparse --name=quality-status 'repo=' -- $argv
or begin
    echo "Usage: quality-status.fish <pr> [--repo OWNER/REPO]" >&2
    exit 3
end

set -l pr $argv[1]
if test -z "$pr"
    echo "Usage: quality-status.fish <pr> [--repo OWNER/REPO]" >&2
    exit 3
end

set -l repo
if set -q _flag_repo
    set repo $_flag_repo
else if set -q GH_REPO; and test -n "$GH_REPO"
    set repo $GH_REPO
else
    set repo (gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)
end

if test -z "$repo"
    echo "ERROR: could not determine repo (pass --repo, set \$GH_REPO, or run inside a git checkout)" >&2
    exit 3
end

# Bot logins — org-level, hardcoded for GrandVision. Override via env if needed.
set -l qodo_login (test -n "$QODO_BOT"; and echo $QODO_BOT; or echo qodo-grandvisionhq)
set -l danger_login (test -n "$DANGER_BOT"; and echo $DANGER_BOT; or echo grandvisioncircleci)

set -l data (gh pr view $pr --repo $repo --json headRefOid,comments 2>/dev/null)
if test -z "$data"
    echo "ERROR: gh pr view failed for PR $pr in $repo" >&2
    exit 3
end

set -l head_sha (echo $data | jq -r .headRefOid)

# --- Qodo ---
# Latest persistent review (Qodo edits in place; we take the most recent matching comment)
set -l qodo_review_body (echo $data | jq -r --arg login $qodo_login \
    '[.comments[] | select(.author.login == $login and (.body | contains("Code Review by Qodo")))] | last | .body // ""')
set -l qodo_review_created (echo $data | jq -r --arg login $qodo_login \
    '[.comments[] | select(.author.login == $login and (.body | contains("Code Review by Qodo")))] | last | .createdAt // ""')
set -l qodo_update_sha (echo $data | jq -r --arg login $qodo_login \
    '[.comments[] | select(.author.login == $login and (.body | contains("latest commit")) and (.body | contains("Code Review by Qodo") | not))] | last | (.body // "") | (capture("commit/(?<s>[0-9a-f]{40})") // {s:""}).s')

set -l qodo_state none
set -l qodo_action na
set -l qodo_bugs 0
set -l qodo_violations 0
set -l qodo_gaps 0

if test -n "$qodo_review_body"
    # Freshness: prefer update notif's SHA; fall back to comparing review createdAt vs head commit date
    if test -n "$qodo_update_sha"
        if test "$qodo_update_sha" = "$head_sha"
            set qodo_state current
        else
            set qodo_state stale
        end
    else
        # No update notification yet. Either Qodo has only posted once (current),
        # or commits have been pushed but Qodo hasn't re-reviewed yet (stale).
        # Compare review createdAt to head commit's committer date as epoch seconds.
        set -l head_committed (gh api "repos/$repo/commits/$head_sha" --jq '.commit.committer.date' 2>/dev/null)
        if test -z "$head_committed"
            set qodo_state error
        else
            set -l a (date -j -u -f %Y-%m-%dT%H:%M:%SZ $qodo_review_created +%s 2>/dev/null)
            set -l b (date -j -u -f %Y-%m-%dT%H:%M:%SZ $head_committed +%s 2>/dev/null)
            if test -z "$a" -o -z "$b"
                set qodo_state error
            else if test $a -ge $b
                set qodo_state current
            else
                set qodo_state stale
            end
        end
    end

    # Counts (informational; verdict uses the action-required image)
    set -l b_match (string match -rg 'Bugs \((\d+)\)' -- $qodo_review_body | head -1)
    set -l v_match (string match -rg 'Rule violations \((\d+)\)' -- $qodo_review_body | head -1)
    set -l g_match (string match -rg 'Requirement gaps \((\d+)\)' -- $qodo_review_body | head -1)
    test -n "$b_match"; and set qodo_bugs $b_match
    test -n "$v_match"; and set qodo_violations $v_match
    test -n "$g_match"; and set qodo_gaps $g_match

    # Action-required image (primary blocking signal). Only meaningful when current.
    if test "$qodo_state" = current
        if string match -q '*alt="Action required"*' -- $qodo_review_body
            set qodo_action yes
        else
            set qodo_action no
        end
    end
end

# --- DangerJS ---
set -l danger_body (echo $data | jq -r --arg login $danger_login \
    '[.comments[] | select(.author.login == $login)] | last | .body // ""')

set -l danger_state none
set -l danger_failures 0
set -l danger_warnings 0
if test -n "$danger_body"
    set danger_state present
    set -l f (string match -rg '<!--\s*(\d+)\s+failure' -- $danger_body | head -1)
    set -l w (string match -rg '(\d+)\s+warning' -- $danger_body | head -1)
    test -n "$f"; and set danger_failures $f
    test -n "$w"; and set danger_warnings $w
end

# --- Verdict ---
set -l verdict PROCEED
set -l reason ""

if test "$qodo_state" = error
    set verdict WAIT
    set reason "qodo: error fetching head commit metadata"
else if test "$qodo_action" = yes
    set verdict BLOCK
    set reason "qodo: Action required (bugs=$qodo_bugs)"
else if test "$qodo_state" = stale
    set verdict WAIT
    set reason "qodo: review stale (head=$head_sha, review-sha=$qodo_update_sha) — awaiting refresh"
else if test "$danger_failures" -gt 0
    set verdict BLOCK
    set reason "dangerjs: failures=$danger_failures"
end

# --- Output ---
echo "pr=$pr"
echo "head_sha=$head_sha"
echo "qodo=$qodo_state"
echo "qodo_action_required=$qodo_action"
echo "qodo_bugs=$qodo_bugs"
echo "qodo_violations=$qodo_violations"
echo "qodo_gaps=$qodo_gaps"
echo "dangerjs=$danger_state"
echo "dangerjs_failures=$danger_failures"
echo "dangerjs_warnings=$danger_warnings"
echo "verdict=$verdict"
test -n "$reason"; and echo "reason=$reason"

switch $verdict
    case BLOCK
        exit 1
    case WAIT
        exit 2
    case '*'
        exit 0
end
