# sorin-fixed.zsh-theme

if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]];
then

  EMOJI=(🐶 🐱 🐭 🐹 🐰 🐻 🐼 🐨 🐯 🦁 🐮 🐷 🐸 🐙 🐵 )
  function random_emoji {
    echo -n "$EMOJI[$RANDOM%$#EMOJI+1]"
  }

  MODE_INDICATOR="%{$fg[red]%}<<<%{$reset_color%}"
  local return_status="%{$fg[red]%}%(?..x )%{$reset_color%}"

  PROMPT='$(random_emoji)  %{$fg[cyan]%}%c$(git_prompt_info) %(!.%{$fg_bold[red]%}#.%{$fg_bold[green]%}>)%{$reset_color%} '

  ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%} "
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}*"
  ZSH_THEME_GIT_PROMPT_CLEAN=""
  RPROMPT='$(vi_mode_prompt_info)$(virtualenv_prompt_info)${return_status}$(git_prompt_status)%{$reset_color%}'

  ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}+"
  ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%}m"
  ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}x"
  ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%}>"
  ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%}="
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%}?"
  ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}^"

else

  MODE_INDICATOR="<<<"
  local return_status="%(?::x )"

  PROMPT='%c$(git_prompt_info) %(!.#.>) '

  ZSH_THEME_GIT_PROMPT_PREFIX=" git:"
  ZSH_THEME_GIT_PROMPT_SUFFIX=""
  ZSH_THEME_GIT_PROMPT_DIRTY="*"
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  RPROMPT='$(vi_mode_prompt_info) ${VIRTUAL_ENV:t} ${return_status}$(git_prompt_status)'

  ZSH_THEME_GIT_PROMPT_ADDED="+"
  ZSH_THEME_GIT_PROMPT_MODIFIED="m"
  ZSH_THEME_GIT_PROMPT_DELETED="x"
  ZSH_THEME_GIT_PROMPT_RENAMED=">"
  ZSH_THEME_GIT_PROMPT_UNMERGED="="
  ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
  ZSH_THEME_GIT_PROMPT_STASHED="^"

fi
