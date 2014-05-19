# oh-my-zsh
export ZSH=$HOME/.external/oh-my-zsh
ZSH_CUSTOM=$HOME/.external/oh-my-zsh-custom
ZSH_THEME="sorin"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
plugins=(
    autojump
    autopep8
    brew
    fasd
    git
    git-flow
    history-substring-search
    osx
    pep8
    pip
    python
    tmux
    vi-mode
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# vi-mode
bindkey 'jk' vi-cmd-mode
bindkey '\e[A' history-substring-search-up
bindkey '\e[B' history-substring-search-down

# environment
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

# paths
pathdirs=(
    /usr/texbin
)
for d in $pathdirs; do
    if [ -d $d ]; then
        path+=$d
    fi
done

# shortcuts
alias py=python
alias py3=python3
alias ipy=ipython
alias ipy3=ipython3
alias br=brew
alias tm=tmux
alias e=vim

# functions
function nowrap {
    export COLS=`tput cols`
    cut -c-$COLS
    unset COLS
    echo -ne "\e[0m"
}
