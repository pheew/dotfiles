---
name: herdr
description: "Control Herdr: the Herdr desktop app (herdr-app, with herdr-core `hc`) or the older Herdr terminal multiplexer (TUI). Use only when the user explicitly mentions Herdr, herdr-app or hc, or asks to use Herdr to inspect or control spaces, workspaces, tabs, panes, terminals, keys, layouts, mods or another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work."
---

# Herdr

Two programs carry the Herdr name. Each one prints its own current manual.
Those manuals are the authority. This file only picks the right one.

## 1. Find out where you run

```bash
printf 'HERDR_ENV=%s HC_TERMINAL_ID=%s\n' "${HERDR_ENV:-}" "${HC_TERMINAL_ID:-}"
```

| Result | You run in | Read |
|---|---|---|
| `HERDR_ENV=1` | a pane of the Herdr TUI | `herdr --skill` |
| `HC_TERMINAL_ID` set, `HERDR_ENV` empty | a terminal of the Herdr desktop app | `herdr-app --skill` and `hc --skill` |
| both empty | not inside Herdr | see step 3 |

If both are set, the TUI runs inside an app terminal. The TUI owns your pane:
use `herdr --skill`. Change the outer app window only when the user asks.

## 2. Read the manual, then act

Skip a manual that is already in your context. Otherwise run the command from
the table before your first Herdr command, and follow what it prints.

- **Herdr desktop app:** `herdr-app --skill` covers the window: spaces, tabs,
  panes, keys, layouts and mods. `hc --skill` covers terminals and agents:
  start, read, send to, wait for and clean up. The app guide points to
  `~/.config/herdr-app/AGENTS.md` for keys, layouts and mods.
  Do not use the `herdr` CLI here. It belongs to the TUI, and bare `herdr`
  launches the TUI.
- **Herdr TUI:** `herdr --skill`. Do not run bare `herdr` for discovery: it
  launches or attaches the TUI.

## 3. Not inside Herdr

Say that this session does not run inside Herdr. Stop, unless the user asks
you to look at or change the Herdr desktop app window. `herdr-app ls` and
`herdr-app status` reach the running window from any terminal; read
`herdr-app --skill` first.
