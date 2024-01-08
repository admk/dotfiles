from shutil import which as _which

import platform


$STARSHIP_CONFIG = f"{$XDG_CONFIG_HOME}/starship.toml"

if platform.system() == "Darwin":
    arch = 'aarch64-apple-darwin'
else:
    arch = 'x86_64-unknown-linux-musl'
home = ${...}.get('KXH_HOME', $HOME)
starship_exec = f'{home}/.local/bin/starship-{arch}'

if pf'{starship_exec}'.exists():
    aliases['starship'] = starship_exec
    xontrib load prompt_starship
