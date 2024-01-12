from shutil import which as _which

mkdir -p $XDG_CACHE_HOME/xonsh

$XONSH_HISTORY_BACKEND = 'sqlite'
$XONSH_HISTORY_FILE = f'{$XDG_CACHE_HOME}/xonsh/xonsh-history.sqlite'
$XONSH_HISTORY_MATCH_ANYWHERE = True
$HISTCONTROL = 'ignoredups'
$MOUSE_SUPPORT = False
$XONSH_SHOW_TRACEBACK = True
$XONSH_TRACEBACK_LOGFILE = f'{$XDG_CACHE_HOME}/xonsh-traceback.log'
$MULTILINE_PROMPT = ' '
$SUGGEST_COMMANDS = False
$XONSH_AUTOPAIR = True
$COMPLETIONS_DISPLAY = 'single'
$COMPLETIONS_MENU_ROWS = 8

$AUTO_CD = True
$DOTGLOB = True

$VISUAL = 'vim'
if _which('nvim'):
    $VISUAL = 'nvim'
if 'VSCODE_INJECTION' in ${...}:
    $VISUAL = 'code --wait'
$EDITOR = $VISUAL
$CLICOLOR = 1
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
