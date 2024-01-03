$PATH += [
    '~/.local/bin',
]

uname = $(uname).lower().strip()
platformrc = pf'$XONSH_CONFIG_DIR/rc.d/platform/{uname}.xsh'
if platformrc.exists():
    execx(f'source {platformrc}')

$XONTRIB_SH_SHELLS = ['bash', 'sh']

xontribs = [
    'argcomplete',
    'autoxsh',
    'autojump',
    'abbrevs',
    'sh',
    'pipeliner',
    'jedi',
    'fish_completer'
]
xontrib load -s @(xontribs)

execx($(starship init xonsh))
$MULTILINE_PROMPT = ' '

$AUTO_CD = True
$DOTGLOB = True
$XONSH_SHOW_TRACEBACK = False
$SUGGEST_COMMANDS = False
