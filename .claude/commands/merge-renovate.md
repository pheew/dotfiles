---
allowed-tools: Bash(gh *), Bash(git *), Bash(az devops *), Bash(yarn *), Bash(~/.claude/scripts/wait-for-ci.fish *), Bash(~/.claude/scripts/wait-for-merge.fish *), Bash(~/.claude/scripts/wait-for-renovate.fish *), Bash(~/.claude/scripts/renovate-status.fish *)
description: Triage, prepare, and merge open Renovate dependency PRs
---

# Merge Renovate PRs

Process all open Renovate dependency PRs on this repository. Every PR gets a verdict: **merge** or **close**. No PR is left open without a decision.

## Helper Scripts

These scripts handle CI polling automatically (no manual approval per loop iteration):

- **`~/.claude/scripts/wait-for-ci.fish <pr> [--timeout 1800] [--interval 30]`**
  Polls `gh pr checks` until all checks resolve. Exits 0 if all pass, 1 if any fail, 2 on timeout.

- **`~/.claude/scripts/wait-for-merge.fish <pr> [--timeout 300] [--interval 10]`**
  Polls `gh pr view` until PR state is MERGED. Exits 0 on merge, 1 if closed without merge, 2 on timeout.

- **`~/.claude/scripts/wait-for-renovate.fish [--timeout 1200] [--interval 60] [--ignore PR_NUMBER...]`**
  Polls for new open Renovate PRs. Exits 0 if found (prints PR numbers+titles), 2 on timeout.
  **Important**: When existing Renovate PRs are already open, pass `--ignore <number>` for each one so the script only triggers on *new* PRs.

**No sleep, no polling loops.** Do NOT use `sleep` commands or write bash loops to poll GitHub. If you need to wait for a condition, use one of the scripts above. Small `sleep N; gh pr view` idioms are also forbidden — just run the check directly.

## Phase 1: Inventory & Prioritize

1. Read the **Renovate Dependency Dashboard** issue to get the full picture (open PRs, rate-limited, blocked, deprecations, repo problems):
   - Find it: `gh issue list --search "Dependency Dashboard in:title" --state open --json number,title --jq '.[0].number'`
   - Read it: `gh issue view <number> --json body`
   - Summarize any relevant context from the dashboard (problems, blocked PRs, deprecations)

2. List all open Renovate PRs with full status in one call:
   - `~/.claude/scripts/renovate-status.fish`
   (This returns CI state, review decision, auto-merge, merge-queue, and labels for all PRs via a single GraphQL call — do NOT loop `gh pr checks` per PR)

3. Classify each PR:
   - **Security**: title contains `[security]`
   - **Patch**: title contains `(patch)` or version bump is patch-level
   - **Minor**: minor version bump
   - **Major**: major version bump

4. Sort by priority: security > patch > minor > major. Tiebreaker: passing CI ranks higher than failing/pending CI.

5. Present a summary table to the user:

   | # | PR | Update | Type | CI | Size |
   |---|-----|--------|------|----|------|

### If no open PRs exist

1. Wait up to 20 minutes for Renovate to open new PRs (pass `--ignore` for each already-open Renovate PR):
   `~/.claude/scripts/wait-for-renovate.fish --timeout 1200 --interval 60 --ignore <existing_pr>...`
2. If new PRs appear (exit 0), loop back to step 2 above to list and classify them.
3. If the wait times out (exit 2), fall back to the **Dependency Dashboard** issue body (already fetched in step 1). Pick a rate-limited PR to force-create by checking its checkbox via a GitHub issue body edit. Use these priority rules:
   - **Security** updates first
   - **Patch** updates next (low-risk, high-value)
   - **Minor** updates after that
   - **Major** updates last (highest risk)
   - Within the same tier, prefer updates that affect fewer packages (smaller blast radius)
4. After checking the checkbox, wait for Renovate to create the PR (pass `--ignore` for each already-open Renovate PR):
   `~/.claude/scripts/wait-for-renovate.fish --timeout 600 --interval 30 --ignore <existing_pr>...`
