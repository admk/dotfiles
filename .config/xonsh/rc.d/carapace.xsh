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


if ${...}.get('USE_CARAPACE', False) and _carapace := _carapace_path():
    aliases['carapace'] = _carapace
    COMPLETIONS_CONFIRM = True
    exec($(carapace _carapace xonsh))
    # mkdir -p $XDG_CONFIG_HOME/carapace/bin
    # ln -s @(_carapace) $XDG_CONFIG_HOME/carapace/bin/carapace
