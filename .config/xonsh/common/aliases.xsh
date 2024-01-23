from shutil import which as _which


def _env_alias(env, cmd=None, setmode='off'):
    if setmode not in ('toggle', 'update', 'off'):
        raise ValueError(f'invalid setmode: {setmode!r}')
    def wrapper(args):
        if callable(env):
            num_args = env.__code__.co_argcount
            envs_args, args = args[:num_args], args[num_args:]
            _env = env(*envs_args)
        else:
            _env = env
        if cmd is not None:
            args = [cmd] + args
        if args:
            with ${...}.swap(**_env):
                execx(' '.join(args))
            return
        if setmode == 'off':
            return
        match = all(${...}.get(k) == v for k, v in _env.items())
        for k, v in _env.items():
            if setmode == 'update' or (setmode == 'toggle' and not match):
                print(f'${k} = {v!r}')
                ${...}[k] = v
            elif setmode == 'toggle' and match:
                print(f'del ${k}')
                del ${...}[k]
            else:
                raise ValueError('Unreachable')
    return wrapper


def register_env_alias(names, cmd=None, setmode='off'):
    def _wrapper(env):
        nonlocal names
        names = [names] if isinstance(names, str) else names
        for name in names:
            aliases.register(name)(_env_alias(env, cmd, setmode))
    return _wrapper


def register_dep_aliases(dep_aliases):
    for a, cmd in dep_aliases.items():
        if _which(cmd.split(' ')[0]):
            aliases[a] = cmd


def bash_like_alias(args):
    import inspect
    from xonsh.lazyimps import pyghooks, pygments
    lexer = formatter = None
    def _format_alias(v):
        if isinstance(v, list):
            return ' '.join(v)
        if inspect.isfunction(v):
            src = _dedent(inspect.getsource(v))
            nonlocal lexer, formatter
            if lexer is None or formatter is None:
                lexer = pyghooks.XonshLexer()
                formatter = pygments.formatters.TerminalFormatter()
            src = pygments.highlight(src, lexer, formatter)
            return f'"""\n{src}"""'
        return v
    if not args:
        args = aliases.keys()
    for a in args:
        print(f'{a} = {_format_alias(aliases[a])}')
