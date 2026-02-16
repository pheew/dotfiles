#!/usr/bin/env fish
#
# wait-for-ci.fish — Poll GitHub PR checks until all reach a terminal state.
#
# Usage:
#   wait-for-ci.fish <pr-number> [--timeout SECONDS] [--interval SECONDS]
#
# Arguments:
#   pr-number   The GitHub PR number to monitor
#   --timeout   Maximum time to wait in seconds (default: 1800 = 30 min)
#   --interval  Seconds between polls (default: 30)
#
# Output:
#   Progress lines:  [120s] checks: 2 passed, 0 failed, 1 pending (of 3)
#   Final summary:   PASSED / FAILED (with details) / TIMEOUT
#
# Exit codes:
#   0  All checks passed
#   1  One or more checks failed (names + links printed)
#   2  Timeout reached with checks still pending
#   3  Usage error or gh CLI failure

argparse --name=wait-for-ci 'timeout=' 'interval=' -- $argv
or begin
    echo "Usage: wait-for-ci.fish <pr-number> [--timeout SECONDS] [--interval SECONDS]" >&2
    exit 3
end

set -l pr $argv[1]
if test -z "$pr"
    echo "Usage: wait-for-ci.fish <pr-number> [--timeout SECONDS] [--interval SECONDS]" >&2
    exit 3
end

set -l timeout_secs (test -n "$_flag_timeout"; and echo $_flag_timeout; or echo 1800)
set -l interval_secs (test -n "$_flag_interval"; and echo $_flag_interval; or echo 30)
set -l elapsed 0

# Terminal check states grouped by outcome
set -l pending_states PENDING QUEUED IN_PROGRESS REQUESTED WAITING
set -l failure_states FAILURE ERROR CANCELLED STARTUP_FAILURE TIMED_OUT ACTION_REQUIRED STALE

while true
    # Fetch current check status
    set -l checks_json (gh pr checks $pr --json name,state,link 2>&1)
    if test $status -ne 0
        echo "ERROR: gh pr checks failed: $checks_json" >&2
        exit 3
    end

    set -l total (echo $checks_json | jq 'length')

    # No checks registered yet — keep waiting
    if test "$total" -eq 0
        echo "[$elapsed""s] No checks found yet, waiting..."
        sleep $interval_secs
        set elapsed (math $elapsed + $interval_secs)
        if test $elapsed -ge $timeout_secs
            echo "TIMEOUT after $elapsed""s — no checks ever appeared"
            exit 2
        end
        continue
    end

    # Tally check states
    set -l passed 0
    set -l failed 0
    set -l pending 0
    set -l failed_names
    set -l failed_links

    for row in (echo $checks_json | jq -r '.[] | "\(.name)\t\(.state)\t\(.link)"')
        set -l parts (string split \t $row)
        set -l name $parts[1]
        set -l state $parts[2]
        set -l link $parts[3]

        if contains -- $state $pending_states
            set pending (math $pending + 1)
        else if contains -- $state $failure_states
            set failed (math $failed + 1)
            set -a failed_names $name
            set -a failed_links $link
        else
            set passed (math $passed + 1)
        end
    end

    echo "[$elapsed""s] checks: $passed passed, $failed failed, $pending pending (of $total)"

    # All checks have resolved
    if test $pending -eq 0
        if test $failed -gt 0
            echo ""
            echo "FAILED — $failed check(s) failed:"
            for i in (seq (count $failed_names))
                echo "  - $failed_names[$i] ($failed_links[$i])"
            end
            exit 1
        else
            echo ""
            echo "PASSED — all $total check(s) green"
            exit 0
        end
    end

    # Still pending — check timeout then sleep
    if test $elapsed -ge $timeout_secs
        echo ""
        echo "TIMEOUT after $elapsed""s — $pending check(s) still pending"
        exit 2
    end

    sleep $interval_secs
    set elapsed (math $elapsed + $interval_secs)
end
