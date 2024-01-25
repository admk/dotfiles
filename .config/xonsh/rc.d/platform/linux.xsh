import platform

from common.aliases import register_env_alias


aliases |= {
    'ns': 'nvidia-smi',
    'st': 'gpustat -cup',
    'stime': 'squeue -h --me -j $SLURM_JOB_ID -o %e',
}


@register_env_alias('vd', setmode='toggle')
def _cuda_visible_devices(args):
    devices, *args = args
    return args, {'CUDA_VISIBLE_DEVICES': devices}


@aliases.register('sgpus')
def _sgpus(args):
    gres = $(scontrol show node | grep gres)
    total = {}
    alloc = {}
    for l in gres.splitlines():
        l = l.strip()
        if l.startswith('CfgTRES='):
            l = l.replace('CfgTRES=', '')
            d = total
        elif l.startswith('AllocTRES='):
            l = l.replace('AllocTRES=', '')
            d = alloc
        else:
            continue
        for g in l.split(','):
            k, v = g.split('=')
            if k.startswith('gres/'):
                d[k] = d.get(k, 0) + int(v)
    print(f'Allocated GPUs: {alloc["gres/gpu"]}/{total["gres/gpu"]}')
    for k, v in alloc.items():
        if k == 'gres/gpu':
            continue
        print(f"- {k.replace('gres/gpu:', '')}: {v}/{total[k]}")


def _ts_job_ids():
    return [int(l.strip().split(' ')[0]) for l in $(ts).splitlines()[1:]]


@aliases.register('ts-list-cmd')
def _ts_full_cmd_all(args):
    show_id = '-i' in args or '--id' in args
    running = '-r' in args or '--running' in args
    allocating = '-a' in args or '--allocating' in args
    success = '-s' in args or '--success' in args
    failed = '-f' in args or '--failed' in args
    killed = '-k' in args or '--killed' in args
    for i in _ts_job_ids():
        cmd = $(ts -F @(i)).strip('\n')
        state = $(ts -s @(i))
        if show_id:
            print(f'{i}: {cmd}')
        else:
            print(cmd)


@aliases.register('ts-cancel')
def _ts_cancel_all(args):
    running = '-r' in args or '--running' in args
    allocating = '-a' in args or '--allocating' in args
    allocating_jobs = []
    running_jobs = []
    for i in _ts_job_ids():
        state = $(ts -s @(i))
        if 'allocating' in state:
            allocating_jobs.append(str(i))
        elif 'running' in state:
            running_jobs.append(str(i))
    if allocating:
        print(f"Removing allocating jobs: {', '.join(allocating_jobs)}...")
        for i in allocating_jobs:
            $(ts -r @(i))
    if running:
        print(f"Stopping running jobs: {', '.join(running_jobs)}...")
        for i in running_jobs:
            $(ts -k @(i))
    if not allocating and not running:
        print(f'Running jobs: {", ".join(running_jobs)}')
        print(f'Allocating jobs: {", ".join(allocating_jobs)}')
        print(
            'Use -a/--allocating or -r/--running '
            'to specify which jobs to cancel.')


@aliases.register('ts-rerun-failed')
def _ts_rerun_failed(args):
    import re
    cancelled = '-c' in args or '--cancelled' in args
    jobs = []
    for i in _ts_job_ids():
        if 'running' in $(ts -s @(i)).strip():
            continue
        info = $(ts -i @(i))
        match = re.search(r'exit code (\-?\d+)', info)
        if match is None:
            print(f'Job {i} has no exit code.')
        code = int(match.group(1))
        if code == 0:
            continue
        if not cancelled and code < 0:
            continue
        print(f'Rerunning job {i}...')
        cmd = $(ts -F @(i))
        $(ts @(args) @(cmd))
        $(ts -u @(i))


def _share_folder(args):
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
        brew install gcc tmux btop


def _ubuntu_specific():
    from shutil import which
    xontrib load apt_tabcomplete
    execs = [
        'autojump',
        'colordiff',
        'curl',
        'less',
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
