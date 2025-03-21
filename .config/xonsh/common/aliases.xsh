from functools import wraps as _wraps
from textwrap import dedent as _dedent
from shutil import which as _which


def _env_exec(env, cmd=None, setmode='off'):
    if setmode not in ('toggle', 'update', 'off'):
        raise ValueError(f'invalid setmode: {setmode!r}')
    def wrapper(args, stdin=None, stdout=None, stderr=None, spec=None):
        args, _env = env(args)
        if cmd is not None:
            args = ([cmd] if isinstance(cmd, str) else cmd) + args
        if args:
            with ${...}.swap(**_env):
                args = [repr(a) if ' ' in a else a for a in args]
                # FIXME:
                # 1. doesn't work with pipes
                # 2. doesn't return error codes
                from xonsh.procs.pipelines import STDOUT_CAPTURE_KINDS
                if spec.captured in STDOUT_CAPTURE_KINDS:
                    return $(@(args))
                if not spec.last_in_pipeline:
                    return $(@(args))
                return execx(' '.join(args))
        if setmode == 'off':
            return
        match = all(${...}.get(k) == v for k, v in _env.items())
        for k, v in _env.items():
            if setmode == 'update' or (setmode == 'toggle' and not match):
                if ${...}.get('KXH_VERBOSE') == '1':
                    print(f'${k} = {v!r}')
                if not v:
                    if k in ${...}:
                        del ${...}[k]
                else:
                    ${...}[k] = v
            elif setmode == 'toggle' and match:
                if ${...}.get('KXH_VERBOSE') == '1':
                    print(f'del ${k}')
                del ${...}[k]
            else:
                raise ValueError('Unreachable')
    return wrapper


def register_env_alias(names, cmd=None, setmode='off'):
    import inspect
    def wrapper(env):
        pnames = [names] if isinstance(names, str) else names
        for name in pnames:
            wrapped = _env_exec(env, cmd, setmode)
            # FIXME: functools.wraps(env)(wrapped)
            # doesn't work with xonsh aliases
            wrapped.src = inspect.getsource(env)
            aliases.register(name)(wrapped)
    return wrapper


def register_dep_aliases(dep_aliases):
    for a, cmd in dep_aliases.items():
        cmds = [cmd] if isinstance(cmd, str) else cmd
        for cmd in cmds:
            if not _which(cmd.split(' ')[0]):
                continue
            aliases[a] = cmd
            break


def bash_like_alias(args):
    import inspect
    try:
        from xonsh.lib.lazyimps import pyghooks, pygments
    except ImportError:
        from xonsh.lazyimps import pyghooks, pygments
    from xonsh.aliases import ExecAlias, FuncAlias
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
        # elif hasattr(v, 'src'):
        elif isinstance(v, FuncAlias):
            if hasattr(v.func, 'src'):
                src = v.func.src
            else:
                src = _dedent(inspect.getsource(v.func))
            src = _syntax_highlight(src)
            return f'"{src}"' if "\n" not in src else f'"""\n{src}\n"""'
        elif inspect.isfunction(v):
            src = _syntax_highlight(_dedent(inspect.getsource(v.func.src)))
            return f'"""\n{src}\n"""'
        return _syntax_highlight(str(v))
    if not args:
        args = aliases.keys()
    for a in args:
        print(f'{a} = {_format_alias(aliases[a])}')
