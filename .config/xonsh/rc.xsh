from shutil import which as _which


def verbose_source(filename, verbose, verbose_src):
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


def _kxh_host_specific(verbose):
    import os
    import fnmatch
    from glob import glob
    host = ${...}.get('KXH_HOST', '')
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    host_rcs = f'{config_home}/kxh/hosts/*'
    if verbose:
        print(f'kxh: host={host}')
    verbose_src = True
    for rc in glob(host_rcs):
        if not os.path.isfile(rc):
            continue
        rc_name = os.path.splitext(os.path.basename(rc))[0]
        if not fnmatch.fnmatch(host, rc_name):
            continue
        verbose_source(rc, verbose, verbose_src)


def _kxh_platform_specific(verbose):
    uname = $(uname).lower().strip()
    platform_rc = pf'$XONSH_CONFIG_DIR/rc.d/platform/{uname}.xsh'
    if verbose:
        print(f'kxh: platform={uname}')
    if not platform_rc.exists():
        return
    verbose_source(platform_rc, verbose, False)


def _kxh_user_specific(verbose):
    import os
    import fnmatch
    from glob import glob
    user = ${...}.get('KXH_USER', $USER)
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    user_rc = pf'{config_home}/kxh/users/{user}.xsh'
    if not user_rc.exists():
        return
    verbose_source(user_rc, verbose, verbose)


def _rc_main():
    import sys
    sys.path.append($XONSH_CONFIG_DIR)
    if 'KXH_OLD_HOME' in ${...}:
        $PATH.insert(0, '$KXH_OLD_HOME/.local/bin')
    if 'KXH_HOME' in ${...}:
        $PATH.insert(0, '$KXH_HOME/.local/bin')

    $XONTRIBS_AUTOLOAD_DISABLED = True

    verbose = ${...}.get('KXH_VERBOSE') == '1'
    _kxh_host_specific(verbose)
    _kxh_platform_specific(verbose)
    _kxh_user_specific(verbose)

    $XONTRIB_SH_SHELLS = ['bash', 'sh']
    xontribs = [
        'abbrevs',
        'argcomplete',
        'autoxsh',
        'coreutils',
        'fish_completer',
        'jedi',
        'onepath',
        # 'output_search',
        'pipeliner',
        'readable-traceback',
        'sh',
    ]
    xontrib load -s @(xontribs)
    dep_xontribs = [
        'autojump',
    ]
    for cmd_xtb in dep_xontribs:
        if isinstance(cmd_xtb, str):
            cmd, xtb = cmd_xtb, cmd_xtb
        else:
            cmd, xtb = cmd_xtb
        if !(which @(cmd)):
            xontrib load @(xtb)


_rc_main()
del _kxh_host_specific, _kxh_platform_specific, _kxh_user_specific, _rc_main
