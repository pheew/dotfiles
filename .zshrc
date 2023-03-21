## Enable profiler
# zmodload zsh/zprof

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="lambda-custom"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.custom-zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
        gitfast
        git
        git-custom
        common-aliases
        common-custom
        golang
        yarn
        npm
        node-custom
        vi-mode
        nextjs-custom
        fzf
        fzf-solarized
)

if [[ "$OSTYPE" == "darwin"* ]]; then
        local brew_bin
        if [[ "$(arch)" == "arm64" ]]; then
                brew_bin="/opt/homebrew/bin/brew"
        else
                brew_bin="/usr/local/homebrew/bin/brew"
        fi

        if [[ -f "$brew_bin" ]]; then
                plugins+=(brew)
                local brew_prefix=$($brew_bin config | awk -F ': ' '/HOMEBREW_PREFIX/ {print $2}')
                export PATH="${brew_prefix}/bin:${brew_prefix}/sbin${PATH+:$PATH}:"
                export MANPATH="${brew_prefix}/share/man${MANPATH+:$MANPATH}:"
                export INFOPATH="${brew_prefix}/share/info:${INFOPATH:-}"

                FPATH="$brew_prefix/share/zsh/site-functions:$FPATH"

                autoload -Uz compinit

                for dump in ~/.zcompdump(N.mh+24); do
                    compinit
                done

                compinit -C

        fi
fi

function command_exists {
        local cmd
        cmd="${1}"

        command -v "$cmd" >/dev/null 2>&1
}

function if_exists {
        local cmd
        cmd="${1}"

        local plugin
        plugin="${2-$cmd}"

        if command_exists "$cmd"; then
                plugins+=($plugin)
        fi
}

if command_exists system-ctl; then
        plugins+=(systemd custom-systemd)
fi

if_exists yum
if_exists fzf
if_exists pacman archlinux
if_exists apt-get debian
if_exists fd
if_exists rg ripgrep

if command_exists docker; then
        alias dgc="docker run --rm -e FORCE_IMAGE_REMOVAL=1 -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc:ro spotify/docker-gc"
        plugins+=(docker)
fi

if command_exists tmux; then
        ZSH_TMUX_AUTOSTART=true
        ZSH_TMUX_AUTOQUIT=false

        plugins+=(tmux)
fi

source $ZSH/oh-my-zsh.sh

# User configuration

export GOPATH=$HOME/go
export GO15VENDOREXPERIMENT=1

export PATH="${PATH}:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin #add go paths

# Node bin take precedence over global paths
export PATH="./node_modules/.bin:~/.yarn/bin:${PATH}" # add nodejs path

if [[ -f ~/.nvm/nvm.sh ]]; then
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm
        export NVM_SYMLINK_CURRENT="true"
        plugins+=(nvm)

        export PATH="~/.nvm/current/bin:$PATH"
fi

# Setup (neo)vim
if command_exists vim; then
        export EDITOR=vim
fi
if command_exists nvim; then
        alias vim=nvim
fi

if command_exists htop; then
        alias top=htop
fi

if command_exists tree; then
        alias tree="tree --gitignore"
fi

unsetopt Autocd
#export KEYTIMEOUT=1

function reload() {
        echo 'reloading zsh config...'
        exec zsh
}

function timezsh() {
        shell=${1-$SHELL}
        for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

if [ -f ~/.secrets.sh ]; then
        source ~/.secrets.sh
fi
