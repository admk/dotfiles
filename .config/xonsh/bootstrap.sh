#!/usr/bin/env bash

# envs
export XSH_NAME=.kodot
export XSH_HOME=$HOME/$XSH_NAME
if [[ $XSH_MODE == 'non-hermetic' ]]; then
    export XDG_HOME=$HOME
elif [[ $XSH_MODE == 'semi-hermetic' ]]; then
    export XDG_HOME=$XSH_HOME
elif [[ $XSH_MODE == 'hermetic' ]]; then
    export XDG_HOME=$XSH_HOME
    export OLD_HOME=${HOME}
    export HOME=$XSH_HOME
else
    echo 'Unsupported XSH_MODE $XSH_MODE' >&2
    exit 1
fi
export XDG_CONFIG_HOME="$XDG_HOME/.config"
export XDG_DATA_HOME="$XDG_HOME/.local/share"
export XDG_CACHE_HOME="$XDG_HOME/.cache"
export PATH="$XSH_HOME/.local/bin:$XSH_HOME/.conda/bin:$PATH"
cd $HOME

# conda
CONDA_SRC=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
CONDA_PREFIX=$HOME/.miniconda3
if [ ! -f "$CONDA_PREFIX/bin/conda" ]; then
    mkdir -p $XDG_CACHE_HOME
    CONDA_INSTALLER=$XDG_CACHE_HOME/miniconda3.sh
    if [[ $(uname) == 'Darwin' ]]; then
        OS='MacOSX'
    elif [[ $(uname) == 'Linux' ]]; then
        OS='Linux'
    else
        echo 'Unsupported OS $OS' >&2
        exit 1
    fi
    ARCH=$(uname -m)
    CONDA_URL=$CONDA_SRC/Miniconda3-latest-$OS-$ARCH.sh
    echo "Downloading miniconda3 from $CONDA_URL to $CONDA_INSTALLER..."
    curl -L $CONDA_URL -o $CONDA_INSTALLER
    echo "Installing miniconda3 to $CONDA_PREFIX..."
    sh $CONDA_INSTALLER -u -b -p $CONDA_PREFIX > /dev/null
    if [ -f $CONDA_INSTALLER ]; then
        rm $CONDA_INSTALLER
    fi
fi

# xonsh
CONDA_PYTHON=$CONDA_PREFIX/bin/python
if [[ ! -z $XONSH_VERSION ]]; then
    exec $SHELL || exit 0
fi
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
