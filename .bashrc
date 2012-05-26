# setup paths
MATLAB_PATH=/Applications/Miscellaneous/MATLAB_R2011a.app/bin:
SAGE_ROOT=/usr/local/share/sage:
GTKWAVE_PATH=/Applications/Miscellaneous/gtkwave.app/Contents/Resources/bin:
TEXINPUTS=SAGE_ROOT/local/share/texmf//:
PATH=/usr/local/bin:/usr/local/git/bin:$SAGE_ROOT:$MATLAB_PATH:$GTKWAVE_PATH:$PATH

# has color
export CLICOLOR=1

# bash prompts
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export PS1="\[\e[0;37m\]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\[\e[0m\]\n\u@\h:\W\$(__git_ps1 "$s") \n> "
export PS2="  "

# use mvim instead of vim for python support
hash mvim &> /dev/null
if [ $? -eq 0 ]; then
    alias vim='mvim -v'
fi

# bash completion for git
source ~/.bash_completion.d/git-completion.bash
source ~/.bash_completion.d/git-flow-completion.bash
