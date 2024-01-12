import platform


def _carapace_path():
    if platform.system() == "Darwin":
        arch = 'darwin-arm64'
    if platform.system() == "Linux":
        arch = 'linux-amd64'
    home = ${...}.get('KXH_HOME', $HOME)
    file = f'{home}/.local/bin/carapace-{arch}'
    if pf'{file}'.exists():
        return file
    return None


if ${...}.get('USE_CARAPACE', True):
    _carapace_exec = _carapace_path()
    if _carapace_exec:
        if ${...}.get('KXH_VERBOSE') == '1':
            print(f'kxh: carapace: using {_carapace_exec}')
        aliases['carapace'] = _carapace_exec
        $COMPLETIONS_CONFIRM = True
        exec($(carapace _carapace xonsh))
        # mkdir -p $XDG_CONFIG_HOME/carapace/bin
        # ln -s @(_carapace_exec) $XDG_CONFIG_HOME/carapace/bin/carapace
