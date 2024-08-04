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


def _install_secretive():
    import os
    if os.path.exists($SSH_AUTH_SOCK):
        return
    echo 'Installing Secretive'
    brew install maxgoedjen/tap/secretive
    echo 'Starting Secretive'
    brew services start secretive


def _auto_theme(force=False):
    last_mode = $(cat $XDG_CACHE_HOME/kxh/last_color_mode 2>/dev/null)
    mode = $(defaults read -g AppleInterfaceStyle 2>/dev/null)
    if not mode:
        mode = 'Light'
    if not force and mode == last_mode:
        return
    echo @(mode) > $XDG_CACHE_HOME/kxh/last_color_mode
    theme = ${...}.get('DARK_THEME', 'tokyonight_night')
    if mode == 'Light':
        theme = ${...}.get('LIGHT_THEME', 'tokyonight_day')
    if 'ALACRITTY_SOCKET' in ${...}:
        alacritty_dir = f'{$XDG_CONFIG_HOME}/alacritty'
        ln -sf @(alacritty_dir)/themes/@(theme).toml @(alacritty_dir)/_active_theme.toml
        touch @(alacritty_dir)/alacritty.toml
    if 'KITTY_PID' in ${...}:
        kitty @ set-colors -a -c $XDG_CONFIG_HOME/kitty/themes/@(theme).conf


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


_install_secretive()
_auto_theme()
del (
    _install_secretive,
)
