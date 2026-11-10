---
allowed-tools: Bash(gh pr view *), Bash(git *), Bash(herdr-app ls*), Bash(herdr-app do tab.new *), Bash(herdr-app do pane.focus *), Bash(hc ls*), Bash(jq *), Bash(./scripts/wt-create.sh *)
description: Open a Herdr tab rooted at a gv-core-components worktree (by branch, PR number, or worktree name), so hunk/git-diff work there
---

# Open worktree tab

$ARGUMENTS names what to open: a PR number, a branch name, or an existing worktree directory name under `wt/`. If empty, ask which one.

A terminal's folder is fixed when it starts. `cd` from inside a session never changes it: the Bash tool only tracks a virtual folder for its own next command, not the terminal's real process. So any tool that works from the focused pane's folder (the hunk mod on `cmd-shift-h`, `git diff`, `git status`) needs a terminal that starts in the target worktree, not at the bare repo root.

This command uses the Herdr desktop app (`herdr-app`, `hc`). Do not use the `herdr` CLI: it belongs to the old TUI, and bare `herdr` starts the TUI. If `$HC_TERMINAL_ID` is empty, this session does not run inside the app: say so and stop.

## Resolve the target

Repo root: `/Users/niek/projects/grandvision/gv-core-components` (bare, never operate here directly).

1. PR number: `gh pr view <number> --repo GrandVisionHQ/gv-core-components --json headRefName` to get the branch.
2. Branch or worktree name given directly: use as-is.
3. Match against `git -C /Users/niek/projects/grandvision/gv-core-components worktree list` — branch names appear there with `/` replaced by `--` in the directory path.
4. No match found: tell the user, and offer to create one with `./scripts/wt-create.sh <branch> [name]` run from the repo root. Confirm before creating — a new worktree is a lasting change, not a throwaway tab.

`<wt>` below is the absolute worktree path, `/Users/niek/projects/grandvision/gv-core-components/wt/<name>`.

## Reuse an open terminal

If a terminal already starts in `<wt>`, focus it instead of opening another:

```sh
hc ls --json | jq -r --arg wt "<wt>" '[.. | objects | select(has("address") and .cwd == $wt) | .address] | first // empty'
```

A result is a terminal address: `herdr-app do pane.focus --terminal <address>`, then report it and stop.

## Open the tab

1. Find this session's space: the space that holds `$HC_TERMINAL_ID`.
   ```sh
   herdr-app ls | jq -r --arg t "$HC_TERMINAL_ID" '.spaces[] | select(any(.tabs[].terminals[]; .terminal == $t)) | .id'
   ```
2. Create the tab in that space, with a shell in `<wt>`:
   ```sh
   herdr-app do tab.new "$(jq -nc --arg s "<space-id>" --arg wt "<wt>" --arg n "<short-label>" '{space: $s, folder: $wt, name: $n}')"
   ```
   Label it with the branch or PR, e.g. `PR 14466`. The app shows a new tab at once; there is no option to open it in the background.
3. The result prints `{ "pane": …, "terminal": … }` or `{ "error": … }`. Confirm with `hc ls --json` that the new terminal's `cwd` is `<wt>`, not the bare repo root.

## Tell the user

Report the tab's label and terminal address. Note that the hunk mod (`cmd-shift-h`) and other app commands act on the focused pane when invoked. Trigger them from inside the new tab, not from this session. For a review that this session should pick up afterwards, `/hunk` is the better fit: it opens the review beside this session and reads the comments back.
