from functools import wraps as _wraps
from textwrap import dedent as _dedent
from shutil import which as _which


def _env_exec(env, cmd=None, setmode='off'):
    if setmode not in ('toggle', 'update', 'off'):
        raise ValueError(f'invalid setmode: {setmode!r}')
    def wrapper(args):
        args, _env = env(args)
        if cmd is not None:
            args = [cmd] + args
        if args:
            with ${...}.swap(**_env):
                args = [repr(a) if ' ' in a else a for a in args]
                # FIXME doesn't work with pipes
                return execx(' '.join(args))
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
    def wrapper(env):
        nonlocal names
        names = [names] if isinstance(names, str) else names
        for name in names:
            aliases.register(name)(_wraps(env)(_env_exec(env, cmd, setmode)))
    return wrapper


def register_dep_aliases(dep_aliases):
    for a, cmd in dep_aliases.items():
        if _which(cmd.split(' ')[0]):
            aliases[a] = cmd


def bash_like_alias(args):
    import inspect
    from xonsh.lazyimps import pyghooks, pygments
    from xonsh.aliases import ExecAlias
    lexer = formatter = None
    def _syntax_highlight(v):
        nonlocal lexer, formatter
        if lexer is None or formatter is None:
            lexer = pyghooks.XonshLexer()
            formatter = pygments.formatters.TerminalFormatter()
        return pygments.highlight(v, lexer, formatter).rstrip('\n')
    def _format_alias(v):
        if isinstance(v, list):
            src = _syntax_highlight(' '.join(v))
            return f'"{src}"'
        elif inspect.isfunction(v):
            src = _syntax_highlight(_dedent(inspect.getsource(v)))
            return f'"""\n{src}\n"""'
        elif isinstance(v, ExecAlias):
            src = _syntax_highlight(v.src)
            return f'"{src}"'
        return _syntax_highlight(str(v))
    if not args:
        args = aliases.keys()
    for a in args:
        print(f'{a} = {_format_alias(aliases[a])}')