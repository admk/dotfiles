from shutil import which as _which

$COMMAND_ICON_MAP = {
    'aerc': ' ',  # FIXME not working, aerc sets its own title
    'ac': '󰚩 ',
    'aichat': '󰚩 ',
    'brew': ' ',
    'fzf': ' ',
    'k': '󰣀 ',
    'kxh': '󰣀 ',
    'ssh': '󰣀 ',
    'less': ' ',
    'tmux': ' ',
    'gl': ' ',
    'gp': ' ',
    'gP': ' ',
    'lg': ' ',
    'lazygit': ' ',
    'system-color': ' ',
    'starship': ' ',
    'xh': ' ',
    'top': '󰄩 ',
    'htop': '󰄩 ',
    'btop': '󰄩 ',
    'bpytop': '󰄩 ',
}


def _title_main():
    from xonsh.prompt.base import PromptFormatter
    _pf = PromptFormatter()
    _TITLE_SEP = '│'

    def title_func():
        host = ${...}.get('KXH_HOST', '')
        host = '' if host == 'localhost' else f' {host}{_TITLE_SEP}'
        curjob = _pf('{current_job}')
        curjob = $COMMAND_ICON_MAP.get(curjob.split('/')[-1], curjob)
        prompt = _pf(f'{host}{curjob}{_TITLE_SEP}{{short_cwd}}')
        return prompt

    $TITLE = title_func


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
    @events.on_post_spec_run_reset
    def on_post_run_no_linebreak(spec=None, **kwargs):
        global _preprompt_linebreak
        _preprompt_linebreak = False


_title_main()
_starship_main()
del _title_main, _starship_main


if _which('atuin'):
    execx($(atuin init xonsh --disable-up-arrow))


# FIXME: term_integration does not work in tmux-based prewarmed shells
load_term_integration = (
    ${...}.get('TERM_PROGRAM') == 'iTerm.app' or
    ${...}.get('KITTY_PID') is not None
) and (
    ${...}.get('KXH_PREWARMER', 'none') != 'none' and
    ${...}.get('KXH_PREWARMED', '0') == '1'
)
if load_term_integration:
    xontrib load term_integration
    $MULTILINE_PROMPT = '│'
