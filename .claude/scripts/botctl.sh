#!/usr/bin/env bash
# botctl.sh — shared bootstrap for botctl bots.
#
# botctl bots run in a NON-interactive bash that has no node on PATH and no
# bash-native nvm (the user manages node interactively with fish-only
# jorgebucaran/nvm.fish). Source this at the start of any command that needs the
# toolchain:
#
#     cd <repo> && source ~/.claude/scripts/botctl.sh && { nvm use || nvm install; } && yarn install
#
# It provides a small, self-contained bash `nvm` that uses the SAME store as the
# user's fish nvm — ~/.local/share/nvm, layout vX.Y.Z/bin — so there is ONE node
# store shared by fish and the bots (no duplicate downloads), with no dependency
# on fish or on nvm-sh: `nvm install` resolves and downloads node straight from
# nodejs.org into that store, where fish's `nvm` will also see it.
#
#   - `nvm use`     activates the .nvmrc version if already in the store (offline, fast)
#   - `nvm install` fetches+activates it if missing — so a Renovate PR that bumps
#                   `.nvmrc` to a new version Just Works.
#
# The bot's bash does NOT persist env between commands, so source this and run
# `nvm use`/`nvm install` in the SAME command as each node/yarn/git call.
#
# Future shared bot setup (env, auth helpers, …) can be added below — keep it
# idempotent and side-effect-free on source.

# Idempotent: skip re-running setup if already sourced in this shell.
if [ -n "${__BOTCTL_SH_SOURCED:-}" ]; then
    return 0 2>/dev/null || true
fi
__BOTCTL_SH_SOURCED=1

# ---------------------------------------------------------------------------
# nvm — self-contained bash node version manager over the shared nvm.fish store
# ---------------------------------------------------------------------------

export nvm_data="${nvm_data:-$HOME/.local/share/nvm}"
export nvm_mirror="${nvm_mirror:-https://nodejs.org/dist}"

# Version string from the nearest .nvmrc/.node-version (walks up from $1/$PWD).
_botctl_node_rc() {
    local d="${1:-$PWD}" f v
    while [ -n "$d" ] && [ "$d" != "/" ]; do
        for f in .nvmrc .node-version; do
            if [ -f "$d/$f" ]; then
                v=$(tr -d ' \t\r' <"$d/$f" | head -1)
                [ -n "$v" ] && { printf '%s\n' "$v"; return 0; }
            fi
        done
        d=$(dirname "$d")
    done
    return 1
}

# Bin dir of the newest INSTALLED node matching a spec, else empty (offline).
#   "24"        -> newest installed v24.*            (major only — the common case)
#   "20.19" / "v20.19.5" -> newest installed with that prefix
#   "lts/*", "" -> newest installed of any version   (alias/none — best effort)
_botctl_node_bin() {
    local spec=${1#v}
    case "$spec" in
        [0-9]*) ls -1d "$nvm_data"/v"${spec//./\\.}"*/bin 2>/dev/null | sort -V | tail -1 ;;
        *) ls -1d "$nvm_data"/v*/bin 2>/dev/null | sort -V | tail -1 ;;
    esac
}

# Resolve a spec to a full version (vX.Y.Z) via the nodejs.org index (network).
#   index.tab columns: version<TAB>date<TAB>…<TAB>lts(name|-)<TAB>security ; newest-first.
_botctl_node_resolve() {
    local spec=${1#v} idx
    idx=$(curl -fsSL --max-time 20 "$nvm_mirror/index.tab" 2>/dev/null) || return 1
    case "$spec" in
        node | latest | "")
            awk -F'\t' 'NR>1{print $1; exit}' <<<"$idx" ;;
        lts | lts/\*)
            awk -F'\t' 'NR>1 && $10!="-"{print $1; exit}' <<<"$idx" ;;
        lts/*)
            awk -F'\t' -v n="${spec#lts/}" 'NR>1 && tolower($10)==tolower(n){print $1; exit}' <<<"$idx" ;;
        [0-9]*)
            awk -F'\t' -v p="^v${spec//./\\.}([.]|\$)" 'NR>1 && $1 ~ p {print $1; exit}' <<<"$idx" ;;
        *) return 1 ;;
    esac
}

# Download+extract a fully-resolved version into the shared store (idempotent).
_botctl_node_install() {
    local full=$1 dest="$nvm_data/$1"
    if [ -x "$dest/bin/node" ]; then return 0; fi
    local os arch
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$(uname -m)" in
        arm64 | aarch64) arch=arm64 ;;
        x86_64) arch=x64 ;;
        *) arch=$(uname -m) ;;
    esac
    local url="$nvm_mirror/$full/node-$full-$os-$arch.tar.gz"
    echo "nvm: installing $full from $url" >&2
    mkdir -p "$dest"
    if ! curl -fsSL --max-time 300 "$url" | tar -xz -C "$dest" --strip-components=1 2>/dev/null; then
        rm -rf "$dest"
        echo "nvm: download/extract failed for $url" >&2
        return 1
    fi
}

# nvm <use|install|list|current> — `use` activates (installing on demand) in THIS shell.
nvm() {
    local cmd=${1:-} spec=${2:-}
    case "$cmd" in
        use | install)
            if [ -z "$spec" ]; then
                spec=$(_botctl_node_rc "$PWD") || {
                    echo "nvm: no version given and no .nvmrc found under $PWD" >&2
                    return 1
                }
            fi
            case "$spec" in
                *[!A-Za-z0-9._/*-]*)
                    echo "nvm: refusing suspicious version spec: '$spec'" >&2
                    return 1
                    ;;
            esac
            local bin
            bin=$(_botctl_node_bin "$spec")
            if [ -z "$bin" ]; then
                # `use` only consults the store; `install` (or a use-miss) goes to network.
                if [ "$cmd" = use ]; then
                    echo "nvm: '$spec' not installed (run: nvm install)" >&2
                    return 1
                fi
                local full
                full=$(_botctl_node_resolve "$spec") && [ -n "$full" ] || {
                    echo "nvm: could not resolve '$spec' from $nvm_mirror/index.tab" >&2
                    return 1
                }
                _botctl_node_install "$full" || return 1
                bin="$nvm_data/$full/bin"
            fi
            if [ -z "$bin" ] || [ ! -x "$bin/node" ]; then
                echo "nvm: could not activate '$spec' (no usable node under $nvm_data)" >&2
                return 1
            fi
            export PATH="$bin:$PATH"
            export nvm_current_version
            nvm_current_version=$(basename "$(dirname "$bin")")
            echo "nvm: using $nvm_current_version" >&2
            ;;
        list | ls)
            ls -1d "$nvm_data"/v*/ 2>/dev/null | xargs -n1 basename 2>/dev/null | sort -V ;;
        current)
            echo "${nvm_current_version:-none}" ;;
        *)
            echo "nvm (botctl.sh): supported commands: use [ver], install [ver], list, current" >&2
            return 1 ;;
    esac
}
