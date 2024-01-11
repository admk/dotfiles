$VI_MODE = True
# $UPDATE_PROMPT_ON_KEYPRESS = True


@events.on_ptk_create
def custom_keybindings(bindings, **kw):
    from prompt_toolkit.keys import Keys
    from prompt_toolkit.key_binding.key_processor import KeyPress
    from prompt_toolkit.filters import ViInsertMode

    @bindings.add('j', 'k', filter=ViInsertMode())
    def _(event):
        event.cli.key_processor.feed(KeyPress(Keys.Escape))

    @bindings.add('c-a', filter=ViInsertMode())
    def _(event):
        pos = event.app.current_buffer.document.get_start_of_line_position()
        event.app.current_buffer.cursor_position += pos

    # @bindings.add('c-e', filter=ViInsertMode())
    # def _(event):
    #     # does not take into account the prefilled prompt from history
    #     pos = event.app.current_buffer.document.get_end_of_line_position()
    #     event.app.current_buffer.cursor_position += pos
