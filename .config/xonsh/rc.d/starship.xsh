import platform

$STARSHIP_CONFIG = f"{$XDG_CONFIG_HOME}/starship.toml"


def _starship_main():

    if platform.system() == "Darwin":
        arch = 'aarch64-apple-darwin'
    else:
        arch = 'x86_64-unknown-linux-musl'
    home = ${...}.get('KXH_HOME', $HOME)
    file = f'{home}/.local/bin/starship-{arch}'

    if pf'{file}'.exists():
        aliases['starship'] = file
        xontrib load prompt_starship


_starship_main()