5. Once the PR appears, loop back to step 2 to list and classify it.

## Phase 2: Triage

For each PR in priority order:

1. Read the full PR description — Renovate includes release notes, changelogs, and **breaking change warnings** in the body:
   - `gh pr view <number> --json body,title,additions,deletions,files`
2. Summarize for the user:
   - What packages are changing and from which version to which
   - Any breaking changes, deprecations, or migration notes from the changelog
   - Diff size and files touched
3. Ask the user: **merge** or **close**?
4. If **close**: ask for a brief reason, then `gh pr close <number> --comment "<reason>"`

After triaging all PRs, confirm the merge queue order with the user before proceeding.

## Phase 3: Prepare

For the first PR in the merge queue:

1. Check CI status: `gh pr checks <number> --json name,state,link`
2. Check mergeability: `gh pr view <number> --json mergeable,mergeStateStatus`

### If CI is red

Extract the Azure Pipelines build ID from the check URL and investigate:

1. Get check links: `gh pr checks <number> --json name,state,link`
2. Extract `buildId` from the Azure Pipelines URL
3. Read build timeline to find failed steps:
   ```
   az devops invoke --area build --resource timeline \
     --route-parameters project=<project-id> buildId=<build-id> \
     --org https://dev.azure.com/<org> \
     --query "records[?result=='failed'].{name:name,result:result,logId:log.id}" -o json
   ```
4. Read the failed step's log to understand the error:
   ```
   az devops invoke --area build --resource logs \
     --route-parameters project=<project-id> buildId=<build-id> logId=<log-id> \
     --org https://dev.azure.com/<org>
   ```
5. **Fix the issue**: check out the branch, read the relevant source code, apply fixes (type errors, API changes, config updates), commit, and push. If the fix is non-trivial, escalate to the user.

### If there are merge conflicts

1. Check out the PR branch
2. Rebase on the main branch
3. **Lock file conflicts**: do NOT manually resolve `yarn.lock` conflicts. Instead:
   - Accept the main branch version: `git checkout --theirs yarn.lock`
   - Continue the rebase: `git rebase --continue`
   - Run `yarn install` to regenerate the lock file with the PR's changes on top
   - Amend the commit: `git add yarn.lock && git commit --amend --no-edit`
4. Fix any other conflicts in source files
5. Force-push the rebased branch

### If breaking changes are indicated

Read the affected source code and apply necessary fixes (API changes, type updates, import changes). Commit and push to the PR branch.

After pushing fixes, wait for CI: `~/.claude/scripts/wait-for-ci.fish <number>`

**Goal**: PR has green CI and no merge conflicts.

## Phase 4: Merge

1. Enqueue the PR via GitHub's merge queue: `gh pr merge --squash --auto <number>`
   **Critical**: do NOT use `--admin` — it bypasses branch protections and review requirements.
2. Wait until merged: `~/.claude/scripts/wait-for-merge.fish <number>`
3. Confirm the merge to the user

**Critical**: only ONE Renovate PR may be in the merge queue at a time. Do not merge the next PR until the current one has fully landed on the main branch. This leaves space for other (non-Renovate) PRs in the merge queue.

## Phase 5: Prepare-ahead

While the current PR is merging (or immediately after it lands):

1. Take the next PR from the queue
2. Pull the latest main branch (which now includes the previous merge)
3. Rebase the next PR's branch on main
4. **Lock file handling**: after a prior dependency merge, the lock file will almost certainly conflict. Follow the same lock file procedure from Phase 3: accept main's version, run `yarn install`, amend
5. Fix any other conflicts from the prior merge
6. Force-push the rebased branch
7. Wait for CI: `~/.claude/scripts/wait-for-ci.fish <number>`

Once the previous merge has landed AND this PR is ready (CI green, no conflicts), loop back to Phase 4.

Repeat until the queue is empty.

## Completion

When all PRs have been processed, report:
- How many PRs were merged
- How many PRs were closed (with reasons)
- Any remaining issues or follow-ups
