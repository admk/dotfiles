xontrib load homebrew

$PATH = [
    '/opt/homebrew/opt/coreutils/libexec/gnubin'
] + $PATH + [
    '/Applications/Visual Studio Code.app/Contents/Resources/app/bin',
]
$BASH_COMPLETIONS += [
    '/opt/homebrew/etc/bash_completion.d',
    '/opt/homebrew/share/bash-completion/completions',
]

$SSH_AUTH_SOCK = '/Users/ko/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh'


$CHROMIUM = p'/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary'
aliases['chrome'] = "'$CHROMIUM'"


@aliases.register('proxy-browser')
def proxy_browser(args):
    parallel --halt-on-error 2 --ungroup ::: \
        f'ssh -vNT -o ControlMaster=no -D 1080 {args[0]}' \
        "'$CHROMIUM' --proxy-server=socks5://localhost:1080"
