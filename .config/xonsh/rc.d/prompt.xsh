from shutil import which as _which


@events.on_transform_command
def _transform_bangbang(cmd):
    import re
    cmd = cmd.replace('!!', $(history show -1).strip())
    cmd = re.sub(r'!(-?\d+)', r'$(history show \1)', cmd)
    return cmd


_preprompt_linebreak = False

def _starship_main():
    file = f'{$KXH_CONDA_PREFIX}/bin/starship'
    if not pf'{file}'.exists():
        print(f'kxh: starship: {file!r} not found, installing...')
        @(f'{$KXH_CONDA_PREFIX}/bin/conda') install -y -c conda-forge starship

    $STARSHIP_CONFIG = f"{$XDG_CONFIG_HOME}/starship.toml"
    aliases['starship'] = file
    if ${...}.get('KXH_VERBOSE') == '1':
        print(f'kxh: starship: using {file!r}')
    xontrib load prompt_starship

    # FIXME this occasionally breaks starship config file
    if 'SSH_CONNECTION' in ${...}:
        if pf'{file}'.exists():
            # enable line breaks in starship prompt when using SSH
            # as the prompt could be very long
            starship config line_break.disabled false
            starship config add_newline true
    else:
        # omit initial newline on shell startup
        # this config exists in starship.toml:
        # starship config add_newline false
        # and print a newline after every command
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
    execx($(atuin init xonsh --disable-up-arrow))
