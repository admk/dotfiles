def debug(enable):
    if enable != '1':
        return
    $XONSH_DEBUG = True
    $XONSH_SHOW_TRACEBACK = True
    try:
        import ipdb
        ipdb.set_trace()
        return
    except ImportError:
        pass
    try:
        import pdb
        pdb.set_trace()
        return
    except ImportError:
        pass
    print('kxh: debugger (debugpy, ipdb, or pdb) not found.')


def _verbose_source(filename, verbose, verbose_src):
    if verbose or verbose_src:
        from xonsh.lazyimps import pyghooks, pygments
        from pygments.formatters import TerminalFormatter
        lexer = pyghooks.XonshLexer()
        formatter = TerminalFormatter()
        src = f'source @({filename!r})'
        src = pygments.highlight(src, lexer, formatter).strip('\n')
        print(f'kxh: {src}')
    source @(filename)
    if not verbose_src:
        return
    from textwrap import indent, dedent
    with open(filename) as f:
        src = indent(dedent(f.read()), '  ')
    lexer = pyghooks.XonshLexer()
    src = pygments.highlight(src, lexer, formatter)
    print('\n' + src.strip('\n') + '\n')


def host_specific(verbose):
    import os
    import re
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    config_host_rcs = f'{config_home}/kxh/hosts/'
    if os.path.exists(config_host_rcs):
        host_rcs = config_host_rcs
    else:
        cache_home = ${...}.get('XDG_CACHE_HOME', '~/.cache')
        host_rcs = f'{cache_home}/kxh/hosts/'
    host = ${...}.get('KXH_HOST', '')
    if verbose:
        print(f'kxh: host={host}')
    verbose_src = True
    for rc in os.listdir(host_rcs):
        rc_file = os.path.join(host_rcs, rc)
        if not os.path.isfile(rc_file):
            continue
        rc_name = os.path.splitext(rc)[0]
        if not re.match(rc_name, host):
            continue
        _verbose_source(rc_file, verbose, verbose_src)


def platform_specific(verbose):
    uname = $(uname).lower().strip()
    platform_rc = pf'$XONSH_CONFIG_DIR/rc.d/platform/{uname}.xsh'
    if verbose:
        print(f'kxh: platform={uname}')
    if not platform_rc.exists():
        return
    _verbose_source(platform_rc, verbose, False)


def user_specific(verbose):
    import os
    import fnmatch
    from glob import glob
    user = ${...}.get('KXH_USER', $USER)
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    user_rc = pf'{config_home}/kxh/users/{user}.xsh'
    if not user_rc.exists():
        return
    _verbose_source(user_rc, verbose, verbose)
