from shutil import which as _which

$VISUAL = 'vim'
if _which('nvim'):
    $VISUAL = 'nvim'
if 'VSCODE_INJECTION' in ${...}:
    $VISUAL = 'code --wait'
$EDITOR = $VISUAL
$CLICOLOR = 1
$LSCOLORS = 'gxfxcxdxbxegedabagacad'
$LS_COLORS = 'di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
$LESS = '-F -g -i -M -R -S -w -X -z-4'
$LC_CTYPE = 'en_US.UTF-8'
$LC_ALL = 'en_US.UTF-8'

if not p'~/.tmux'.exists():
    execx('git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm')
if 'TMUX' in ${...}:
    $TERM="xterm-256color"
