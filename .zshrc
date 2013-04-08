# Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Editor
EDITOR=vim

# Vi mode
bindkey 'jk' vi-cmd-mode

# Path
pathdirs=(
    /usr/local/share/python
    /usr/local/share/python3
)
for d in $pathdirs; do
    if [ -d $d ]; then
        path+=$d
    fi
done
