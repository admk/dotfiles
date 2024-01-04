#!/usr/bin/env bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [[ -z $XONSH_VERSION ]]; then
    if ! command -v xonsh &>/dev/null; then
        echo "Installing xonsh..."
        pip install --user -r $CURR_DIR/requirements.txt
    fi
    python -m xonsh
fi
