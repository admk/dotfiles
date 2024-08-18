import sys
from shutil import which as _which

$PATH = [
    '/opt/homebrew/opt/coreutils/libexec/gnubin',
] + $PATH + [
    '/Applications/Visual Studio Code.app/Contents/Resources/app/bin',
    '$KXH_HOME/.local/bin/darwin',
]
$BASH_COMPLETIONS += [
    '/opt/homebrew/etc/bash_completion.d',
    '/opt/homebrew/share/bash-completion/completions',
]

$HF_HOME = f'/Users/{$USER}/.cache/huggingface'
$SSH_AUTH_SOCK = f'/Users/{$USER}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh'
if 'DBUS_LAUNCHD_SESSION_BUS_SOCKET' in ${...}:
    $DBUS_SESSION_BUS_ADDRESS = f'unix:path={$DBUS_LAUNCHD_SESSION_BUS_SOCKET}'

$CHROMIUM = p'/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary'
$BROWSER = 'open'


def _install_homebrew():
    if !(which brew 1>/dev/null 2>/dev/null):
        return
    echo 'Installing Homebrew...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    pkgs = [
        'font-symbols-only-nerd-font',
        'felixkratz/formulae/borders',
        'felixkratz/formulae/sketchybar',
        'koekeishiya/formulae/skhd',
        'koekeishiya/formulae/yabai',
    ]
    brew install @(pkgs)


def _install_secretive():
    import os
    if os.path.exists($SSH_AUTH_SOCK):
        return
    echo 'Installing Secretive'
    brew install maxgoedjen/tap/secretive
    echo 'Starting Secretive'
    brew services start secretive


@aliases.register('fo')
def _mdfind_fzf_oepn(args):
    for cmd in ('mdfind', 'fzf', 'magika'):
        if not _which(cmd):
            print(f'{cmd} not found.', file=sys.stderr)
            return -1
    file = $(mdfind @(args) 2> /dev/null | fzf)
    if not file:
        return
    group = $(magika -i --jsonl @(file) | jq -r ".dl.group").strip()
    if group in ['text', 'code']:
        $EDITOR @(file)
    else:
        open @(file) > /dev/null


def _auto_theme(force=False):
    if !(which system-color 1>/dev/null 2>/dev/null):
        system-color > /dev/null


@aliases.register('toggle-dark-mode')
def _toggle_dark_mode():
    script = """
        tell app \"System Events\"
        to tell appearance preferences
        to set dark mode to not dark mode"""
    osascript -e @(script.replace('\n', ' '))
    _auto_theme(True)


@aliases.register('proxy-browser-alt')
def _proxy_browser_alt(args):
    ssh_options = {
        'ControlMaster': 'no',
        # 'ExitOnForwardFailure': 'yes',
        # 'ClearAllForwardings': 'yes',
    }
    ssh_options = ' '.join(f'-o {k}={v}' for k, v in ssh_options.items())
    args = ' '.join(args)
    parallel -j2 --halt now,done=1 --ungroup ::: \
        "'$CHROMIUM' --proxy-server=socks5://localhost:1080 2>/dev/null" \
        f'ssh -vNT {ssh_options} -D 1080 {args}'


@aliases.register('proxy-browser')
def _proxy_browser(args):
    ssh_options = {
        # 'ControlMaster': 'no',
        'ExitOnForwardFailure': 'yes',
        'ClearAllForwardings': 'yes',
    }
    ssh_options = [f'-o {k}={v}' for k, v in ssh_options.items()]
    bargs = '_'.join(args).replace(' ', '_').replace('/', '_').replace('@', '_')
    socket_path = f'/tmp/ssh_proxy_browser_{bargs}'
    if not !(ssh -vfMNT @(ssh_options) -S @(socket_path) @(args)):
        echo 'Failed to establish SSH connection'
        return
    if not !(ssh @(ssh_options) -S @(socket_path) -O forward -D 1080 @(args)):
        echo 'Failed to forward SOCKS5 proxy port 1080'
        return
    if not !('$CHROMIUM' --proxy-server=socks5://localhost:1080):
        echo 'Failed to start browser'
        return
    ssh -S @(socket_path) -O exit @(args)


aliases |= {
    'chrome': "'$CHROMIUM'",
}


_install_homebrew()
_install_secretive()
_auto_theme()
del (
    _install_secretive,
)
