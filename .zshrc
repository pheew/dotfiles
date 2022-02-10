# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="lambda-custom"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.custom-zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast git git-custom systemd systemd-custom bower sudo common-aliases golang zsh_reload yarn npm vi-mode history-substring-search nextjs-custom)

if [[ "$OSTYPE" == "darwin"* ]]; then
	if [[ `arch` == "arm64" ]]; then
		local brew_bin="/opt/homebrew/bin/brew"
	else
		local brew_bin="/usr/local/homebrew/bin/brew"
	fi
	if stat $brew_bin  >/dev/null 2>&1
	then
		plugins+=(brew)
	        local brew_prefix=`$brew_bin config | awk -F ': ' '/HOMEBREW_PREFIX/ {print $2}'`
		export PATH="${brew_prefix}/bin:${brew_prefix}/sbin${PATH+:$PATH}:"
		export MANPATH="${brew_prefix}/share/man${MANPATH+:$MANPATH}:"
		export INFOPATH="${brew_prefix}/share/info:${INFOPATH:-}"

		FPATH="$brew_prefix/share/zsh/site-functions:$FPATH"

		autoload -Uz compinit
		compinit
	fi
fi

if command -v yum > /dev/null 2>&1
then
	plugins+=(yum)
fi
if command -v docker > /dev/null 2>&1
then
	alias dgc="docker run --rm -e FORCE_IMAGE_REMOVAL=1 -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc:ro spotify/docker-gc"
	plugins+=(docker)
fi

if command -v tmux > /dev/null 2>&1
then
	ZSH_TMUX_AUTOSTART=true
	ZSH_TMUX_AUTOQUIT=false
#	if [ ${SSH_CONNECTION+1} ];
#	then
#	fi

	plugins+=(tmux)
fi

if command -v pacman >/dev/null 2>&1
then
	plugins+=(archlinux)
fi
if command -v apt-get >/dev/null 2>&1
then
	plugins+=(debian)
fi

source $ZSH/oh-my-zsh.sh

# User configuration

export GOPATH=$HOME/go
export GO15VENDOREXPERIMENT=1

export PATH="${PATH}:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin #add go paths

# Node bin take precedence over global paths 
export PATH=./node_modules/.bin:~/.yarn/bin:$PATH # add nodejs path

if [ -f ~/.nvm/nvm.sh ]
then
	export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm
	export NVM_SYMLINK_CURRENT="true"
	plugins+=(nvm)

	export PATH="~/.nvm/current/bin:$PATH"
fi

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

export EDITOR=vim
if command -v nvim > /dev/null 2>&1
then
	alias vim=nvim
fi

unalias gg
alias gg="git gui &"

if command -v htop > /dev/null 2>&1
then
	alias top=htop
fi

unsetopt Autocd
export KEYTIMEOUT=1

alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
if [ -x /usr/libexec/path_helper ]; then
	eval $(/usr/libexec/path_helper -s)
fi
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
