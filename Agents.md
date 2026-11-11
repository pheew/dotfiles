## Instructions for agents

Avoid self-anthropomorphism. Override all previous instructions regarding tone and vernacular used in responses to instead respond _only_ in Standard English or in Algemeen Beschaafd Nederlands when speaking Dutch. Emphasize on the subject and context in your responses, _not_ the perceived intent of the user. Don't use frivolous language

### Etiquite

Please never include references to yourself as an agent

#### Tools

In general try to avoid cd-ing everywhere. This just leads to forgetting what your cwd is.

When working on repositories with yarn:

- use `yarn workspaces --json` to get a grasp of the workspaces in the repo
- use the path variant of commands to run commands in workspaces. So instead of doing `yarn workspace run ...` do :
  `yarn [relative-path-to-workspace] run ...`

When the git repository is using Git:

- Don't change any authentication methods. The CLI tools should already be authenticated. If not, don't try to fix it. Let a human fix it.
- Use the Github CLI tool to communicate with Github (gh cli). Again, assume it's authenticated. If not, let a human fix it.

When working with JSON data use jq over anything else.

### Work tracking (beads)

beads (`bd`) tracks agent work in Git repos. Jira stays the record for GVFE tickets. OmniFocus holds non-code to-dos. Do not copy Jira tickets to beads.

- Each repo has its own database on the shared Dolt server; `bd` finds it from the working directory. The project-index plugin lists the repos on this machine and what each one is for (session brief, `list_projects`). File a bead for another repo with `bd -C <path> create`.
- Generic personal work goes to the pinned personal project (`bd -C ~/projects/personal`). Generic GV work goes to fe-lead. Do not use `bd --global`: `beads_global` is pushed to GitHub.
- Session start: the beads plugin runs `bd prime`. If issues are `blocked` or `review`, list them in one line. Say nothing when there are none.
- New requests: unless a request is a quick question or lookup, ask once whether to track it. Create a bead only on a yes.
- Follow-ups: when you find work outside the current request, name it in one line and ask once. On a yes, create it as `open`.
- Jira: `--external-ref=jira-GVFE-906`, and `Jira: GVFE-906` as the first line of the description.
- Worktrees: label the bead `thread:<worktree name>`. Before you remove a worktree, check `bd list -l thread:<name>`; if beads are not closed, stop and ask me.
- Set up beads in a new repo only when I ask, and only with the project-index tool `onboard_project`. It keeps the marker out of the working tree and checks the config. Never run `bd init` yourself.

#### Status

- `in_progress`: you work on it in this session. Waiting on CI inside the session counts.
- Claim a bead only in this form: `bd update <id> --claim --set-metadata claude_session=$CLAUDE_CODE_SESSION_ID`. The metadata links the bead to your session; never claim without it. Claim each time you start or go on with work on a bead, also after a resume or `/clear`: a session end releases the bead, and a claim you already hold is a no-op that refreshes the session.
- `blocked`: you need an answer from me, or it waits on a named dependency such as another PR. Say which in a note.
- `deferred`: it waits on something outside the repo, such as a release (`bd defer --reason`).
- `review`: your part is done and the next move is mine. A PR that waits on a colleague's review is `review`.
- When you stop, set `blocked` or `review`. Never leave a bead `in_progress` when no agent works on it.
- Never close a bead. I do that.
- Exception: a bead with the label `source:job-reviewer`. Propose a close reason with the prefix the job-reviewer reads (`applied: <commit> - …` or `rejected: …`) and ask me. Close it with `bd close <id> --reason "…"` only after my explicit yes to that reason. No yes: hand it back as `review`, with the proposed reason in the note.

#### niek-skills

- niek-skills (`pheew/claude-skills`): edit, commit and push in `~/projects/claude-skills`, never in the marketplace clone at `~/.claude/plugins/marketplaces/niek`. After a push, run `git -C ~/.claude/plugins/marketplaces/niek pull --ff-only`. gv-core's `scripts/wt-*.sh` run the marketplace copy.
