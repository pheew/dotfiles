# ZSH Theme - Preview: http://cl.ly/350F0F0k1M2y3A2i3p1S

function _custom_wip() {
	if [ -n "$(work_in_progress)" ]; then
		echo "WIP!! "
	fi
}
PROMPT='λ %~/ $(git_prompt_info)%{$fg_bold[yellow]%}$(_custom_wip)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
