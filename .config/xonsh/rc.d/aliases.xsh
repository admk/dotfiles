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
    'gP': 'git push',
    'gPf': 'git push --force-with-lease',
    'gp': 'git pull',
    'gc': 'git commit',
    'gca': 'git commit --amend --no-edit',
    'gs': 'git status',
    'ga': 'git add',
    'gd': 'git diff',
    'gds': 'git diff --staged',
    'gl': 'git lg',
    'gw': 'git web',
    'grep': 'grep --color=auto',
    'http-here': 'python -m http.server',
    'k': 'kxh',
    'nvr': '$KXH_CONDA_PREFIX/bin/nvr',
    'py': 'python',
    'ipy': 'ipython',
    'pio': 'python3 -m pip install --index-url https://pypi.org/simple/',
    'l': 'ls',
    'la': 'ls -a',
    'll': 'ls -la',
    'lg': 'lazygit',
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
    'cat': 'bat',
    'rcp': 'rsync --progress --recursive --archive',
    'ls': ['lsd', 'eza'],
    'cs': 'gh copilot suggest -t shell',
    'ce': 'gh copilot explain',
    'wttr': 'curl wttr.in',
})


@aliases.register(',')
@aliases.register(',,')
@aliases.register(',,,')
@aliases.register(',,,,')
def _supercomma():
    cd @("../" * (len($__ALIAS_NAME)))


@aliases.register('g')
@aliases.return_command
def _git(args):
    if not args:
        return ['git', 'status']
    return ['git', *args]


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


@aliases.register('y')
def _yy(args):
    tmp = $(mktemp -t 'yazi-cwd.XXXXXX')
    yazi @(args) --cwd-file @(tmp)
    cwd = $(cat -- @(tmp))
    if os.path.isdir(cwd) and cwd != $PWD:
        cd @(cwd)
    rm -f @(tmp)


@aliases.register('tmux')
def _tmux(args):
    tm = $(@(_which('which')) 'tmux').strip()
    if not tm:
        print('tmux not found.')
        return 1
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
    port = ${...}.get('PYDB_PORT')
    if not port:
        import socket
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('', 0))
            port = s.getsockname()[1]
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
                    execx(f'kill -- {p}')
            else:
                print('Aborting')
                return
    if 'NVIM' in ${...}:
        client = 'nvim'
        # auto-attach to debugpy in nvim
        cmd = f"<c-/>;DapPyAttach({port})<CR>"
        execx(f'nvr --remote-send "{cmd}"')
    else:
        client = 'client'
    print(f'Waiting for {client} to attach to {port}...')
    with ${...}.swap(WANDB_MODE='disabled'):
        if stdin is not None:
            echo @(stdin) | \
                python -m debugpy --listen @(port) --wait-for-client @(args)
        else:
            python -m debugpy --listen @(port) --wait-for-client @(args)

# ${...}.setdefault('PYDB_PORT', 5678)


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


@aliases.register('ssh-exit-all')
def ssh_exit_all():
    home = ${...}.get('KXH_OLD_HOME', $HOME)
    socket_dir = pf'{home}/.ssh/control_socket'
    sockets = os.listdir(socket_dir)
    if not sockets:
        print('No sockets found.')
        return
    print(f'Found {len(sockets)} sockets:')
    for p in sockets:
        print(f'  {p}')
    if input(f'Close all sockets? [yN] ') != 'y':
        print('Abort.')
        return
    for p in sockets:
        p = socket_dir / p
        if p.exists():
            execx(f'ssh -O exit -o ControlPath="{p}" bogus')


@aliases.register('ssh-forward')
def ssh_forward(args):
    import argparse
    parser = argparse.ArgumentParser(
        prog='ssh-forward',
        description='Forward a remote port to a local port.')
    parser.add_argument(
        'host', help='Remote host to forward port to.')
    parser.add_argument(
        'remote_port', type=int, help='Remote port to forward.')
    parser.add_argument(
        'local_port', type=int, nargs='?', help='Local port to forward to.')
    parser.add_argument(
        '-c', '--cancel', action='store_true', help='Close existing connection.')
    parser.add_argument(
        '-b', '--browse', action='store_true', help='Open browser to remote port.')
    args = parser.parse_args(args)
    if args.local_port is None:
        args.local_port = args.remote_port
    route = f'{args.local_port}:localhost:{args.remote_port}'
    r = !(lsof -i tcp:@(args.local_port))
    if args.cancel:
        if r:
            r = !(@thread ssh -O cancel -L @(route) @(args.host) 2>&1)
            if not r:
                print(r.output)
                print('Failed to cancel existing connection.')
                return 1
        else:
            print(f'Local port {args.local_port} is not in use.')
            return 1
        return 0
    if r:
        print(r.output)
        print(f'Local port {args.local_port} is in use.')
    r = !(@thread ssh -fNT -O forward -L @(route) -o ExitOnForwardFailure=yes @(args.host) 2>&1)
    if not r:
        print(r.output)
        print(r.errors)
        print('Failed to forward port to remote host.')
        return 1
    print(
        f'Forwarded remote port {args.remote_port} '
        f'to local port {args.local_port}.')
    if args.browse:
        execx(f'open http://localhost:{args.local_port}')
