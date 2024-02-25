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


def add_border(title, hl_title, src, hl_src):
    width = max(len(l) for l in src.split('\n'))
    width = max(width, len(title))
    lines = ['╭─' + '─' * width + '─╮']
    if title:
        lines.append('│ ' + hl_title + ' ' * (width - len(title)) + ' │')
        lines.append('├─' + '─' * width + '─┤')
    for hl_line, line in zip(hl_src.split('\n'), src.split('\n')):
        lines.append('│ ' + hl_line + ' ' * (width - len(line)) + ' │')
    lines.append('╰─' + '─' * width + '─╯')
    return '\n'.join(lines)


def _verbose_source(filename, verbose, verbose_src):
    if verbose or verbose_src:
        from xonsh.lazyimps import pyghooks, pygments
        from pygments.formatters import TerminalFormatter
        lexer = pyghooks.XonshLexer()
        formatter = TerminalFormatter()
        src_fn = f'source @({filename!r})'
        hl_src_fn = pygments.highlight(src_fn, lexer, formatter).strip('\n')
        if not verbose_src:
            print('kxh:', hl_src_fn)
    source @(filename)
    if not verbose_src:
        return
    import tabulate
    from textwrap import dedent
    with open(filename) as f:
        src = dedent(f.read()).strip('\n')
    lexer = pyghooks.XonshLexer()
    hl_src = pygments.highlight(src, lexer, formatter)
    print(add_border(src_fn, hl_src_fn, src, hl_src))


def ssh_host_specific(verbose):
    import os
    import re
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    config_host_rcs = f'{config_home}/kxh/hosts/'
    if not os.path.exists(config_host_rcs):
        cache_home = ${...}.get('XDG_CACHE_HOME', '~/.cache')
        host_rc = f'{cache_home}/kxh/hosts_collated.xsh'
        if os.path.exists(host_rc):
            _verbose_source(host_rc, verbose, verbose)
        return
    host_rcs = config_host_rcs
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
        _verbose_source(rc_file, verbose, verbose)


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


def main():
    if 'KXH_OLD_HOME' in ${...}:
        $PATH.insert(0, '$KXH_OLD_HOME/.local/bin')
    if 'KXH_HOME' in ${...}:
        $PATH.insert(0, '$KXH_HOME/.local/bin')

    debug(${...}.get('KXH_DEBUG'))
    verbose = ${...}.get('KXH_VERBOSE') == '1'
    ssh_host_specific(verbose)
    platform_specific(verbose)
    user_specific(verbose)
