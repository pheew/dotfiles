#!/usr/bin/env zsh

alias gupum="git pull --rebase upstream master"

unalias gg
alias gg="git gui &"


function glb() {
 local branches
 branches=$(git reflog show --pretty=format:'%gs ~ %gd' --date=relative \
	 	| grep 'checkout:' \
		| grep -oE '[^ ]+ ~ .*' \
		| awk -F~ '!seen[$1]++' \
		| head -n 10 \
		| awk -F' ~ HEAD@{' '{printf("%s: %s\n", substr($2, 1, length($2)-1), $1)}'
	)

  echo "$branches" \
	  | fzf \
	  | awk -F': ' '{ print $2}' \
	  | xargs git checkout 
}

function ghpr() {
  local PRs
  PRs=$(gh pr list "$@")

  echo "$PRs" \
	| fzf \
	| awk '{ print $1}' \
	| xargs gh pr checkout
}
