#!/usr/bin/env bash

# envs
export OLD_HOME=${HOME:-$(pwd)}
if [[ -z $XSH_NON_HERMETIC ]]; then
    export HOME=$OLD_HOME/.kodot
fi
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export PATH="$HOME/.local/bin:$HOME/.conda/bin:$PATH"

# conda
CONDA_PREFIX=$HOME/.miniconda3
if [ ! -f "$CONDA_PREFIX/bin/conda" ]; then
    echo "Downloading miniconda3..."
    curl -L -O https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
    echo "Installing miniconda3..."
    sh Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_PREFIX > /dev/null
    rm Miniconda3-latest-Linux-x86_64.sh
fi

# xonsh
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONDA_PYTHON=$CONDA_PREFIX/bin/python
if [[ -z $XONSH_VERSION ]]; then
    cd $HOME
    if ! $CONDA_PYTHON -c 'import xonsh' &>/dev/null; then
        echo "Installing xonsh..."
        $CONDA_PYTHON -m pip install --user pip
        $CONDA_PYTHON -m pip install --user -r $CURR_DIR/requirements.txt
    fi
    if ! $CONDA_PYTHON -c 'import xonsh' &>/dev/null; then
        echo 'Xonsh failed to install.'
        exec $SHELL
    else
        $CONDA_PREFIX/bin/python -m xonsh
    fi
fi
