# path
typeset -U path
path+=(
    $HOME/.external/bin
    /usr/local/m-cli
)
path=($^path(N))

# oh-my-zsh
export ZSH=$HOME/.external/oh-my-zsh
if [[ ! -d $ZSH ]]; then
    echo '==> Installing oh-my-zsh...'
    git clone -b master --recursive \
        https://github.com/robbyrussell/oh-my-zsh.git $ZSH
fi
ZSH_CUSTOM=$HOME/.external/oh-my-zsh-custom
ZSH_THEME="ko"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
plugins=(
    autojump autopep8 brew docker fasd fzf git git-flow
    history-substring-search osx pep8 pip python tmux vi-mode
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# vi-mode fix
bindkey 'jk' vi-cmd-mode
bindkey ' ' magic-space
bindkey -M vicmd 'j' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd "gg" beginning-of-history
bindkey -M vicmd "G" end-of-history
bindkey -M vicmd "?" history-incremental-search-backward
bindkey -M vicmd "/" history-incremental-search-forward
bindkey -M viins "^W" backward-kill-word
bindkey -M viins "^?" backward-delete-char
bindkey -M viins "^A" beginning-of-line
bindkey -M viins "^E" end-of-line

# arrow keys fix
bindkey "$terminfo[cuu1]" history-substring-search-up
bindkey "$terminfo[cud1]" history-substring-search-down

# environment
export VISUAL=`which vim`
export EDITOR=$VISUAL
export LESS='-F -g -i -M -R -S -w -X -z-4'
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

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
    tmux attach-session -t $session 2>/dev/null || tmux new-session -s $session
}
ATTACHED=`tmux list-sessions 2>/dev/null | grep -e "$USER.*attached"`
if [[ -z $SSH_CONNECTION && -z $TMUX && -z $ATTACHED ]]; then
    tmux-reattach
fi

# neovim
export NVIM_TUI_ENABLE_TRUE_COLOR=1
export NVIM_TUI_ENABLE_CURSOR_SHAPE=1

# shortcuts
alias c=clear
alias o=open
alias e=nvim
alias br=brew
alias tm=tmux
alias gs="git status --short"
alias py=python
alias py3=python3
alias ipy=ipython
alias ipy3=ipython3
alias brup="brew update && brew upgrade"

# functions
function nowrap {
    # trim outputs
    export COLS=`tput cols`
    cut -c-$COLS
    unset COLS
    echo -ne "\e[0m"
}
function cdf {
    # cd to the path of the active Finder window
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
    if [ "$target" != "" ]; then
        cd "$target"; pwd
    else
        echo 'No Finder window found' >&2
    fi
}
function man {
    # colored manpages
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}
function sync {
    # sync and update configs

    function error {
        echo "! Failed to $1" 1>&2
    }

    cd $HOME

    echo '===> Fetching admk/ko-dot'
    touch .__sync \
        && git stash -u \
        && git checkout master \
        && git pull origin master \
        && git push origin master \
        && git stash pop \
        && rm .__sync \
        || error 'update admk/ko-dot'

    echo '===> Updating oh-my-zsh'
    upgrade_oh_my_zsh

    echo '===> Updating submodules'
    git submodule update --init --recursive \
        || error 'update submodules'

    echo '===> Refreshing Tmux preferences'
    tmux source-file ~/.tmux.conf > /dev/null \
        && tmux refresh-client -S \
        || error 'refresh Tmux preferences'

    echo '===> Updating Vim plugins'
    vim +PlugUpdate +qall \
        || error 'update Vim plugins'

    echo 'All done!'

    exec zsh
}

# custom
ZSHRC_CUSTOM="$HOME/.zshrc.custom"
if [[ -f $ZSHRC_CUSTOM ]]; then
    source $ZSHRC_CUSTOM
fi
