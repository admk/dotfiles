def debug(enable):
    if enable != '1':
        return
    $XONSH_DEBUG = True
    $XONSH_SHOW_TRACEBACK = True
    $XONSH_TRACE_SUBPROC = True
    try:
        import debugpy
    except ImportError:
        pass
    else:
        debugpy.listen(5678)
        print('kxh shell ==> debugger (debugpy) listening on port 5678.')
        debugpy.wait_for_client()
        return
    try:
        import ipdb as debugger
    except ImportError:
        import pdb as debugger
    except ImportError:
        pass
    else:
        debugger.set_trace()
        return
    print('kxh shell ==> debugger (debugpy, ipdb, or pdb) not found.')


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


def _verbose_source(filename, verbose, verbose_src, dec_key=None):
    if verbose or verbose_src:
        from xonsh.lazyimps import pyghooks, pygments
        from pygments.formatters import TerminalFormatter
        lexer = pyghooks.XonshLexer()
        formatter = TerminalFormatter()
        src_fn = f'source @({filename!r})'
        hl_src_fn = pygments.highlight(src_fn, lexer, formatter).strip('\n')
        if not verbose_src:
            print('kxh shell ==>', hl_src_fn)
    if dec_key is not None:
        from cryptography.fernet import Fernet
        with open(filename, 'r', encoding='utf-8') as f:
            enc_src = f.read().encode('utf-8')
            src_text = Fernet(dec_key).decrypt(enc_src).decode('utf-8')
            src_text = src_text.strip('\n')
        execx(src_text)
    else:
        source @(filename)
    if not verbose_src:
        return
    import tabulate
    from textwrap import dedent
    if dec_key is None:
        with open(filename) as f:
            src_text = dedent(f.read()).strip('\n')
    lexer = pyghooks.XonshLexer()
    hl_src_text = pygments.highlight(src_text, lexer, formatter)
    print(add_border(src_fn, hl_src_fn, src_text, hl_src_text))


def ssh_host_specific(verbose):
    import os
    import re
    config_home = ${...}.get('XDG_CONFIG_HOME', '~/.config')
    config_host_rcs = f'{config_home}/kxh/hosts/'
    if not os.path.exists(config_host_rcs):
        if 'SSH_CONNECTION' not in ${...}:
            print(f'kxh shell ==> path {config_host_rcs!r} does not exist.')
            return
        cache_home = ${...}.get('XDG_CACHE_HOME', '~/.cache')
        host_rc = f'{cache_home}/kxh/hosts_collated.xsh.enc'
        if os.path.exists(host_rc):
            key = f'{cache_home}/kxh/key'
            if not os.path.exists(key):
                print(f'kxh shell ==> missing key to decrypt {host_rc!r}.')
                return
            key = open(key, 'r', encoding='utf-8').read().strip()
            _verbose_source(host_rc, verbose, verbose, key)
        return
    host_rcs = config_host_rcs
    host = ${...}.get('KXH_HOST', '')
    if verbose:
        print(f'kxh shell ==> host={host}')
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
        print(f'kxh shell ==> platform={uname}')
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


def git_config(config):
    gitconf = str(p'$HOME/.gitconfig')
    for k, v in config.items():
        ev = $(git config -f @(gitconf) --get @(k)).strip()
        if ev == v:
            continue
        git config -f @(gitconf) @(k) @(v)


def main():
    if 'KXH_OLD_HOME' in ${...}:
        $PATH.insert(0, '$KXH_OLD_HOME/.local/bin')
    if 'KXH_HOME' in ${...}:
        $PATH.insert(0, '$KXH_HOME/.local/share/bin')
        $PATH.insert(0, '$KXH_HOME/.local/bin')

    debug(${...}.get('KXH_DEBUG'))
    verbose = ${...}.get('KXH_VERBOSE') == '1'
    ssh_host_specific(verbose)
    platform_specific(verbose)
    user_specific(verbose)
