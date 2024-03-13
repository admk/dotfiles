$PATH = [
    '/opt/homebrew/opt/coreutils/libexec/gnubin',
] + $PATH + [
    '/Applications/Visual Studio Code.app/Contents/Resources/app/bin',
]
$BASH_COMPLETIONS += [
    '/opt/homebrew/etc/bash_completion.d',
    '/opt/homebrew/share/bash-completion/completions',
]

$HF_HOME = f'/Users/{$USER}/.cache/huggingface'
$SSH_AUTH_SOCK = f'/Users/{$USER}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh'

$CHROMIUM = p'/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary'
aliases['chrome'] = "'$CHROMIUM'"

$BROWSER = 'open'

@aliases.register('proxy-browser-alt')
def proxy_browser_alt(args):
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
def proxy_browser(args):
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


@aliases.register('patch-vscode')
def patch_vscode():
    sed -i '' \
        's/:k\.isUnsupportedGlibc/:0/g' \
        "/Applications/Visual Studio Code.app/Contents/Resources/app/out/"\
        "vs/workbench/workbench.desktop.main.js"
