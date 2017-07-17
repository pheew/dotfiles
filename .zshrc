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
plugins=(gitfast systemd bower sudo common-aliases golang zsh_reload yarn)

if command -v yum > /dev/null 2>&1
then
	plugins+=(yum)
fi
if command -v docker > /dev/null 2>&1
then
	plugins+=(docker)
fi


if command -v tmux > /dev/null 2>&1
then
	if [ ${SSH_CONNECTION+1} ];
	then
		ZSH_TMUX_AUTOSTART=true
	fi

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

if command -v brew >/dev/null 2>&1
then
	plugins+=(brew)
fi


source $ZSH/oh-my-zsh.sh

# User configuration

export GOPATH=$HOME/go
export GO15VENDOREXPERIMENT=1

export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:$HOME/.local/bin:$HOME/bin
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin #add go paths
export PATH=$PATH:./node_modules/.bin # add nodejs path

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export EDITOR=vim

#alias grep="$(which grep) $GREP_OPTIONS"
#unset GREP_OPTIONS

#alias gg="git gui"

alias jrn-unit="sudo journalctl -xe -f -u "
alias jrn-follow="sudo journalctl -xe -f"
alias jrn-fgrep="sudo journalctl -xe -f | grep"
alias sc-failed="systemctl --failed"

if command -v htop > /dev/null 2>&1
then
	alias top=htop
fi

unsetopt autocd
#unalias gvt

alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
eval $(/usr/libexec/path_helper -s)
