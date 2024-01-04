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

cd $HOME

# conda
CONDA_URL=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
CONDA_PREFIX=$HOME/.miniconda3
if [ ! -f "$CONDA_PREFIX/bin/conda" ]; then
    mkdir -p $XDG_CACHE_HOME
    CONDA_INSTALLER=$XDG_CACHE_HOME/miniconda3.sh
    echo "Downloading miniconda3 to $CONDA_INSTALLER..."
    curl -L $CONDA_URL/Miniconda3-latest-Linux-x86_64.sh -o $CONDA_INSTALLER
    echo "Installing miniconda3 to $CONDA_PREFIX..."
    sh $CONDA_INSTALLER -u -b -p $CONDA_PREFIX > /dev/null
    if [ -f $CONDA_INSTALLER ]; then
        rm $CONDA_INSTALLER
    fi
fi

# xonsh
CONDA_PYTHON=$CONDA_PREFIX/bin/python
if [[ -z $XONSH_VERSION ]]; then
    if ! $CONDA_PYTHON -c 'import xonsh' &>/dev/null; then
        USER_BASE=$($CONDA_PYTHON -m site --user-base)
        echo "Installing xonsh to $USER_BASE..."
        $CONDA_PYTHON -m pip install --user pip
        $CONDA_PYTHON -m pip install --user -r $XDG_CONFIG_HOME/xonsh/requirements.txt
    fi
    if ! $CONDA_PYTHON -c 'import xonsh' &>/dev/null; then
        echo 'Xonsh failed to install, fall back to $SHELL.'
        exec $SHELL
    else
        $CONDA_PREFIX/bin/python -m xonsh
    fi
fi
