from shutil import which as _which


def _rc_main():
    import sys
    sys.path.append($XONSH_CONFIG_DIR)
    if 'KXH_OLD_HOME' in ${...}:
        $PATH.insert(0, '$KXH_OLD_HOME/.local/bin')
    if 'KXH_HOME' in ${...}:
        $PATH.insert(0, '$KXH_HOME/.local/bin')

    $XONTRIBS_AUTOLOAD_DISABLED = True

    uname = $(uname).lower().strip()
    platformrc = pf'$XONSH_CONFIG_DIR/rc.d/platform/{uname}.xsh'
    if platformrc.exists():
        execx(f'source {platformrc}')

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
