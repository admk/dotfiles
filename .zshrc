# Prezto
PREZTO="${ZDOTDIR:-$HOME}/.external/prezto"
if [[ -s "$PREZTO/init.zsh" ]]; then
    source "$PREZTO/init.zsh"
    # Zstyles
    zstyle ':prezto:module:editor:info:keymap:primary' format ' %B%F{red}>%F{yellow}>%F{green}>%f%b'
    zstyle ':prezto:module:editor:info:keymap:alternate' format ' %B%F{green}<%F{yellow}<%F{red}<%f%b'
fi

# Environment
export VISUAL=`which vim`
export EDITOR=$VISUAL
if [ -z "$TMUX" ]; then
    export TERM=xterm-256color
fi

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
