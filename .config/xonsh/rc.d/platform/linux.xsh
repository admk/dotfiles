import platform

from common.aliases import register_env_alias


aliases |= {
    'ns': 'nvidia-smi',
    'st': 'gpustat -cup',
    'sexit': '"SLURM_JOB_ID" in ${...} && scancel $SLURM_JOB_ID || exit -1',
}


@register_env_alias('vd', setmode='update')
def _cuda_visible_devices(args):
    if not args:
        return args, {'CUDA_VISIBLE_DEVICES': ''}
    devices, *args = args
    return args, {'CUDA_VISIBLE_DEVICES': devices}


def _share_folder(args):
    # TODO WIP
    if len(args) != 1:
        print('Usage: share-folder <user>')
        return
    if not p'/home/shared'.exists():
        groupadd shared
        mkdir -p /home/shared/
        chgrp -R shared /home/shared/
        chmod -R 2775 /home/shared/
    usermod -a -G shared @(args)


def _install_homebrew():
    if $USER != "root":
        return
    if p'/home/linuxbrew/.linuxbrew/bin/brew'.exists():
        return
    print('Installing Homebrew...')
    url = 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
    proxy = ${...}.get('PROXY', '')
    with ${...}.swap(
        http_proxy=proxy,
        https_proxy=proxy,
        all_proxy=proxy,
    ):
        apt-get install -y build-essential procps curl file git
        curl -fsL @(url) -o .homebrew_install.sh
        execx('/bin/bash .homebrew_install.sh')
        rm .homebrew_install.sh
        xontrib reload homebrew
        brew install gcc tmux btop atuin


def _ubuntu_specific():
    from shutil import which
    xontrib load apt_tabcomplete
    execs = [
        'autojump',
        'colordiff',
        'curl',
        'less',
        'xsel',
        ('locale-gen', 'locales'),
        ('nvim', 'neovim'),
    ]
    to_install = []
    for e in execs:
        e, i = e if isinstance(e, tuple) else (e, e)
        if not which(e):
            to_install.append(i)
    if $USER == 'root' and to_install:
        apt update
        apt install -y @(to_install)
    if 'local-gen' in to_install:
        locale-gen "en_US.UTF-8"


if 'ubuntu' in platform.uname().version.lower():
    _ubuntu_specific()
    _install_homebrew()
    aliases.register('share-folder')(_share_folder)
del _ubuntu_specific, _install_homebrew, _share_folder
