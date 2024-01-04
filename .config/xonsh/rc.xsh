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
    'autojump',
    'autoxsh',
    'coreutils',
    'fish_completer',
    'jedi',
    'pipeliner',
    'sh',
]
xontrib load -s @(xontribs)

$MULTILINE_PROMPT = ' '

$AUTO_CD = True
$DOTGLOB = True
$XONSH_SHOW_TRACEBACK = False
$SUGGEST_COMMANDS = False
