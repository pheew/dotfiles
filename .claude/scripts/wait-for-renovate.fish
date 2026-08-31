#!/usr/bin/env fish
#
# wait-for-renovate.fish — Poll for new open Renovate PRs on the current repo.
#
# Watches for PRs authored by renovate-bot-service. Exits as soon as one or
# more new PRs appear, printing their numbers and titles.
#
# Usage:
#   wait-for-renovate.fish [--timeout SECONDS] [--interval SECONDS] [--ignore PR_NUMBER...]
#
# Options:
#   --timeout   Maximum time to wait in seconds (default: 3600 = 1 hour)
#   --interval  Seconds between polls (default: 60)
#   --ignore    PR numbers to exclude from results (repeatable)
#
# Output:
#   Progress lines:  [60s] no new Renovate PRs (0 open)
#   Final lines:     FOUND 2 Renovate PR(s): ...
#
# Exit codes:
#   0  One or more Renovate PRs found
#   2  Timeout reached with no PRs appearing
#   3  Usage error or gh CLI failure

set -x CLICOLOR_FORCE 0

argparse --name=wait-for-renovate 'timeout=' 'interval=' 'ignore=+' -- $argv
or begin
    echo "Usage: wait-for-renovate.fish [--timeout SECONDS] [--interval SECONDS] [--ignore PR...]" >&2
    exit 3
end

set -l timeout_secs (test -n "$_flag_timeout"; and echo $_flag_timeout; or echo 3600)
set -l interval_secs (test -n "$_flag_interval"; and echo $_flag_interval; or echo 60)
set -l elapsed 0

# Build jq filter to exclude ignored PR numbers
set -l jq_filter '.'
if set -q _flag_ignore
    set -l ignore_list (string join ',' $_flag_ignore)
    set jq_filter "[.[] | select(.number | IN($ignore_list) | not)]"
end

while true
    set -l result (gh pr list --search "author:app/renovate-bot-service" --state open --json number,title 2>&1)
    if test $status -ne 0
        echo "ERROR: gh pr list failed: $result" >&2
        exit 3
    end

    set -l filtered (echo $result | jq "$jq_filter")
    set -l count (echo $filtered | jq 'length')

    if test "$count" -gt 0
        echo ""
        echo "FOUND $count Renovate PR(s):"
        for row in (echo $filtered | jq -r '.[] | "  #\(.number) \(.title)"')
            echo $row
        end
        exit 0
    end

    set -l total (echo $result | jq 'length')
    echo "[$elapsed""s] no new Renovate PRs ($total open, $count after ignore filter)"

    if test $elapsed -ge $timeout_secs
        echo ""
        echo "TIMEOUT after $elapsed""s — no Renovate PRs appeared"
        exit 2
    end

    sleep $interval_secs
    set elapsed (math $elapsed + $interval_secs)
end
