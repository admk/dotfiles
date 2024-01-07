from shutil import which as _which

$XONSH_HISTORY_BACKEND = 'sqlite'
$HISTCONTROL = 'ignoredups'
$MOUSE_SUPPORT = True

$MULTILINE_PROMPT = ' '

$AUTO_CD = True
$DOTGLOB = True
$XONSH_SHOW_TRACEBACK = True
$XONSH_TRACEBACK_LOGFILE = f'{$XDG_CACHE_HOME}/xonsh-traceback.log'
$SUGGEST_COMMANDS = False

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

if 'TMUX' in ${...}:
    $TERM="xterm-256color"

try:
    $XONTRIB_ONEPATH_ACTIONS |= {
        'text/': $VISUAL,
        '*.log': 'tail',
    }
except KeyError:
    pass
