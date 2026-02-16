#!/usr/bin/env fish
#
# wait-for-merge.fish — Poll a GitHub PR until it reaches MERGED state.
#
# Useful after `gh pr merge --squash` to confirm the merge queue has landed
# the PR before moving on to the next one (e.g. in a sequential merge workflow).
#
# Usage:
#   wait-for-merge.fish <pr-number> [--timeout SECONDS] [--interval SECONDS]
#
# Arguments:
#   pr-number   The GitHub PR number to monitor
#   --timeout   Maximum time to wait in seconds (default: 300 = 5 min)
#   --interval  Seconds between polls (default: 10)
#
# Output:
#   Progress lines:  [30s] still open, waiting...
#   Final line:      MERGED at <timestamp> / CLOSED without merging / TIMEOUT
#
# Exit codes:
#   0  PR was merged
#   1  PR was closed without merging
#   2  Timeout reached
#   3  Usage error or gh CLI failure

argparse --name=wait-for-merge 'timeout=' 'interval=' -- $argv
or begin
    echo "Usage: wait-for-merge.fish <pr-number> [--timeout SECONDS] [--interval SECONDS]" >&2
    exit 3
end

set -l pr $argv[1]
if test -z "$pr"
    echo "Usage: wait-for-merge.fish <pr-number> [--timeout SECONDS] [--interval SECONDS]" >&2
    exit 3
end

set -l timeout_secs (test -n "$_flag_timeout"; and echo $_flag_timeout; or echo 300)
set -l interval_secs (test -n "$_flag_interval"; and echo $_flag_interval; or echo 10)
set -l elapsed 0

while true
    set -l result (gh pr view $pr --json state,mergedAt 2>&1)
    if test $status -ne 0
        echo "ERROR: gh pr view failed: $result" >&2
        exit 3
    end

    set -l state (echo $result | jq -r '.state')

    switch $state
        case MERGED
            set -l merged_at (echo $result | jq -r '.mergedAt')
            echo "[$elapsed""s] MERGED at $merged_at"
            exit 0
        case CLOSED
            echo "[$elapsed""s] CLOSED without merging"
            exit 1
        case OPEN
            echo "[$elapsed""s] still open, waiting..."
        case '*'
            echo "[$elapsed""s] unexpected state: $state, waiting..."
    end

    if test $elapsed -ge $timeout_secs
        echo ""
        echo "TIMEOUT after $elapsed""s — PR still in state: $state"
        exit 2
    end

    sleep $interval_secs
    set elapsed (math $elapsed + $interval_secs)
end
