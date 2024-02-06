import platform

from common.aliases import register_env_alias


aliases |= {
    'ns': 'nvidia-smi',
    'st': 'gpustat -cup',
}


@register_env_alias('vd', setmode='toggle')
def _cuda_visible_devices(args):
    devices, *args = args
    return args, {'CUDA_VISIBLE_DEVICES': devices}


@aliases.register('sgpus')
def _sgpus(args):
    import tabulate
    gres = $(scontrol show node | grep -e NodeName -e State -e CfgTRES -e AllocTRES)
    info = {}
    states = {}
    for l in gres.splitlines():
        l = l.strip()
        if l.startswith('NodeName='):
            node = l.replace('NodeName=', '').split(' ')[0]
            continue
        if l.startswith('State='):
            states[node] = l.split()[0].replace('State=', '')
        if l.startswith('CfgTRES='):
            l = l.replace('CfgTRES=', '')
            t = 'total'
        elif l.startswith('AllocTRES='):
            l = l.replace('AllocTRES=', '')
            t = 'alloc'
        else:
            continue
        if not l:
            continue
        for g in l.split(','):
            k, v = g.split('=')
            if not k.startswith('gres/'):
                continue
            if k == 'gres/gpu':
                continue
            k = k.replace('gres/gpu:', '')
            sub_info = info.setdefault(k, {}).setdefault(node, {})
            sub_info[t] = sub_info.get(t, 0) + int(v)
    tab_info = []
    for g, sub_info in info.items():
        tab_info += [
            (k, states[k], g, f"{i.get('alloc', 0)}/{i.get('total', 0)}")
            for k, i in sub_info.items()]
    table = tabulate.tabulate(
        tab_info, headers=['Node', 'State', 'GPU', 'Alloc/Total'],
        tablefmt="rounded_outline")
    print(table)


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
        brew install gcc tmux btop


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
