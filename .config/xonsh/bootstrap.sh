#!/usr/bin/env bash

# envs
export XSH_NAME=${XSH_NAME:-.kodot}
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
export XSH_CONDA_PREFIX=$XSH_HOME/.miniconda3
export PATH="$XSH_HOME/.local/bin:$XSH_CONDA_PREFIX/bin:$PATH"
if [[ ! -z $XSH_VERBOSE ]]; then
    echo "----- xsh envs -----"
    echo "\$HOME=$HOME"
    echo "\$OLD_HOME=$OLD_HOME"
    echo "\$XSH_NAME=$XSH_NAME"
    echo "\$XSH_HOME=$XSH_HOME"
    echo "\$XSH_CONDA_PREFIX=$XSH_CONDA_PREFIX"
    echo "\$XDG_HOME=$XDG_HOME"
    echo "\$XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
    echo "\$XDG_DATA_HOME=$XDG_DATA_HOME"
    echo "\$XDG_CACHE_HOME=$XDG_CACHE_HOME"
    echo "\$PATH=$PATH"
    OUT=/dev/stdout
    ERR=/dev/stderr
else
    OUT=/dev/null
    ERR=/dev/stderr
fi
cd $HOME

# conda
CONDA_SRC=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
if [ ! -f "$XSH_CONDA_PREFIX/bin/conda" ]; then
    CONDA_INSTALLER=$XSH_HOME/miniconda3.sh
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
    curl -L $CONDA_URL -o $CONDA_INSTALLER 1>$OUT 2>$ERR
    echo "Installing miniconda3 to $XSH_CONDA_PREFIX..."
    sh $CONDA_INSTALLER -u -b -p $XSH_CONDA_PREFIX 1>$OUT 2>$ERR
    if [ -f $CONDA_INSTALLER ]; then
        rm $CONDA_INSTALLER
    fi
fi

# xonsh
export XSH_PYTHON=$XSH_CONDA_PREFIX/bin/python
if [[ ! -z $XSH_VERBOSE ]]; then
    echo "----- xsh conda envs -----"
    echo "\$XSH_PYTHON=$XSH_PYTHON"
    PYTHONNOUSERSITE=1 $XSH_PYTHON -m site
fi
if [[ ! -z $XONSH_VERSION ]]; then
    exec $SHELL || exit 0
fi
if [ ! -f $XSH_CONDA_PREFIX/bin/xonsh ]; then
    USER_BASE=$(PYTHONNOUSERSITE=1 $XSH_PYTHON -m site --user-base)
    echo "Installing xonsh to $USER_BASE..."
    PYTHONNOUSERSITE=1 $XSH_PYTHON -m pip install \
        -r $XDG_CONFIG_HOME/xonsh/requirements.txt 1>$OUT 2>$ERR
fi
if [ ! -f $XSH_CONDA_PREFIX/bin/xonsh ]; then
    echo 'Xonsh failed to install, fall back to $SHELL.'
    exec $SHELL
else
    SHELL=$XSH_CONDA_PREFIX/bin/xonsh $SHELL
fi
