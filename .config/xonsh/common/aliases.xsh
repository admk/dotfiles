from shutil import which as _which


def _envs_alias(envs, cmd=None, settable=False):
    def wrapper(args):
        if callable(envs):
            num_args = envs.__code__.co_argcount
            envs_args, args = args[:num_args], args[num_args:]
            _envs = envs(*envs_args)
        if cmd is not None:
            args = [cmd] + args
        if args:
            with ${...}.swap(**_envs):
                execx(' '.join(args))
            return
        if not settable:
            return
        match = all(${...}.get(k) == v for k, v in _envs.items())
        for k, v in _envs.items():
            if not match:
                print(f'${k} = {v!r}')
                ${...}[k] = v
            else:
                print(f'del ${k}')
                del ${...}[k]
    return wrapper


def _register_envs_alias(names, envs, cmd=None, settable=False):
    names = [names] if isinstance(names, str) else names
    for name in names:
        aliases.register(name)(_envs_alias(envs, cmd, settable))


def _register_dep_aliases(dep_aliases):
    for a, cmd in dep_aliases.items():
        if _which(cmd.split(' ')[0]):
            aliases[a] = cmd
