def _kxh_main():
    host = ${...}.get('KXH_HOST')
    if not host:
        return
    import os
    import fnmatch
    from glob import glob
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    kxh_rcs = f'{config_home}/kxh/*'
    for rc in glob(kxh_rcs):
        if not os.path.isfile(rc):
            continue
        rc_name = os.path.splitext(os.path.basename(rc))[0]
        print(host, rc_name)
        if fnmatch.fnmatch(host, rc_name):
            if ${...}.get('KXH_VERBOSE') == '1':
                print(f'kxh: source {rc}')
            execx(f'source {rc}')


_kxh_main()
del _kxh_main
