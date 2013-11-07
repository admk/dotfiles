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
ATTACHED=`tmux list-sessions | grep -e "$USER.*attached"`
if [[ -z $SSH_CONNECTION  && -z $TMUX && -z $ATTACHED ]]; then
    tmux-reattach
fi

# Vi mode
bindkey 'jk' vi-cmd-mode

# Path
pathdirs=(
    /usr/texbin
)
for d in $pathdirs; do
    if [ -d $d ]; then
        path+=$d
    fi
done

# Shortcuts
alias py=python
alias py3=python3
alias ipy=ipython
alias ipy3=ipython3
alias br=brew
alias tm=tmux

# functions
function nowrap {
    export COLS=`tput cols`
    cut -c-$COLS
    unset COLS
    echo -ne "\e[0m"
}
