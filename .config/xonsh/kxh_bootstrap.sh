#!/usr/bin/env bash

# envs
export KXH_NAME=${KXH_NAME:-.kxh}
export KXH_OLD_HOME=${KXH_OLD_HOME:-$HOME}
export KXH_HOME=$KXH_OLD_HOME/$KXH_NAME
export KXH_MODE=${KXH_MODE:-hermetic}
if [[ $KXH_MODE == 'non-hermetic' ]]; then
    export XDG_HOME=$HOME
elif [[ $KXH_MODE == 'semi-hermetic' ]]; then
    export XDG_HOME=$KXH_HOME
elif [[ $KXH_MODE == 'hermetic' ]]; then
    export XDG_HOME=$KXH_HOME
    export HOME=$KXH_HOME
else
    echo 'Unsupported KXH_MODE $KXH_MODE' >&2
    exit 1
fi
export KXH_BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
export KXH_CONDA_PREFIX=$KXH_HOME/.miniconda3
export KXH_PYTHON=$KXH_CONDA_PREFIX/bin/python
export KXH_SHELL=$KXH_CONDA_PREFIX/bin/xonsh
export XDG_CONFIG_HOME="$XDG_HOME/.config"
export XDG_DATA_HOME="$XDG_HOME/.local/share"
export XDG_CACHE_HOME="$XDG_HOME/.cache"
# export PATH="$KXH_HOME/.local/bin:$KXH_CONDA_PREFIX/bin:$PATH"
if [[ $KXH_VERBOSE == '1' ]]; then
    echo "----- XONSH ENV -----"
    echo "\$HOME=$HOME"
    echo "\$KXH_OLD_HOME=$KXH_OLD_HOME"
    echo "\$KXH_NAME=$KXH_NAME"
    echo "\$KXH_HOME=$KXH_HOME"
    echo "\$KXH_BOOTSTRAP=$KXH_BOOTSTRAP"
    echo "\$KXH_CONDA_PREFIX=$KXH_CONDA_PREFIX"
    echo "\$KXH_PYTHON=$KXH_PYTHON"
    echo "\$KXH_SHELL=$KXH_SHELL"
    echo "\$XDG_HOME=$XDG_HOME"
    echo "\$XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
    echo "\$XDG_DATA_HOME=$XDG_DATA_HOME"
    echo "\$XDG_CACHE_HOME=$XDG_CACHE_HOME"
    echo "\$PATH=$PATH"
    echo "args: $@"
    OUT=/dev/stdout
    ERR=/dev/stderr
else
    OUT=/dev/null
    ERR=/dev/stderr
fi
cd $HOME

# conda
CONDA_SRC=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
if [ ! -f "$KXH_CONDA_PREFIX/bin/conda" ]; then
    CONDA_INSTALLER=$KXH_HOME/miniconda3.sh
    if [[ $(uname) == 'Darwin' ]]; then
        OS='MacOSX'
    elif [[ $(uname) == 'Linux' ]]; then
        OS='Linux'
    else
        echo 'Unsupported OS $OS' >$ERR
        exit 1
    fi
    ARCH=$(uname -m)
    CONDA_URL=$CONDA_SRC/Miniconda3-latest-$OS-$ARCH.sh
    echo "Downloading miniconda3 from $CONDA_URL to $CONDA_INSTALLER..."
    curl -L $CONDA_URL -o $CONDA_INSTALLER 1>$OUT 2>$ERR
    echo "Installing miniconda3 to $KXH_CONDA_PREFIX..."
    sh $CONDA_INSTALLER -u -b -p $KXH_CONDA_PREFIX 1>$OUT 2>$ERR
    if [ -f $CONDA_INSTALLER ]; then
        rm $CONDA_INSTALLER
    fi
fi

# xonsh
if [[ $KXH_VERBOSE == '1' ]]; then
    echo "----- CONDA ENV -----"
    echo "\$KXH_PYTHON=$KXH_PYTHON"
    PYTHONNOUSERSITE=1 $KXH_PYTHON -m site
fi
if [[ ! -z $XONSH_VERSION ]]; then
    exec $SHELL $@ || exit 0
fi
if [ ! -f $KXH_SHELL ]; then
    echo "Installing xonsh..."
    PYTHONNOUSERSITE=1 $KXH_PYTHON -m pip install \
        -r $XDG_CONFIG_HOME/xonsh/requirements.txt 1>$OUT 2>$ERR
fi
if [ ! -f $KXH_OLD_HOME/.local/bin/xonsh ]; then
    echo "Linking xonsh..."
    mkdir -p $KXH_OLD_HOME/.local/bin
    ln -s $KXH_BOOTSTRAP $KXH_OLD_HOME/.local/bin/xonsh
fi
if [ ! -f $KXH_SHELL ]; then
    echo 'Xonsh failed to install, fall back to $SHELL.'
    exec $SHELL $@ || exit 0
else
    SHELL=$KXH_SHELL exec $KXH_SHELL $@ || exit 0
fi
