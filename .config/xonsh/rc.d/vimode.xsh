from prompt_toolkit.keys import Keys
from prompt_toolkit.key_binding import vi_state, KeyBindings
from prompt_toolkit.key_binding.key_processor import KeyPress
from prompt_toolkit.filters import ViInsertMode


$VI_MODE = True
# $UPDATE_PROMPT_ON_KEYPRESS = True

bindings = KeyBindings()

@events.on_ptk_create
def custom_keybindings(bindings, **kw):
    @bindings.add('j', 'k', filter=ViInsertMode())
    def _(event):
        event.cli.key_processor.feed(KeyPress(Keys.Escape))
