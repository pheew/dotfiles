#!/usr/bin/env bash
# hook-comment-gate.sh — PreToolUse hook: block direct PR-comment writes.
#
# Active ONLY when BOTCTL_COMMENT_GATE=1 is set in the session env (renovate
# bots set it via their BOT.md `env:` block; interactive sessions never do).
# Blocked Bash commands must go through ~/.claude/scripts/renovate-pr-status.sh,
# which upserts a single marker-tagged status comment per PR.
#
# Hook contract: stdin = {"tool_name": "Bash", "tool_input": {"command": ...}};
# exit 0 allows the call, exit 2 blocks it and feeds stderr back to the model.

set -uo pipefail

[ "${BOTCTL_COMMENT_GATE:-0}" = "1" ] || exit 0

INPUT=$(cat)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT")
[ "$TOOL" = "Bash" ] || exit 0
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
[ -n "$CMD" ] || exit 0

BLOCK=0

# `gh pr comment` is always a write.
if grep -qE '(^|[;&|[:space:]])gh[[:space:]]+pr[[:space:]]+comment([[:space:]]|$)' <<<"$CMD"; then
    BLOCK=1
fi

# `gh api ...comments...` only when combined with a write indicator — GET reads
# of comment threads (quality gate, reconcile checks) stay allowed.
if [ "$BLOCK" -eq 0 ] && grep -qE 'gh[[:space:]]+api[[:space:]][^;|&]*comments' <<<"$CMD"; then
    if grep -qE '(-X|--method)[[:space:]=]*(POST|PATCH|PUT|DELETE)|(^|[[:space:]])(-f|-F|--field|--raw-field|--input)([[:space:]]|=)' <<<"$CMD"; then
        BLOCK=1
    fi
fi

# GraphQL comment mutation.
if [ "$BLOCK" -eq 0 ] && grep -qE 'gh[[:space:]]+api[[:space:]]+graphql' <<<"$CMD" && grep -q 'addComment' <<<"$CMD"; then
    BLOCK=1
fi

if [ "$BLOCK" -eq 1 ]; then
    cat >&2 <<'EOF'
BLOCKED by comment gate (BOTCTL_COMMENT_GATE=1): direct PR-comment writes are not allowed in this bot.
Post or refresh the status comment via the wrapper instead:
  ~/.claude/scripts/renovate-pr-status.sh <owner/repo> <pr> <verdict> <reason> <body-file>
It prepends the state marker, edits the existing comment in place, and NOOPs when nothing changed.
See the merge-renovate SKILL.md "Comment Discipline" section.
EOF
    exit 2
fi

exit 0
