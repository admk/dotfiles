from shutil import which as _which

$PATH += [
    '~/.local/bin',
]

uname = $(uname).lower().strip()
platformrc = pf'$XONSH_CONFIG_DIR/rc.d/platform/{uname}.xsh'
if platformrc.exists():
    execx(f'source {platformrc}')

$XONTRIB_SH_SHELLS = ['bash', 'sh']
$XONTRIBS_AUTOLOAD_DISABLED = True

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
    'auotjump',
]
for cmd_xtb in dep_xontribs:
    if isinstance(cmd_xtb, str):
        cmd, xtb = cmd_xtb, cmd_xtb
    else:
        cmd, xtb = cmd_xtb
    if _which(cmd):
        xontrib load @(xtb)

$MULTILINE_PROMPT = ' '

$AUTO_CD = True
$DOTGLOB = True
$XONSH_SHOW_TRACEBACK = True
$XONSH_TRACEBACK_LOGFILE = f'{$XDG_CACHE_HOME}/xonsh-traceback.log'
$SUGGEST_COMMANDS = False
