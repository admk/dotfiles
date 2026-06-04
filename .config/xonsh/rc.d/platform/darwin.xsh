import os
import sys
from shutil import which as _which

$PATH = [
    '/opt/homebrew/opt/coreutils/libexec/gnubin',
    '/opt/homebrew/opt/curl/bin',
] + $PATH + [
    '/Applications/Visual Studio Code.app/Contents/Resources/app/bin',
    '$KXH_HOME/.local/bin/darwin',
    '$HOME/.cargo/bin/',
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
    if os.path.exists('/opt/homebrew'):
        return
    echo 'Installing Homebrew...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    pkgs = [
        'font-symbols-only-nerd-font',
        'felixkratz/formulae/borders',
        'felixkratz/formulae/sketchybar',
        'koekeishiya/formulae/skhd',
        'koekeishiya/formulae/yabai',
        'cormacrelf/tap/dark-notify',
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


def _auto_theme(force=False):
    state = None
    if _which("theme-apply"):
        state = str($(theme-apply --print)).strip()
    elif _which("dark-notify"):
        state = str($(dark-notify -e)).strip()
    if state:
        $KXH_COLOR_MODE = state
        $AICHAT_LIGHT_THEME = str(state.startswith('light')).lower()


@events.on_pre_prompt
@events.on_precommand
def _on_precommand(**kwargs):
    _auto_theme()


@aliases.register('toggle-dark-mode')
def _toggle_dark_mode():
    script = """
        tell app \"System Events\"
        to tell appearance preferences
        to set dark mode to not dark mode"""
    osascript -e @(script.replace('\n', ' '))
    _auto_theme(True)


@aliases.register('osc')
def _openscad_compile(args):
    if len(args) != 1:
        echo 'Usage: osc <file.scad>'
        return
    f = args[0]
    g = f.replace('.scad', '.stl')
    print(f"Rendering and exporting {g!r}...")
    openscad -o @(g) --backend Manifold @(f)


aliases |= {
    'chrome': "'$CHROMIUM'",
    'a': 'aerc',
    'ac': 'aichat',
    't': 'tali-cli',
}


_auto_theme()


_install_homebrew()
_install_secretive()
del (
    _install_homebrew,
    _install_secretive,
)
