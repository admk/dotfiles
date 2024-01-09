import platform


def _carapace_main():
    if platform.system() == "Darwin":
        arch = 'darwin-arm64'
    if platform.system() == "Linux":
        arch = 'linux-amd64'
    home = ${...}.get('KXH_HOME', $HOME)
    file = f'{home}/.local/bin/carapace-{arch}'
    return pf'{file}'.exists()


if _carapace_main():
    aliases['carapace'] = file
    COMPLETIONS_CONFIRM = True
    exec($(carapace _carapace))
