# path {
typeset -U path
path+=(
    /usr/local/opt/curl/bin
    $HOME/.external/bin
    /usr/local/m-cli
)
path=($^path(N))
# }
# zplug {
# initialization
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/b4b4r07/zplug ~/.zplug
fi
source ~/.zplug/init.zsh
# plugins
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async", defer:0
# zplug "sindresorhus/pure", use:pure.zsh, as:theme
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-autosuggestions", defer:3
zplug "lib/completion", from:oh-my-zsh
zplug "b4b4r07/enhancd", use:init.sh
# install if plugin not installed
if ! zplug check --verbose; then
    zplug install
fi
# finalize
zplug load
# }
# history {
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=5000
setopt appendhistory
setopt sharehistory
setopt incappendhistory
# }
# vi-mode {
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
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# }
# environment {
export VISUAL=`which nvim`
export EDITOR=$VISUAL
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
# }
# tmux {
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
    tmux attach-session -t $session 2>/dev/null \
        || tmux new-session -s $session
}
# ATTACHED=`tmux list-sessions 2>/dev/null | grep -e "$USER.*attached"`
# if [[ -z $SSH_CONNECTION && -z $TMUX && -z $ATTACHED ]]; then
#     tmux-reattach
# fi
# }
# shortcuts {
alias c=clear
alias o=open
alias e=nvim
alias br=brew
alias tm=tmux
alias gs="git status --short --branch --column"
alias gds="git diff --staged"
alias py=python
alias py3=python3
alias ipy=ipython
alias ipy3=ipython3
alias pc=proxychains4
alias brup="brew update && brew upgrade"
alias grep='grep --color=auto'
# }
# functions {
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

    echo '===> Updating zplug'
    zplug update || error 'update zplug'

    echo '===> Updating submodules'
    git submodule update --init --recursive \
        || error 'update submodules'

    echo '===> Refreshing Tmux preferences'
    tmux source-file ~/.tmux.conf > /dev/null \
        && tmux refresh-client -S \
        || error 'refresh Tmux preferences'

    echo '===> Updating Vim plugins'
    $EDITOR +PlugUpdate +qall \
        || error 'update Vim plugins'

    echo 'All done!'
    exec zsh
}
function transfer() {
    # check arguments
    if [ $# -eq 0 ];
    then
        echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    # get temporarily filename, output is written to this file show progress can be showed
    tmpfile=$( mktemp -t transferXXX )

    # upload stdin or file
    file=$1

    if tty -s;
    then
        basefile=$(basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g')

        if [ ! -e $file ];
        then
            echo "File $file doesn't exists."
            return 1
        fi

        if [ -d $file ];
        then
            # zip directory and transfer
            zipfile=$( mktemp -t transferXXX.zip )
            cd $(dirname $file) && zip -r -q - $(basename $file) >> $zipfile
            curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> $tmpfile
            rm -f $zipfile
        else
            # transfer file
            curl --progress-bar --upload-file "$file" "https://transfer.sh/$basefile" >> $tmpfile
        fi
    else
        # transfer pipe
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file" >> $tmpfile
    fi

    # cat output link
    cat $tmpfile

    # cleanup
    rm -f $tmpfile
}
# }
# custom {
# prompt_newline=$(echo -n "\u200B")
ZSHRC_CUSTOM="$HOME/.zshrc.custom"
if [[ -f $ZSHRC_CUSTOM ]]; then
    source $ZSHRC_CUSTOM
fi
# }
# vim: set fdm=marker fmr={,}:
