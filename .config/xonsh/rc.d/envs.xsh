from shutil import which as _which

mkdir -p $XDG_CACHE_HOME/xonsh

# $XONSH_HISTORY_BACKEND = 'sqlite'
$XONSH_HISTORY_MATCH_ANYWHERE = True
$HISTCONTROL = 'ignoredups'
# $MOUSE_SUPPORT = True
$XONSH_SHOW_TRACEBACK = ${...}.get('KXH_DEBUG', False)
$XONSH_TRACEBACK_LOGFILE = f'{$XDG_CACHE_HOME}/xonsh/traceback.log'
$MULTILINE_PROMPT = ' '
$SUGGEST_COMMANDS = False
$XONSH_AUTOPAIR = True
# $XONSH_COPY_ON_DELETE = False
$COMPLETIONS_DISPLAY = 'single'
$COMPLETIONS_MENU_ROWS = 8

$AUTO_CD = True
$DOTGLOB = True

$VISUAL = 'nvim' if _which('nvim') else 'vim'
$EDITOR = $VISUAL
$CLICOLOR = 1
$LESS = '-F -g -i -M -R -S -w -X -z-4'
$LC_CTYPE = 'en_US.UTF-8'
$LC_ALL = 'en_US.UTF-8'

if 'TMUX' in ${...}:
    $TERM="xterm-256color"

# $GPG_TTY = $(tty)
if 'KXH_OLD_HOME' in ${...}:
    mkdir -p $KXH_OLD_HOME/.ssh/control_socket

$PIP_CONFIG_FILE = f'{$XDG_CONFIG_HOME}/pip/pip.conf'
$PIP_CACHE_DIR = f'{$XDG_CACHE_HOME}/pip'

$PYDEVD_DISABLE_FILE_VALIDATION = 1

try:
    $XONTRIB_ONEPATH_ACTIONS |= {
        'text/': $VISUAL,
        '*.log': 'tail',
    }
except KeyError:
    pass


def _vscode_shell_integration():
    if ${...}.get('TERM_PROGRAM') != 'vscode':
        return
    if not _which('code'):
        return
    old_editor = $EDITOR
    with open($(code --locate-shell-integration-path bash).strip('\n')) as f:
        src = f.read()
    source-bash @(src)
    $EDITOR = old_editor


_vscode_shell_integration()
del _vscode_shell_integration, _which
