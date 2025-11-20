## Instructions for agents


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

