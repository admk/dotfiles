import platform
from shutil import which as _which

from common.aliases import register_env_alias


aliases |= {
    'ns': 'nvidia-smi',
    'st': 'gpustat -cup',
    'sq': 'squeue -o "%.5i %.7P %.8j %.5u %.2t %.10M %R"',
    'sc': 'scontrol',
    'scn': 'scontrol show node',
    'scj': 'scontrol show job',
    'sla': 'sacctmgr -p list associations',
    'sexit': '"SLURM_JOB_ID" in ${...} && scancel $SLURM_JOB_ID || exit -1',
}


@aliases.register('ss')
def ssshd(args):
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('gpu_type', type=str)
    parser.add_argument('num_gpus', type=int)
    parser.add_argument('--cpus-per-gpu', type=int, default=16)
    args, remaining_args = parser.parse_known_args(args)
    try:
        partition, gpu_type = $SLURM_INFO[args.gpu_type]
    except NameError:
        print('$SLURM_INFO not provided.')
        return
    except KeyError:
        print(f'Unknown GPU type: {args.gpu_type}')
        return
    channel = ${...}.get('SLURM_CHANNEL', '#random')
    command = f'ssshd -N 1 -p {partition} '
    if gpu_type:
        command += f'--gres={gpu_type}:{args.num_gpus} '
    else:
        command += f'--gres="" '
    command += f'-c {args.cpus_per_gpu} '
    command += " ".join(remaining_args)
    command += ' -- slack chat send '
    command += f'\"Job $SLURM_JOB_ID started on $SLURM_NODELIST, '
    command += f'connect with ssh $USER@$SLURM_NODELIST -p $PORT\" \"{channel}\"'
    print(command)
    execx(command)


$CUDA_DEVICE_ORDER = 'PCI_BUS_ID'


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


def _install_apts():
    xontrib load apt_tabcomplete
    execs = [
        'autojump',
        'colordiff',
        'curl',
        'htop',
        'less',
        'lsof',
        'xsel',
        'sudo',
        ('locale-gen', 'locales'),
        ('nc', 'netcat'),
        # too old on 22.04
        # 'npm',
        # ('nvim', 'neovim'),
    ]
    to_install = []
    for e in execs:
        e, i = e if isinstance(e, tuple) else (e, e)
        if not _which(e):
            to_install.append(i)
    if $USER != 'root' or not to_install:
        return
    print(f'Installing packages: {", ".join(to_install)}')
    apt update
    apt install -y @(to_install)
    if 'locales' in to_install:
        locale-gen "en_US.UTF-8"


def _set_timezone():
    if $USER != 'root' or p'/etc/timezone'.exists():
        return
    $DEBIAN_FRONTEND='noninteractive' apt install -y tzdata
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata


def _install_homebrew():
    if $USER != "root":
        $PATH.append('/home/linuxbrew/.linuxbrew/bin')
        return
    if not p'/home/linuxbrew/.linuxbrew/bin/brew'.exists():
        print('Installing Homebrew...')
        mirror = 'https://mirrors.tuna.tsinghua.edu.cn'
        git_url = f'{mirror}/git/homebrew'
        bottle_url = f'{mirror}/homebrew-bottles'
        apt-get install -y build-essential procps curl file git
        git clone --depth=1 @(f'{git_url}/install.git') .brew-install
        with ${...}.swap(
            HOMEBREW_INSTALL_FROM_API=1,
            HOMEBREW_API_DOMAIN=f'{bottle_url}/api',
            HOMEBREW_BOTTLE_DOMAIN=bottle_url,
            HOMEBREW_BREW_GIT_REMOTE=f'{git_url}/brew.git',
            HOMEBREW_CORE_GIT_REMOTE=f'{git_url}/homebrew-core.git',
            NONINTERACTIVE=1,
        ):
            execx('/bin/bash .brew-install/install.sh')
        rm -rf .brew-install
        xpip install xontrib-homebrew
        xontrib reload homebrew
    pkgs = [
        'atuin',
        'btop',
        'lsd',
        'tmux',
        'npm',
        'nvim',
        'yazi',
        ('carapace', 'rsteube/tap/carapace'),
    ]
    to_install = []
    for pkg in pkgs:
        pkg, src = pkg if isinstance(pkg, tuple) else (pkg, pkg)
        if not pf'/home/linuxbrew/.linuxbrew/bin/{pkg}'.exists():
            to_install.append(src)
    if not to_install:
        return
    print(f'Installing homebrew packages: {", ".join(to_install)}.')
    use_proxy = False
    if any('/tap/' in s for s in to_install):
        use_proxy = True
    if use_proxy:
        print(f'Using proxy {$PROXY!r} for GitHub.')
        context = ${...}.swap(
            http_proxy=f'http://{$PROXY}',
            https_proxy=f'http://{$PROXY}',
            all_proxy=f'socks5://{$PROXY}',
        )
    else:
        from contextlib import nullcontext
        context = nullcontext()
    with context:
        /home/linuxbrew/.linuxbrew/bin/brew install @(to_install)


def _ubuntu_specific():
    if 'ubuntu' not in platform.uname().version.lower():
        return
    if ${...}.get('KXH_FAST') != '1':
        _install_apts()
        _install_homebrew()
        _set_timezone()
    aliases.register('share-folder')(_share_folder)


def _centos_specific():
    $FOREIGN_ALIASES_SUPPRESS_SKIP_MESSAGE = True
    if not p'/etc/centos-release'.exists():
        return
    module = aliases.pop('module', None)
    @aliases.register('module')
    def _module(args):
        source-bash --suppress-skip-message module @(args)


try:
    _ubuntu_specific()
    _centos_specific()
except KeyboardInterrupt:
    print('Interrupted')
del (
    _ubuntu_specific, _install_apts, _install_homebrew, _set_timezone,
    _share_folder, _centos_specific)
