from shutil import which as _which


aliases |= {
    '-': 'cd -',
    'xup': 'xpip install -U pip && xpip install -U git+https://github.com/xonsh/xonsh',
    'xr': 'xonsh-reset',
    'c': 'clear',
    'o': 'open',
    'e': '$EDITOR',
    'br': 'brew',
    'brup': 'brew update && brew upgrade && brew cleanup',
    'g': 'git',
    'gc': 'git commit',
    'gs': 'git status',
    'ga': 'git add',
    'gd': 'git diff',
    'gds': 'git diff --staged',
    'gl': 'git lg',
    'py': 'python',
    'ipy': 'ipython',
    'grep': 'grep --color=auto',
    'ash':
        "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' "
        "-o ExitOnForwardFailure=yes -nNT",
    'ip': 'curl -s https://ifconfig.co/json' + (' | jq' if _which('jq') else ''),
}
dep_aliases = {
    'cp': 'rsync --progress --recursive --archive',
    'ls': 'eza',
}
for a, cmd in dep_aliases.items():
    if _which(cmd.split(' ')[0]):
        aliases[a] = cmd


@aliases.register(',')
@aliases.register(',,')
@aliases.register(',,,')
@aliases.register(',,,,')
def _supercomma():
    cd @("../" * (len($__ALIAS_NAME)))


@aliases.register('xf')
def _refresh():
    xonsh-reset
    for f in $XONSHRC:
        if pf'{f}'.exists():
            execx(f'source {f}')
    execx("source $XONSH_CONFIG_DIR/rc.d/*.xsh")


@aliases.register("tr")
@aliases.register("tmux-reattach")
def _tmux_reattach():
    tmux attach-session -d -t $USER 2>/dev/null || tmux new-session -s $USER


@aliases.register('pd')
@aliases.register('pydb')
def _pydb(args):
    processes = $(lsof -i :5678)
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
    args = ' '.join(args)
    execx(f"python -m debugpy --listen 5678 --wait-for-client {args}")


def _register_envs_alias(name, envs):
    @aliases.register(name)
    def _wrapper(args):
        with ${...}.swap(**envs):
            execx(' '.join(args))


_register_envs_alias('hf-offline', {
    'TRANSFORMERS_OFFLINE': '1',
    'HF_DATASETS_OFFLINE': '1',
    'HF_EVALUATE_OFFLINE': '1',
})
_register_envs_alias('proxy', {
    'http_proxy': 'http://127.0.0.1:7890',
    'https_proxy': 'http://127.0.0.1:7890',
    'all_proxy': 'socks5://127.0.0.1:7890',
})
