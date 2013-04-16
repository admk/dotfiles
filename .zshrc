# Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Editor
export VISUAL=`which vim`
export EDITOR=$VISUAL

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
