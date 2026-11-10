---
allowed-tools: Bash(gh pr view *), Bash(git *), Bash(herdr *), Bash(./scripts/wt-create.sh *)
description: Open a herdr pane rooted at a gv-core-components worktree (by branch, PR number, or worktree name), so hunk/git-diff work there
---

# Open worktree pane

$ARGUMENTS names what to open: a PR number, a branch name, or an existing worktree directory name under `wt/`. If empty, ask which one.

A herdr pane's working directory is fixed at creation. `cd` from inside a session never changes it — the Bash tool only tracks a virtual cwd for its own next command, not the pane's real process. So any git-diff-based tool (hunk, `git diff`, `git status`) needs a pane whose actual cwd is the target worktree from the start, not the bare repo root.

## Resolve the target

Repo root: `/Users/niek/projects/grandvision/gv-core-components` (bare, never operate here directly).

1. PR number: `gh pr view <number> --repo GrandVisionHQ/gv-core-components --json headRefName` to get the branch.
2. Branch or worktree name given directly: use as-is.
3. Match against `git -C /Users/niek/projects/grandvision/gv-core-components worktree list` — branch names appear there with `/` replaced by `--` in the directory path.
4. No match found: tell the user, and offer to create one with `./scripts/wt-create.sh <branch> [name]` run from the repo root. Confirm before creating — a new worktree is a lasting change, not a throwaway pane.

## Open the pane

1. Find the current workspace id: `herdr agent list`, take the `workspace_id` of the focused pane. If ambiguous (working across multiple herdr workspaces), ask which one.
2. Create the tab:
   ```
   herdr tab create --workspace <workspace-id> --cwd "/Users/niek/projects/grandvision/gv-core-components/wt/<name>" --label "<short-label>" --no-focus
   ```
   `--no-focus` keeps this from stealing the screen. Label it with the branch or PR, e.g. `PR 14466`.
3. Confirm both `cwd` and `foreground_cwd` on the new pane match the worktree path (`herdr pane get <pane-id>`), not the bare repo root.

## Tell the user

Report the tab's label and id. Note that any herdr plugin action bound to a keybinding or the command palette — hunk's review action included — resolves its target from whichever pane is focused at the moment it's invoked. It has to be triggered from inside that new tab, not from this session.
