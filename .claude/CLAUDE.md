# Claude Instructions

## Tools
- Use absolute paths, avoid cd
- Yarn monorepos: `yarn [path] run ...` not `yarn workspace`
- Don't use npx unless explicitly told to
- Don't fix auth issues - ask a human
- Commits: follow conventional-commits standard
- Never read .env or .secrets files

## gv-core-components
- This is a bare repo — never operate on the repo root directly
- All work happens in `wt/<name>` (e.g. `wt/master`, `wt/chore--remove-rollup-from-builder`)
- Use `scripts/wt-create.sh` to create new worktrees

## CI Polling Scripts
- **`~/.claude/scripts/wait-for-ci.fish <pr> [--timeout 1800] [--interval 30]`** — polls `gh pr checks` until all resolve. Exit 0=pass, 1=fail, 2=timeout.
- **`~/.claude/scripts/wait-for-merge.fish <pr> [--timeout 300] [--interval 10]`** — polls `gh pr view` until MERGED. Exit 0=merged, 1=closed, 2=timeout.
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

## Communication
- Be direct, skip validation phrases
- Challenge my reasoning and assumptions
- On complex tasks: confirm approach, state uncertainties
