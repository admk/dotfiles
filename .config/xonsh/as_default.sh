#!/usr/bin/env bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

if [[ -z $XONSH_VERSION ]]; then
    cd $HOME
    if ! python3 -c 'import xonsh' &>/dev/null; then
        echo "Installing xonsh..."
        python3 -m pip install --user -r $CURR_DIR/requirements.txt
    fi
    exec python3 -m xonsh
fi
