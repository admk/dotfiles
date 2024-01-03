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
