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

# tmux
if [[ -z $TMUX ]]; then
    export TERM=xterm-256color
fi
tmux-reattach() {
    local session
    if [[ -n $@ ]]; then
        session=$@
    else
        session=$USER
    fi
    tmux attach-session -t $session || tmux new-session -s $session
}

# Vi mode
bindkey 'jk' vi-cmd-mode

# Path
pathdirs=(
    /usr/local/share/python3
    /usr/local/share/python
    /usr/local/texlive/2011/bin/universal-darwin/
)
for d in $pathdirs; do
    if [ -d $d ]; then
        path+=$d
    fi
done
