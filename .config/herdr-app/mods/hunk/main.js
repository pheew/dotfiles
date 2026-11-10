import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, closeOverlay, exec, focused, hc, notify, panes, props, run, setShared, shared, spaces, theme } from "herdr";

// Review agent-authored changes in hunk and send your inline comments back to the agent.
// A port of the Herdr TUI plugin jhochenbaum/herdr-hunk-diff to a herdr-app popup.
//
// The popup stays open while an action runs: closing it cancels this view's tasks.

/** @typedef {import("gpui-kit").AsyncContext} AsyncContext */
/** @typedef {import("gpui-kit").Context} Context */
/** @typedef {import("gpui-kit").KeyEvent} KeyEvent */
/** @typedef {import("gpui-kit").Color} Color */
/** @typedef {import("herdr").AgentInfo} AgentInfo */
/** @typedef {NonNullable<ReturnType<typeof focused>>} Focus */
/** @typedef {"auto" | "working" | "staged" | "branch" | "commit"} Mode */
/** @typedef {[key: string, label: string, id: string]} Action */
/** @typedef {{ pane: string, terminal: string | null, agent: string | null, mode: Mode }} Review */
/** @typedef {{ mode: Mode, args: string[], warning: string | null }} Target */
/**
 * A note from `hunk session comment list --json`.
 * @typedef {{ noteId: string, filePath: string, body: string, newRange?: [number, number], oldRange?: [number, number] }} HunkComment
 */

const WATCH = false; // true: `hunk diff --watch` reloads the review when files change
const CLEAR_AFTER_SEND = true; // remove sent comments from hunk
const SENT_CAP = 500; // sent comment ids kept per repo, to block a double send
const PROMPT = `Human-authored inline review comments on your changes in {worktree}:

{comments}

Address each comment and verify the resulting changes. If a comment is unclear or requires a decision, ask a focused clarification question and continue with any unaffected comments. Then summarize what you changed and explain anything you did not implement.`;

/** @type {Action[]} */
const ACTIONS = [
  ["h", "Review changes (branch if ahead of base, else working tree)", "auto"],
  ["w", "Review the working tree", "working"],
  ["s", "Review staged changes", "staged"],
  ["b", "Review this branch against its base", "branch"],
  ["c", "Review the last commit", "commit"],
  ["enter", "Send review comments to the agent", "send"],
  ["n", "Go to the next comment", "next"],
  ["p", "Go to the previous comment", "prev"],
  ["x", "Close the review pane", "close"],
];

const REVIEWS = "hunk.reviews"; // { [repo]: Review }
const SENT = "hunk.sent"; // { [repo]: noteId[] }

class Failure extends Error {}

/**
 * @param {AsyncContext} cx
 * @param {number} ms
 * @returns {Promise<void>}
 */
function sleep(cx, ms) {
  return new Promise((resolve) => cx.timer.after(ms, () => resolve()));
}

/**
 * @param {string} cwd
 * @param {string[]} args
 * @returns {Promise<string | null>} trimmed stdout, or null when git fails
 */
async function git(cwd, args) {
  const r = await exec("git", ["-C", cwd, ...args]);
  return r.code === 0 ? r.stdout.trim() : null;
}

/**
 * @param {string[]} args
 * @returns {Promise<any>} the parsed `--json` output
 */
async function hunkJson(args) {
  const r = await exec("hunk", [...args, "--json"]);
  if (r.code !== 0) {
    const err = (r.stderr || r.stdout).trim();
    if (/No active Hunk sessions/i.test(err)) throw new Failure("No live hunk session for this repo. Open a review first.");
    throw new Failure(`hunk: ${err || `exit ${r.code}`}`);
  }
  return JSON.parse(r.stdout || "{}");
}

/**
 * The base for a branch review: the upstream (unless it is this branch's own remote
 * branch), then origin/HEAD, then main, master or trunk.
 * @param {string} repo
 * @returns {Promise<string | null>}
 */
