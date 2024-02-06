def _starship_main():
    import platform

    if platform.system() == "Darwin":
        arch = 'aarch64-apple-darwin'
    else:
        arch = 'x86_64-unknown-linux-musl'
    home = ${...}.get('KXH_HOME', $HOME)
    file = f'{home}/.local/bin/starship-{arch}'

    if pf'{file}'.exists():
        $STARSHIP_CONFIG = f"{$XDG_CONFIG_HOME}/starship.toml"
        aliases['starship'] = file
        if ${...}.get('KXH_VERBOSE') == '1':
            print(f'kxh: starship: using {file!r}')
        xontrib load prompt_starship


_starship_main()
del _starship_main


if 'SSH_CONNECTION' in ${...}:
    # enable line breaks in starship prompt when using SSH
    # as the prompt could be very long
    starship config line_break.disabled false
