#!/usr/bin/env bash

# envs
export KSH_NAME=${KSH_NAME:-.ksh}
export KSH_OLD_HOME=${KSH_OLD_HOME:-$HOME}
export KSH_HOME=$KSH_OLD_HOME/$KSH_NAME
export KSH_MODE=${KSH_MODE:-non-hermetic}
if [[ $KSH_MODE == 'non-hermetic' ]]; then
    export XDG_HOME=$HOME
elif [[ $KSH_MODE == 'semi-hermetic' ]]; then
    export XDG_HOME=$KSH_HOME
elif [[ $KSH_MODE == 'hermetic' ]]; then
    export XDG_HOME=$KSH_HOME
    export HOME=$KSH_HOME
else
    echo 'Unsupported KSH_MODE $KSH_MODE' >&2
    exit 1
fi
export KSH_CONDA_PREFIX=$KSH_HOME/.miniconda3
export KSH_PYTHON=$KSH_CONDA_PREFIX/bin/python
export KSH_SHELL=$KSH_CONDA_PREFIX/bin/xonsh
export XDG_CONFIG_HOME="$XDG_HOME/.config"
export XDG_DATA_HOME="$XDG_HOME/.local/share"
export XDG_CACHE_HOME="$XDG_HOME/.cache"
export PATH="$KSH_HOME/.local/bin:$KSH_CONDA_PREFIX/bin:$PATH"
if [[ ! -z $KSH_VERBOSE ]]; then
    echo "----- xsh envs -----"
    echo "\$HOME=$HOME"
    echo "\$KSH_OLD_HOME=$KSH_OLD_HOME"
    echo "\$KSH_NAME=$KSH_NAME"
    echo "\$KSH_HOME=$KSH_HOME"
    echo "\$KSH_CONDA_PREFIX=$KSH_CONDA_PREFIX"
    echo "\$KSH_PYTHON=$KSH_PYTHON"
    echo "\$KSH_SHELL=$KSH_SHELL"
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
if [ ! -f "$KSH_CONDA_PREFIX/bin/conda" ]; then
    CONDA_INSTALLER=$KSH_HOME/miniconda3.sh
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
    echo "Installing miniconda3 to $KSH_CONDA_PREFIX..."
    sh $CONDA_INSTALLER -u -b -p $KSH_CONDA_PREFIX 1>$OUT 2>$ERR
    if [ -f $CONDA_INSTALLER ]; then
        rm $CONDA_INSTALLER
    fi
fi

# xonsh
if [[ ! -z $KSH_VERBOSE ]]; then
    echo "----- xsh conda envs -----"
    echo "\$KSH_PYTHON=$KSH_PYTHON"
    PYTHONNOUSERSITE=1 $KSH_PYTHON -m site
fi
if [[ ! -z $XONSH_VERSION ]]; then
    exec $SHELL $@ || exit 0
fi
if [ ! -f $KSH_SHELL ]; then
    echo "Installing xonsh..."
    PYTHONNOUSERSITE=1 $KSH_PYTHON -m pip install \
        -r $XDG_CONFIG_HOME/xonsh/requirements.txt 1>$OUT 2>$ERR
fi
if [ ! -f $KSH_OLD_HOME/.local/bin/xonsh ]; then
    echo "Linking xonsh..."
    mkdir -p $KSH_OLD_HOME/.local/bin
    echo <<EOF
#!/usr/bin/env bash
XDG_CONFIG_HOME=$XDG_CONFIG_HOME \
XDG_DATA_HOME=$XDG_DATA_HOME \
XDG_CACHE_HOME=$XDG_CACHE_HOME \
SHELL=$KSH_SHELL \
exec $KSH_SHELL \$@
EOF > $KSH_OLD_HOME/.local/bin/xonsh
    chmod +x $KSH_OLD_HOME/.local/bin/xonsh
fi
if [ ! -f $KSH_SHELL ]; then
    echo 'Xonsh failed to install, fall back to $SHELL.'
    exec $SHELL $@ || exit 0
else
    SHELL=$KSH_SHELL exec $KSH_SHELL $@ || exit 0
fi
