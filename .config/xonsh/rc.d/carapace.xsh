import os
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
            print(f'kxh: carapace: using {_carapace_exec!r}')
        $COMPLETIONS_CONFIRM = True
        exec($(@(_carapace_exec) _carapace xonsh))
        _carapace_ln = f'{os.path.dirname(_carapace_exec)}/carapace'
        if not pf'{_carapace_ln}'.exists():
            if ${...}.get('KXH_VERBOSE') == '1':
                print(f'kxh: carapace: creating symlink {_carapace_ln!r}')
            ln -s @(_carapace_exec) @(_carapace_ln)
        del _carapace_ln
    del _carapace_exec


del platform
del _carapace_path
