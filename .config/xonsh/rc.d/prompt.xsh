from shutil import which as _which


@events.on_transform_command
def _transform_bangbang(cmd):
    import re
    cmd = cmd.replace('!!', $(history show -1).strip())
    cmd = re.sub(r'!(-?\d+)', r'$(history show \1)', cmd)
    return cmd


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

    if 'SSH_CONNECTION' in ${...}:
        # enable line breaks in starship prompt when using SSH
        # as the prompt could be very long
        starship config line_break.disabled false
        starship config add_newline true
    else:
        # omit initial newline on shell startup
        # this config exists in starship.toml:
        # starship config add_newline false
        # and print a newline after every command
        _preprompt_linebreak = False

        @events.on_pre_prompt
        def on_pre_prompt():
            global _preprompt_linebreak
            if _preprompt_linebreak:
                print()
            else:
                _preprompt_linebreak = True

        @events.on_post_spec_run_clear
        def print_while_ls(spec=None, **kwargs):
            global _preprompt_linebreak
            _preprompt_linebreak = False


_starship_main()
del _starship_main


if _which('atuin'):
    eval "$(atuin init zsh --disable-up-arrow)"
