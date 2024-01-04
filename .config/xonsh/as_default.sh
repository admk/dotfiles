#!/bin/bash

if [[ -z $XONSH_VERSION ]]; then
    if ! command -v xonsh &>/dev/null; then
        echo "Installing xonsh..."
        pip install --user -r .config/xonsh/requirements.txt
    fi
    exec xonsh
fi
