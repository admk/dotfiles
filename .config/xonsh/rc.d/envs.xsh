from shutil import which as _which

mkdir -p $XDG_CACHE_HOME/xonsh

# $XONSH_HISTORY_BACKEND = 'sqlite'
$XONSH_HISTORY_MATCH_ANYWHERE = True
$HISTCONTROL = 'ignoredups'
# $MOUSE_SUPPORT = True
$XONSH_SHOW_TRACEBACK = ${...}.get('KXH_DEBUG', False)
$XONSH_TRACEBACK_LOGFILE = f'{$XDG_CACHE_HOME}/xonsh/traceback.log'
$MULTILINE_PROMPT = '│'
$SUGGEST_COMMANDS = False
$XONSH_AUTOPAIR = True
# $XONSH_COPY_ON_DELETE = False
$COMPLETIONS_DISPLAY = 'single'
$COMPLETIONS_MENU_ROWS = 8

$AUTO_CD = True
$DOTGLOB = True

$PAGER = 'nvimpager' if _which('nvim') else 'less'
$VISUAL = 'nvim' if _which('nvim') else 'vim'
$EDITOR = $VISUAL
$CLICOLOR = 1
$LESS = '-F -g -i -M -R -S -w -X -z-4 -j4'
$LC_CTYPE = 'en_US.UTF-8'
$LC_ALL = 'en_US.UTF-8'
$LANG = 'en_US.UTF-8'

# $GPG_TTY = $(tty)
if 'KXH_OLD_HOME' in ${...}:
    mkdir -p $KXH_OLD_HOME/.ssh/control_socket

# non-xdg-compliant tools
$PIP_CONFIG_FILE = f'{$XDG_CONFIG_HOME}/pip/pip.conf'
$PIP_CACHE_DIR = f'{$XDG_CACHE_HOME}/pip'
$N_PREFIX = $XDG_DATA_HOME
$NOTMUCH_CONFIG = f'{$XDG_CONFIG_HOME}/aerc/notmuch.conf'
$CLAUDE_CONFIG_DIR=f'{$XDG_CONFIG_HOME}/claude'
$CODEX_HOME = f"{$XDG_CONFIG_HOME}/codex"
$LLM_USER_PATH = f"{$XDG_CONFIG_HOME}/llm/"

# python
$PYDEVD_DISABLE_FILE_VALIDATION = 1
$PYDEVD_WARN_SLOW_RESOLVE_TIMEOUT = 10

# notmuch search
$XAPIAN_CJK_NGRAM = 1

try:
    $XONTRIB_ONEPATH_ACTIONS |= {
        'text/': $VISUAL,
        '*.log': 'tail',
        'image/': 'kitten icat',
    }
except KeyError:
    pass


def _kitty_integration():
    if ${...}.get('KITTY_WINDOW_ID') is None:
        return
    global aliases
    aliases |= {
        'icat': 'kitten icat',
        'notify': 'kitten notify',
    }


def _fzf_integration():
    # $fzf_history_binding = "c-r"
    $fzf_ssh_binding = "c-s"
    $fzf_file_binding = "c-t"
    $fzf_dir_binding = "c-g"
    mod = getattr(__import__("xontrib"), 'fzf-widgets', None)
    if mod is not None and hasattr(mod, 'get_fzf_binary_name'):
        setattr(mod, 'get_fzf_binary_name', lambda: 'fzf')


def _nvim_shell_integration():
    if ${...}.get('NVIM') is None:
        return
    if not _which('nvim'):
        return
    aliases['_editor'] = [
        '$KXH_CONDA_PREFIX/bin/nvr',
        '--nostart',
        '--remote-tab-wait',
        '+setlocal bufhidden=wipe']
    $EDITOR = '_editor'


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


def _tmux_main():
    if "TMUX" not in ${...}:
        return

    server = $TMUX.split(',')[0]
    source_once = False

    @events.on_precommand
    def tmux_refresh(cmd, *args, **kwargs):
        """Update shell with tmux env. """
        nonlocal source_once
        if source_once:
            return
        source_once = "SSH_CONNECTION" not in ${...}
        # $TERM = "xterm-256color"
        source-bash $(bash -c @(f"tmux -S {server} showenv -s"))


_kitty_integration()
_fzf_integration()
_nvim_shell_integration()
_vscode_shell_integration()
_tmux_main()
del (
    _kitty_integration,
    _fzf_integration,
    _nvim_shell_integration,
    _vscode_shell_integration,
    _tmux_main,
    _which,
)
