from shutil import which as _which

import platform


if platform.system() == "Darwin":
    arch = 'aarch64-apple-darwin'
else:
    arch = 'x86_64-unknown-linux-musl'
aliases['starship'] = starship_exec = f'{$HOME}/.local/bin/starship-{arch}'


if pf'{starship_exec}'.exists():
    xontrib load prompt_starship
