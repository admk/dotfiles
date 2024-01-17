import platform


aliases |= {
    'ns': 'nvidia-smi',
    'st': 'gpustat -cup',
}

@aliases.register('vd')
def _cuda_visible_devices(args):
    vd, *args = args
    if not args:
        $CUDA_VISIBLE_DEVICES = vd
        print(f'$CUDA_VISIBLE_DEVICES={vd}')
        return
    with ${...}.swap(CUDA_VISIBLE_DEVICES=vd):
        execx(' '.join(args))


def _ubuntu_specific():
    from shutil import which
    xontrib load apt_tabcomplete
    if not which('locale-gen'):
        apt install -y locales
        locale-gen "en_US.UTF-8"
    execs = [
        'autojump',
        'colordiff',
        'curl',
        'less',
        ('nvim', 'neovim'),
    ]
    to_install = []
    for e in execs:
        e, i = e if isinstance(e, tuple) else (e, e)
        if not which(e):
            to_install.append(i)
    if to_install:
        apt install -y @(to_install)


if 'ubuntu' in platform.uname().version.lower():
    _ubuntu_specific()
    del _ubuntu_specific
