from shutil import which as _which


@events.on_transform_command
def _transform_bangbang(cmd, **kwargs):
    import re
    cmd = cmd.replace('!!', $(history show -1).strip())
    cmd = re.sub(r'!(-?\d+)', r'$(history show \1)', cmd)
    return cmd


_preprompt_linebreak = False

def _starship_main():
    aliases['starship'] = file = f'{$KXH_CONDA_PREFIX}/bin/starship'
    if ${...}.get('KXH_DEBUG') == '1':
        print(f'kxh shell ==> starship: using {file!r}')
    # $STARSHIP_CONFIG = f"{$XDG_CONFIG_HOME}/starship.toml"
    $XONTRIB_PROMPT_STARSHIP_LEFT_CONFIG = f"{$XDG_CONFIG_HOME}/starship_left.toml"
    $XONTRIB_PROMPT_STARSHIP_RIGHT_CONFIG = f"{$XDG_CONFIG_HOME}/starship_right.toml"
    $XONTRIB_PROMPT_STARSHIP_BOTTOM_CONFIG = f"{$XDG_CONFIG_HOME}/starship_bottom.toml"
    $XONSH_STYLE_OVERRIDES['bottom-toolbar'] = 'noreverse'
    xontrib load prompt_starship

    if 'SSH_CONNECTION' in ${...}:
        global _preprompt_linebreak
        _preprompt_linebreak = True

    # omit initial newline on shell startup
    # this config exists in starship.toml:
    # starship config add_newline false
    # and print a newline after every command
    @events.on_pre_prompt
    def on_pre_prompt(**kwargs):
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


# if ${...}.get('TERM_PROGRAM') == 'iTerm.app':
#     xontrib load term_integration
