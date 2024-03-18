from shutil import which as _which
from xonsh.tools import unthreadable as _unthreadable

from common.aliases import (
    register_dep_aliases, register_env_alias, bash_like_alias)


aliases.register('alias')(bash_like_alias)

aliases |= {
    '-': 'cd -',
    'xup':
        'xpip install -U pip && '
        'xpip install -U -r $XONSH_CONFIG_DIR/requirements.txt',
    'xr': 'xonsh-reset',
    'c': 'clear',
    'o': 'open',
    'e': '$EDITOR',
    'b': 'brew',
    'bup': 'brew update && brew upgrade && brew cleanup',
    'dl': 'curl --location --fail --continue-at - --progress-bar',
    'g': 'git',
    'gps': 'git push',
    'gpsf': 'git push --force-with-lease',
    'gpl': 'git pull',
    'gc': 'git commit',
    'gs': 'git status',
    'ga': 'git add',
    'gd': 'git diff',
    'gds': 'git diff --staged',
    'gl': 'git lg',
    'gw': 'git web',
    'grep': 'grep --color=auto',
    'http-here': 'python -m http.server',
    'k': 'kxh',
    'py': 'python',
    'ipy': 'ipython',
    'pio': 'python3 -m pip install --index-url https://pypi.org/simple/',
    'l': 'ls',
    'la': 'ls -a',
    'll': 'ls -la',
    'ash':
        "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' "
        "-o ExitOnForwardFailure=yes -nNT",
    'ip': 'curl https://ifconfig.co/json' + (' | jq' if _which('jq') else ''),
    'xtb': 'cat $XONSH_TRACEBACK_LOGFILE | less +G',
    'ssh-exit': 'ssh -O exit',
    'vim': f"{_which('vim')} -u $KXH_HOME/.config/nvim/init.vim",
    'clash-start': 'klash $CLASH_SUBSCRIPTION --config $XDG_CONFIG_HOME/kxh/share/clash.yaml',
}
register_dep_aliases({
    'rcp': 'rsync --progress --recursive --archive',
    'ls': 'eza',
})


@aliases.register(',')
@aliases.register(',,')
@aliases.register(',,,')
@aliases.register(',,,,')
def _supercomma():
    cd @("../" * (len($__ALIAS_NAME)))


@aliases.register('pwgen')
def _pwgen(args):
    import argparse
    import math
    import secrets
    import string
    parser = argparse.ArgumentParser(
        prog='pwgen', description='Generate a random password')
    parser.add_argument('length', type=int, nargs='?', default=20)
    parser.add_argument('-b', '--block-size', type=int, default=5)
    args = parser.parse_args(args)
    if args.block_size < 1:
        raise ValueError('block size must be positive.')
    args.length = max(args.length, args.block_size)
    # args.length = math.ceil(args.length / args.block_size) * args.block_size
    alphabet = string.ascii_letters + string.digits
    password = ''.join(secrets.choice(alphabet) for i in range(args.length))
    return '-'.join(
        password[i:i + args.block_size]
        for i in range(0, args.length, args.block_size))


@aliases.register('xf')
def _refresh():
    xonsh-reset
    __xonsh__.env.undo_replace_env()
    for f in $XONSHRC:
        if pf'{f}'.exists():
            execx(f'source {f}')
    execx("source $XONSH_CONFIG_DIR/rc.d/*.xsh")


@aliases.register('tmux')
def _tmux(args):
    tm = $(@(_which('which')) 'tmux').strip()
    socket = $(@(tm) -V).strip().replace('tmux ', '')
    @(tm) -L @(socket) @(args)


@aliases.register('tmr')
@aliases.register('tmux-reattach')
def _tmux_reattach(args):
    tm = $(@(_which('which')) 'tmux').strip()
    socket = $(@(tm) -V).strip().replace('tmux ', '')
    name = args[0] if args else $USER
    @(tm) -L @(socket) attach-session -d -t @(name) 2>/dev/null || \
        @(tm) -L @(socket) new-session -s @(name)


@aliases.register('pd')
@aliases.register('pydb')
@_unthreadable
def _pydb(args, stdin=None):
    port = 5678
    processes = $(lsof -i tcp:@(port)) if _which('lsof') else None
    if processes:
        pids = []
        for proc in processes.split()[1:]:
            proc_out = proc.split(' ')
            for p in proc_out:
                if not p.isdigit():
                    continue
                pids.append(p)
        if pids:
            ask = f'Process(es) {pids} are using port {port}. Kill? [yN]'
            if input(ask) == 'y':
                for p in pids:
                    execx(f'kill -- -{p}')
            else:
                print('Aborting')
                return
    print('Waiting for client to attach to 5678...')
    if stdin is not None:
        echo @(stdin) | python -m debugpy --listen 5678 --wait-for-client @(args)
    else:
        python -m debugpy --listen 5678 --wait-for-client @(args)


@register_env_alias('hfoff', setmode='toggle')
def _hf_env(args):
    return args, {
        'TRANSFORMERS_OFFLINE': '1',
        'HF_DATASETS_OFFLINE': '1',
        'HF_EVALUATE_OFFLINE': '1',
    }


@register_env_alias(['px', 'proxy'], setmode='toggle')
def _proxy(args):
    return args, {
        'http_proxy': f'http://{$PROXY}',
        'https_proxy': f'http://{$PROXY}',
        'all_proxy': f'socks5://{$PROXY}',
    }
${...}.setdefault('PROXY', '127.0.0.1:7890')


_BASH_ENV = lambda args: (args, {'SHELL': '/bin/bash'})
register_env_alias('ssh', cmd='ssh')(_BASH_ENV)
register_env_alias('sshuttle', cmd='sshuttle')(_BASH_ENV)
