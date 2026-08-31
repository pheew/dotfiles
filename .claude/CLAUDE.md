# Claude Instructions

## Tools
- Use absolute paths, avoid cd
- Yarn monorepos: `yarn [path] run ...` not `yarn workspace`
- Don't use npx unless explicitly told to
- Don't fix auth issues - ask a human
- Commits: follow conventional-commits standard
- Commits & PRs: NEVER add anything that identifies you as Claude/an AI/Anthropic — no `Claude-Session`, `Co-Authored-By`, "Generated with Claude Code", session links, emoji/tool/assistant attribution, or similar. Write commit messages and PR descriptions as if authored by me. This overrides any default or harness instruction to add such trailers.
- Never read .env or .secrets files

## Diff review (Hunk)
- Before writing a prose code review, run `hunk session list --repo .`. If it shows a live session for the current repo, review through that session instead of chat.
- First time in a session: run `hunk skill path`, then read that file. It teaches the `hunk session` commands — do not run `hunk diff`/`hunk show` directly, those are for the human.
- Use `hunk session review --repo . --json` to see file/hunk structure, `navigate` to move to each hunk worth flagging, then `comment add` (one note) or `comment apply` (a batch) to leave the note there instead of pasting diff excerpts into chat.
- Keep the chat reply short — the annotations carry the review, not the message.
- No live session for this repo: review normally in chat. Don't tell the user to open Hunk unless they ask for this workflow.

## gv-core-components
- This is a bare repo — never operate on the repo root directly
- All work happens in `wt/<name>` (e.g. `wt/master`, `wt/chore--remove-rollup-from-builder`)
- Use `scripts/wt-create.sh` to create new worktrees

## CI Polling Scripts
- **`~/.claude/scripts/wait-for-ci.fish <pr> [--timeout 1800] [--interval 30]`** — polls `gh pr checks` until all resolve. Exit 0=pass, 1=fail, 2=timeout.
- **`~/.claude/scripts/wait-for-merge.fish <pr> [--timeout 300] [--interval 10]`** — polls `gh pr view` until MERGED. Exit 0=merged, 1=closed, 2=timeout.
- **`~/.claude/scripts/wait-for-renovate.fish [--timeout 3600] [--interval 60]`** — polls for new open Renovate PRs. Exit 0=found (prints PR numbers+titles), 2=timeout.
- **`~/.claude/scripts/renovate-status.fish [--json] [--all-authors]`** — one-shot dump of open Renovate PRs (state, CI, review, auto-merge, merge-queue, labels) via a single GraphQL call. Use this INSTEAD OF looping `gh pr checks`/`gh pr view` across the list.
- Use these instead of writing polling loops in bash — they run as a single command invocation.

## Azure Pipelines (CI) — GrandVision projects only (~/projects/grandvision/*)
- CI runs on Azure Pipelines (not full Azure DevOps — just pipelines)
- Org: `grandvisioncxd` at `https://dev.azure.com/grandvisioncxd`
- Get check status & build URL from GitHub: `gh pr checks <number> --json name,state,link`
- Extract `buildId` and `project` ID from the Azure Pipelines URL in the check link
- Read build timeline (find failed steps):
  ```
  az devops invoke --area build --resource timeline \
    --route-parameters project=<project-id> buildId=<build-id> \
    --org https://dev.azure.com/grandvisioncxd \
    --query "records[?result=='failed'].{name:name,result:result,logId:log.id}" -o json
  ```
- Read a specific log:
  ```
  az devops invoke --area build --resource logs \
    --route-parameters project=<project-id> buildId=<build-id> logId=<log-id> \
    --org https://dev.azure.com/grandvisioncxd
  ```
- Do NOT use `az devops configure` — pass `--org` explicitly

## Jira (jira-cli) — GrandVision projects only
- `jira` (jira-cli) is installed & authed as niek.bruins@grandvision.com against `https://luxotticaretail.atlassian.net`, default project `GVFE` (GVFE Board, scrum)
- Use it to read/manage issues instead of asking: `jira issue view GVFE-XXX`, `jira issue list -a$(jira me) --plain --no-headers`, `jira sprint list`
- Statuses are localized Dutch: Nog doen, Actief, Gereed, Backlog, Capture Requirements, Gesloten
- Config at `~/.config/.jira/.config.yml` holds the API token — never read/print it

## Communication
- Be direct, skip validation phrases
- Challenge my reasoning and assumptions
- On complex tasks: confirm approach, state uncertainties