async function resolveBase(repo) {
  const branch = await git(repo, ["branch", "--show-current"]);
  /** @param {string | null} ref */
  const usable = (ref) => ref && !(branch && ref.endsWith(`/${branch}`));
  const upstream = await git(repo, ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"]);
  if (usable(upstream)) return upstream;
  const head = await git(repo, ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"]);
  if (usable(head)) return head;
  for (const name of ["main", "master", "trunk"]) {
    if (await git(repo, ["rev-parse", "--verify", "--quiet", name])) return name;
  }
  return null;
}

/**
 * @param {string} repo
 * @param {string} base
 */
async function aheadOf(repo, base) {
  const n = await git(repo, ["rev-list", "--count", `${base}..HEAD`]);
  return Number.parseInt(n ?? "0", 10) > 0;
}

/**
 * hunk arguments for a mode; "auto" and "branch" resolve here.
 * @param {string} repo
 * @param {Mode} mode
 * @returns {Promise<Target>}
 */
async function hunkArgs(repo, mode) {
  let warning = null;
  if (mode === "auto" || mode === "branch") {
    const base = await resolveBase(repo);
    if (base && (mode === "branch" || (await aheadOf(repo, base)))) {
      return { mode: "branch", args: ["diff", `${base}...HEAD`], warning };
    }
    if (mode === "branch") warning = "No base branch found; showing the working tree.";
    mode = "working";
  }
  if (mode === "commit") return { mode, args: ["show"], warning };
  if (mode === "staged") return { mode, args: ["diff", "--staged", ...(WATCH ? ["--watch"] : [])], warning };
  return { mode: "working", args: ["diff", ...(WATCH ? ["--watch"] : [])], warning };
}

/** @returns {Record<string, Review>} */
function reviews() {
  return /** @type {Record<string, Review> | undefined} */ (shared(REVIEWS)) ?? {};
}

/**
 * The review pane for a repo, when it is still open.
 * @param {string} repo
 * @returns {Review | null}
 */
function reviewPane(repo) {
  const entry = reviews()[repo];
  return entry && panes().some((p) => p.pane === entry.pane) ? entry : null;
}

/**
 * @param {string | null} cwd
 * @param {string} repo
 */
function inside(cwd, repo) {
  return cwd === repo || (cwd ?? "").startsWith(`${repo}/`);
}

/**
 * The agent that gets the comments: the focused one, else the one the review was opened
 * from, else the only agent in this tab working in the repo.
 * @param {string} repo
 * @param {Focus} f
 * @returns {AgentInfo}
 */
function agentFor(repo, f) {
  const live = agents();
  const review = reviews()[repo];
  const own = live.find((a) => a.address === f.terminal && a.address !== review?.terminal);
  if (own) return own;
  const opener = review && live.find((a) => a.address === review.agent);
  if (opener) return opener;
  const here = panes().filter((p) => p.tab === f.tab && p.terminal && inside(p.cwd, repo));
  const candidates = live.filter((a) => here.some((p) => p.terminal === a.address));
  if (candidates.length === 1) return candidates[0];
  throw new Failure(candidates.length ? "More than one agent works in this repo; focus the one to send to." : "No agent found for this repo; focus the agent and try again.");
}

/**
 * @param {HunkComment[]} comments
 * @param {string} repo
 * @param {string} agent
 */
function formatReview(comments, repo, agent) {
  const lines = comments.map((c) => {
    const at = c.newRange?.[0] ?? c.oldRange?.[0];
    return `- ${c.filePath}${at !== undefined ? `:${at}` : ""} — ${c.body}`;
  });
  /** @type {Record<string, string>} */
  const values = { "{worktree}": repo, "{comments}": lines.join("\n"), "{count}": String(comments.length), "{agent}": agent };
  return PROMPT.replace(/\{worktree\}|\{comments\}|\{count\}|\{agent\}/g, (m) => values[m]);
}

export default class Hunk extends View {
  /**
   * @param {unknown} _props
   * @param {AsyncContext} cx
   */
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    /** @type {string | null} the running action's label */
    this.busy = null;
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  /**
   * @param {KeyEvent} e
   * @param {Context} cx
   */
  key(e, cx) {
    cx.stop_propagation();
    if (e.key === "escape") return this.dismiss();
    if (this.busy) return;
    const m = e.modifiers;
    if (m.control || m.alt || m.platform) return this.dismiss();
    const key = e.key === "enter" ? "enter" : (e.key_char ?? e.key);
    const action = ACTIONS.find((a) => a[0] === key);
    if (!action) return this.dismiss();
    this.start(action, cx);
  }

  /**
   * @param {Action} action
   * @param {Context} cx
   */
  start([, label, id], cx) {
    this.busy = label;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        await this.act(id, cx);
      } catch (err) {
        notify({ title: "hunk", body: err instanceof Error ? err.message : String(err), level: "error" });
      }
      this.dismiss();
    });
  }

  async repo() {
    const f = focused();
    if (!f?.cwd) throw new Failure("The focused pane has no folder.");
    if (spaces().find((s) => s.id === f.space)?.machine) throw new Failure("Reviews on another machine are not supported.");
    const repo = await git(f.cwd, ["rev-parse", "--show-toplevel"]);
    if (!repo) throw new Failure(`${f.cwd} is not in a git repository.`);
    return { f, repo };
  }

  /**
   * @param {string} id an Action id
   * @param {AsyncContext} cx
   */
  async act(id, cx) {
    const { f, repo } = await this.repo();
    if (id === "send") return this.send(repo, f);
    if (id === "next" || id === "prev") {
      await hunkJson(["session", "navigate", "--repo", repo, id === "next" ? "--next-comment" : "--prev-comment"]);
      return;
    }
    if (id === "close") {
      const entry = reviewPane(repo);
      if (!entry) throw new Failure("No review pane is open for this repo.");
      run("pane.close", { pane: entry.pane });
      return;
    }
    return this.review(repo, f, /** @type {Mode} */ (id), cx);
  }

  /**
   * @param {string} repo
   * @param {Focus} f
   * @param {Mode} mode
   * @param {AsyncContext} cx
   */
  async review(repo, f, mode, cx) {
    const target = await hunkArgs(repo, mode);
    if (target.warning) notify({ title: "hunk", body: target.warning, level: "warning" });

    const open = reviewPane(repo);
    if (open) {
      // Re-point the live session; the --watch flag is not part of a reload.
      const reload = target.args.filter((a) => a !== "--watch");
      await hunkJson(["session", "reload", "--repo", repo, "--", ...reload]);
      setShared(REVIEWS, { ...reviews(), [repo]: { ...open, mode: target.mode } });
      run("pane.focus", { pane: open.pane });
      return;
    }

    const agent = agents().find((a) => a.address === f.terminal)?.address ?? null;
    const before = new Set(panes().map((p) => p.pane));
    run("terminal.open", { argv: ["hunk", ...target.args], folder: repo, place: "right" });
    for (let i = 0; i < 40; i++) {
      const added = panes().find((p) => !before.has(p.pane) && p.tab === f.tab);
      if (added) {
        setShared(REVIEWS, { ...reviews(), [repo]: { pane: added.pane, terminal: added.terminal, agent, mode: target.mode } });
        return;
      }
      await sleep(cx, 50);
    }
    throw new Failure("hunk started, but its pane did not appear; send and close may not find it.");
  }

  /**
   * @param {string} repo
   * @param {Focus} f
   */
  async send(repo, f) {
    const listed = await hunkJson(["session", "comment", "list", "--repo", repo, "--type", "user"]);
    /** @type {HunkComment[]} */
    const comments = Array.isArray(listed.comments) ? listed.comments.filter((/** @type {any} */ c) => c?.noteId && c.filePath) : [];
    const sentAll = /** @type {Record<string, string[]> | undefined} */ (shared(SENT)) ?? {};
    const sent = new Set(sentAll[repo] ?? []);
    const unsent = comments.filter((c) => !sent.has(c.noteId));
    if (unsent.length === 0) {
      notify({ title: "hunk", body: "No new review comments to send.", level: "info" });
      return;
    }

    const agent = agentFor(repo, f);
    const name = agent.program?.name ?? agent.address;
    const r = await hc(["send", agent.address, formatReview(unsent, repo, name)]);
    if (r.code !== 0) throw new Failure(`Could not send to ${name}; comments kept. ${r.stderr.trim()}`);

    // Record delivery before cleanup, so a failed removal cannot send a comment twice.
    const ids = [...(sentAll[repo] ?? []), ...unsent.map((c) => c.noteId)].slice(-SENT_CAP);
    setShared(SENT, { ...sentAll, [repo]: ids });
    let kept = 0;
    if (CLEAR_AFTER_SEND) {
      for (const c of unsent) {
        const rm = await exec("hunk", ["session", "comment", "rm", "--repo", repo, c.noteId, "--json"]);
        if (rm.code !== 0) kept++;
      }
    }
    const tail = kept ? ` ${kept} stayed visible in hunk.` : "";
    notify({ title: "hunk", body: `Sent ${unsent.length} comment(s) to ${name}.${tail}`, level: "success" });
  }

  render() {
    const t = /** @type {Record<string, Color>} */ (theme());
    return v_flex().id("hunk").track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(14).gap(8).bg(t.popover).text_color(t.foreground).text_size(12)
      .child(h_flex().justify_between()
        .child(div().font_semibold().child(this.busy ? `${this.busy}…` : "hunk · waiting for a key"))
        .child(div().text_color(t.muted).child("Esc cancel")))
      .child(v_flex().children(ACTIONS.map(([key, label]) =>
        h_flex().h(20).flex_none().items_center().gap(12)
          .child(div().w(48).text_color(t.accent).child(key === "enter" ? "⏎" : key))
          .child(div().flex_1().text_color(this.busy && this.busy !== label ? t.dim : t.foreground).child(label)))))
      .child(div().text_color(t.muted).child("Acts on the repo of the focused pane."));
  }
}
