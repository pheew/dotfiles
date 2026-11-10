---
allowed-tools: Bash(herdr-app ls*), Bash(herdr-app do pane.split *), Bash(herdr-app do pane.focus *), Bash(hunk session *), Bash(git *), Bash(jq *)
description: Open a hunk review of your changes in a split beside this session, or pick up the review comments left in it
argument-hint: "[staged | commit | branch | working | done]"
---

# hunk review

$ARGUMENTS selects the diff: `branch`, `working`, `staged` or `commit`. Empty means auto. `done` means: read the comments now.

## 1. Find the folder

The folder is the git work tree of the current task. Not your process folder: in a bare-root layout (for example gv-core-components) the session starts at the bare root, and the work happens in `wt/<name>`.

- Use the worktree you created or worked in for this task.
- When the task spans several worktrees, or none is clear, ask which one. Do not guess.
- Confirm with `git -C <folder> rev-parse --show-toplevel`. The output is `<wt>` below.

## 2. Pick up comments first

Run `hunk session list --json` and find the session whose `repoRoot` is `<wt>`.

If that session exists, read the human comments:

```sh
hunk session comment list --repo <wt> --type user --json
```

- Comments present: work through each one (`filePath`, `newRange`/`oldRange`, `body`). Ask about a comment that needs a decision; handle the others. Remove each handled comment with `hunk session comment rm --repo <wt> <noteId> --json`. Then summarize what you changed and what you did not, and reload the review (step 4) so the person sees the result.
- No comments and `$ARGUMENTS` is `done`: say there are no comments, and stop.
- No comments otherwise: go on to step 3.

If no session exists and `$ARGUMENTS` is `done`: say no review is open for `<wt>`, and stop.

## 3. Choose the diff

| Argument | hunk arguments |
|---|---|
| `working` | `diff` |
| `staged` | `diff --staged` |
| `commit` | `show` |
| `branch` | `diff <base>...HEAD` |
| empty | `branch` when HEAD is ahead of `<base>` (`git -C <wt> rev-list --count <base>..HEAD` > 0), else `working` |

`<base>`, the first that applies:
1. The upstream (`git -C <wt> rev-parse --abbrev-ref --symbolic-full-name @{upstream}`), unless it is `<remote>/<current branch>`.
2. `git -C <wt> symbolic-ref --short refs/remotes/origin/HEAD`.
3. The first of `main`, `master`, `trunk` that exists.

No base for `branch`: say so, and use `working`.

## 4. Show it

**A session for `<wt>` exists:** re-point it, then focus its pane only if the person asked.

```sh
hunk session reload --repo <wt> --json -- <hunk arguments>
```

**No session:** this needs the Herdr desktop app. `$HC_TERMINAL_ID` empty means you do not run inside it: give the person `cd <wt> && hunk <hunk arguments>` to run, and stop.

Find your own pane, then split beside it. `pane.split` has no folder argument, so `argv` changes to `<wt>` first. The explicit `pane` puts the split beside you, wherever the person's focus is.

```sh
pane=$(herdr-app ls | jq -r --arg t "$HC_TERMINAL_ID" '.. | objects | select(.terminal? == $t) | .pane')
herdr-app do pane.split "$(jq -nc --arg p "$pane" --arg wt "<wt>" \
  '{direction: "right", pane: $p, argv: ["sh", "-c", "cd \"$1\" && exec hunk <hunk arguments>", "sh", $wt]}')"
```

The result prints `{ "pane": …, "terminal": … }` or `{ "error": … }`. Wait a few seconds, then confirm with `hunk session list --json` that a session with `repoRoot` `<wt>` exists.

## 5. Tell the person

One or two lines: which diff of which worktree is open. Say that they leave comments in hunk with `c`, then run `/hunk done` (or `/hunk` again) to hand them to you.
