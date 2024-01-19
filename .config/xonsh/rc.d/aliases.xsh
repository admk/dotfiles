from shutil import which as _which
from xonsh.tools import unthreadable as _unthreadable


def _register_envs_alias(names, envs, cmd=None):
    def _wrapper(args):
        if cmd is not None:
            args = [cmd] + args
        with ${...}.swap(**envs):
            execx(' '.join(args))
    names = [names] if isinstance(names, str) else names
    for name in names:
        aliases.register(name)(_wrapper)


def _register_dep_aliases(dep_aliases):
    for a, cmd in dep_aliases.items():
        if _which(cmd.split(' ')[0]):
            aliases[a] = cmd


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
    'g': 'git',
    'gps': 'git push',
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
    'l': 'ls',
    'll': 'ls -la',
    'ash':
        "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' "
        "-o ExitOnForwardFailure=yes -nNT",
    'ip': 'curl https://ifconfig.co/json' + (' | jq' if _which('jq') else ''),
    'xtb': 'cat $XONSH_TRACEBACK_LOGFILE | less +G',
    'ssh-exit': 'ssh -O exit',
}
_register_dep_aliases({
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


@aliases.register('tmr')
@aliases.register('tmux-reattach')
def _tmux_reattach():
    tm = $(@(_which('which')) 'tmux').strip()
    @(tm) attach-session -d -t $USER 2>/dev/null || \
        @(tm) new-session -s $USER


@aliases.register('pd')
@aliases.register('pydb')
@_unthreadable
def _pydb(args):
    processes = $(lsof -i tcp:5678)
    if processes:
        for proc in processes.split()[1:]:
            proc_out = proc.split(' ')
            for p in proc_out:
                if p.isdigit():
                    if input(f'Kill {p}? [yN]') == 'y':
                        execx(f'kill {p}')
                    else:
                        print('Aborting')
                        return
    # a stupid hack to work around bad file descriptor error
    import gc
    gc.disable()
    $[python -m debugpy --listen 5678 --wait-for-client @(args)]
    gc.enable()


_register_envs_alias('hf-offline', {
    'TRANSFORMERS_OFFLINE': '1',
    'HF_DATASETS_OFFLINE': '1',
    'HF_EVALUATE_OFFLINE': '1',
})


@aliases.register('px')
@aliases.register('proxy')
def _proxy(args):
    envs = {
        'http_proxy': f'http://{$PROXY}',
        'https_proxy': f'http://{$PROXY}',
        'all_proxy': f'socks5://{$PROXY}',
    }
    with ${...}.swap(**envs):
        execx(' '.join(args))

${...}.setdefault('PROXY', '127.0.0.1:7890')


_BASH_ENV = {'SHELL': '/bin/bash'}
_register_envs_alias('ssh', _BASH_ENV, cmd='ssh')
_register_envs_alias('sshuttle', _BASH_ENV, cmd='sshuttle')
