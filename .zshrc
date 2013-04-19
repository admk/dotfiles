# Prezto
PREZTO="${ZDOTDIR:-$HOME}/.external/prezto"
if [[ -s "$PREZTO/init.zsh" ]]; then
  source "$PREZTO/init.zsh"
fi

# Editor
export VISUAL=`which vim`
export EDITOR=$VISUAL

# Auto run tmux on launch
if [ -z "$TMUX" ]; then
    export TERM=xterm-256color
    tmux attach-session -t "$USER" || tmux new-session -s "$USER"
fi

# Vi mode
bindkey 'jk' vi-cmd-mode

# Path
pathdirs=(
    /usr/local/share/python3
    /usr/local/share/python
)
for d in $pathdirs; do
    if [ -d $d ]; then
        path+=$d
    fi
done
