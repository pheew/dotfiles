#!/usr/bin/env bash
# renovate-pr-status.sh — single upserted status comment per Renovate PR.
#
# The merge-renovate bots must not write PR comments directly: post-per-wake
# produced 80-comment threads (gv-core #13840). This script owns the ONE status
# comment a bot keeps per PR and the local state that makes re-wakes cheap.
#
# Usage:
#   renovate-pr-status.sh <owner/repo> <pr> <verdict> <reason> <body-file> [--dry-run]
#   renovate-pr-status.sh <owner/repo> --dump
#
#   verdict    BLOCK | WAIT | INFO
#   reason     lowercase-hyphenated bucket (quality-hold, failed-to-fix,
#              flake-turned-deterministic, merge-conflicts-unresolvable,
#              registry-quarantine, auto-merged, ...)
#   body-file  human-readable markdown. The state-marker line is prepended by
#              this script — never include one in the body yourself.
#
# Behaviour:
#   unchanged sha+verdict+reason+body  -> prints "NOOP", no API write, exit 0
#   owned comment exists               -> edited in place (PATCH)
#   no owned comment                   -> posted once, id recorded in state
#
# State: $RENOVATE_STATE_FILE, default
#   ~/.botctl/state/renovate-pr-status/<owner>__<repo>.json
# If state is lost, the newest existing comment starting with the marker is
# adopted (one extra API read) before anything is posted, so a wiped state file
# costs at most one duplicate comment ever.

set -euo pipefail

die() {
    echo "renovate-pr-status: $*" >&2
    exit 3
}

[ $# -ge 2 ] || die "usage: renovate-pr-status.sh <owner/repo> <pr> <verdict> <reason> <body-file> [--dry-run] | <owner/repo> --dump"

REPO=$1
case "$REPO" in
    */*) ;;
    *) die "first arg must be <owner/repo>, got '$REPO'" ;;
esac

STATE_FILE="${RENOVATE_STATE_FILE:-$HOME/.botctl/state/renovate-pr-status/${REPO%%/*}__${REPO##*/}.json}"
mkdir -p "$(dirname "$STATE_FILE")"
[ -s "$STATE_FILE" ] || echo '{}' >"$STATE_FILE"

if [ "$2" = "--dump" ]; then
    echo "# state: $STATE_FILE"
    jq -r 'to_entries[] | "#\(.key)\tsha:\(.value.sha)\tverdict:\(.value.verdict)\treason:\(.value.reason)\tcomment:\(.value.comment_id // "-")\tupdated:\(.value.updated)"' "$STATE_FILE"
    exit 0
fi

[ $# -ge 5 ] || die "need <owner/repo> <pr> <verdict> <reason> <body-file>"
PR=$2 VERDICT=$3 REASON=$4 BODY_FILE=$5
DRY_RUN=${6:-}
case "$PR" in
    *[!0-9]*) die "pr must be numeric, got '$PR'" ;;
esac
[ -f "$BODY_FILE" ] || die "body file not found: $BODY_FILE"
if head -1 "$BODY_FILE" | grep -q '^<!-- renovate-bot:state'; then
    die "body file already contains a marker line — the script prepends it; remove yours"
fi

HEAD_SHA=$(gh pr view "$PR" --repo "$REPO" --json headRefOid --jq '.headRefOid[0:7]') || die "could not fetch head SHA for $REPO#$PR"
BODY_HASH=$(shasum -a 256 "$BODY_FILE" | awk '{print substr($1,1,16)}')
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

ENTRY=$(jq --arg pr "$PR" '.[$pr] // empty' "$STATE_FILE")
if [ -n "$ENTRY" ]; then
    P_SHA=$(jq -r '.sha' <<<"$ENTRY")
    P_VERDICT=$(jq -r '.verdict' <<<"$ENTRY")
    P_REASON=$(jq -r '.reason' <<<"$ENTRY")
    P_HASH=$(jq -r '.body_hash' <<<"$ENTRY")
    COMMENT_ID=$(jq -r '.comment_id // empty' <<<"$ENTRY")
    if [ "$P_SHA" = "$HEAD_SHA" ] && [ "$P_VERDICT" = "$VERDICT" ] && [ "$P_REASON" = "$REASON" ] && [ "$P_HASH" = "$BODY_HASH" ]; then
        echo "NOOP: $REPO#$PR unchanged (sha=$HEAD_SHA verdict=$VERDICT reason=$REASON) — nothing posted"
        exit 0
    fi
else
    COMMENT_ID=""
fi

# State lost or first contact: adopt the newest marker comment if one exists,
# so we PATCH it instead of adding to the pile.
if [ -z "$COMMENT_ID" ]; then
    COMMENT_ID=$(gh api "repos/$REPO/issues/$PR/comments" --paginate \
        --jq '[.[] | select(.body | startswith("<!-- renovate-bot:state"))] | (last // empty) | .id' 2>/dev/null || true)
fi

MARKER="<!-- renovate-bot:state v=2 sha=$HEAD_SHA verdict=$VERDICT reason=$REASON ts=$NOW -->"
FULL_BODY=$(mktemp)
trap 'rm -f "$FULL_BODY"' EXIT
{
    echo "$MARKER"
    echo
    cat "$BODY_FILE"
} >"$FULL_BODY"

if [ "$DRY_RUN" = "--dry-run" ]; then
    if [ -n "$COMMENT_ID" ]; then
        echo "DRY-RUN: would UPDATE comment $COMMENT_ID on $REPO#$PR (sha=$HEAD_SHA verdict=$VERDICT reason=$REASON)"
    else
        echo "DRY-RUN: would POST new comment on $REPO#$PR (sha=$HEAD_SHA verdict=$VERDICT reason=$REASON)"
    fi
    exit 0
fi

PAYLOAD=$(mktemp)
trap 'rm -f "$FULL_BODY" "$PAYLOAD"' EXIT
jq -n --rawfile body "$FULL_BODY" '{body: $body}' >"$PAYLOAD"

ACTION=""
if [ -n "$COMMENT_ID" ]; then
    if gh api -X PATCH "repos/$REPO/issues/comments/$COMMENT_ID" --input "$PAYLOAD" --jq '.id' >/dev/null 2>&1; then
        ACTION="UPDATED comment $COMMENT_ID"
    else
        COMMENT_ID="" # comment deleted or not editable — fall through to POST
    fi
fi
if [ -z "$COMMENT_ID" ]; then
    COMMENT_ID=$(gh api "repos/$REPO/issues/$PR/comments" --input "$PAYLOAD" --jq '.id') || die "failed to post comment on $REPO#$PR"
    ACTION="POSTED comment $COMMENT_ID"
fi

jq --arg pr "$PR" --arg sha "$HEAD_SHA" --arg v "$VERDICT" --arg r "$REASON" \
    --arg h "$BODY_HASH" --arg ts "$NOW" --argjson id "$COMMENT_ID" \
    '.[$pr] = {sha: $sha, verdict: $v, reason: $r, body_hash: $h, comment_id: $id, updated: $ts}' \
    "$STATE_FILE" >"$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

echo "$ACTION on $REPO#$PR (sha=$HEAD_SHA verdict=$VERDICT reason=$REASON)"
