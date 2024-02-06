from shutil import which as _which


def _xontrib_load():
    $XONTRIBS_AUTOLOAD_DISABLED = True
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


def _rc_main():
    import os
    import sys
    sys.path.append(os.path.join($XDG_CONFIG_HOME, 'xonsh'))
    from common import kxh
    kxh.main()


_rc_main()
_xontrib_load()
del _rc_main, _xontrib_load
