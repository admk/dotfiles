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
bindkey ' ' magic-space 
bindkey -M vicmd "gg" beginning-of-history
bindkey -M vicmd "G" end-of-history
bindkey -M vicmd "?" history-incremental-search-backward
bindkey -M vicmd "/" history-incremental-search-forward
bindkey -M viins "^W" backward-kill-word
bindkey -M viins "^?" backward-delete-char
bindkey -M viins "^A" beginning-of-line
bindkey -M viins "^E" end-of-line

# environment
export VISUAL=`which vim`
export EDITOR=$VISUAL
export LESS='-F -g -i -M -R -S -w -X -z-4'

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
alias e=vim
alias o=open
alias br=brew
alias tm=tmux
alias py=python
alias py3=python3
alias ipy=ipython
alias ipy3=ipython3

# functions
function nowrap {
    export COLS=`tput cols`
    cut -c-$COLS
    unset COLS
    echo -ne "\e[0m"
}

# sync
function sync {
    function error {
        echo "! Failed to $1" 1>&2
    }

    cd $HOME

    echo '===> Fetching admk/ko-dot'
    git stash \
        && git checkout master \
        && git pull origin master \
        && git push origin master \
        && git stash pop \
        || error 'update admk/ko-dot'

    echo '===> Updating submodules'
    git submodule update --init --recursive \
        || error 'update submodules'

    echo '===> Refreshing Tmux preferences'
    tmux source-file ~/.tmux.conf > /dev/null \
        && tmux refresh-client -S \
        || error 'refresh Tmux preferences'

    echo '===> Updating Vim plugins'
    vim -u .vim/bundles.vim +BundleInstall +BundleClean! +qall \
        || error 'update Vim plugins'

    echo 'All done!'
}
