$VI_MODE = True


def _custom_keybindings(bindings, **kwargs):
    from prompt_toolkit.keys import Keys
    from prompt_toolkit.key_binding.key_processor import KeyPress
    from prompt_toolkit.filters import ViInsertMode, ViNavigationMode

    @bindings.add('j', 'k', filter=ViInsertMode())
    def _exit_insert_mode(event):
        """
        Map j and k to <Escape>
        in Vi Insert mode.
        """
        event.cli.key_processor.feed(KeyPress(Keys.Escape))

    @bindings.add('c-a', filter=ViInsertMode())
    def _start_of_buffer(event):
        """
        Restore the default behavior of ctrl-a
        to go to the beginning of the line.
        """
        pos = event.app.current_buffer.document.get_start_of_line_position()
        event.app.current_buffer.cursor_position += pos

    @bindings.add('c-e', filter=ViInsertMode())
    def _end_of_buffer_or_insert_suggestion(event):
        """
        Restore the default behavior of ctrl-e
        to go to the end of the line.
        In addition,
        if there is a suggestion available,
        insert it.
        """
        app = event.app
        suggestion_available = (
            app.current_buffer.suggestion is not None
            and len(app.current_buffer.suggestion.text) > 0
            and app.current_buffer.document.is_cursor_at_the_end)
        if suggestion_available:
            suggestion = event.current_buffer.suggestion
            event.current_buffer.insert_text(suggestion.text)
        pos = app.current_buffer.document.get_end_of_line_position()
        app.current_buffer.cursor_position += pos


def _fallback_clipboard(prompter, **kwargs):
    from shutil import which
    commands = ('xclip', 'xsel', 'pbcopy', 'clip')
    if any(which(c) for c in commands):
        return
    from prompt_toolkit.clipboard.in_memory import InMemoryClipboard
    prompter.clipboard = InMemoryClipboard()


if ${...}.get('VI_MODE'):
    events.on_ptk_create(_custom_keybindings)
    events.on_ptk_create(_fallback_clipboard)
del _custom_keybindings, _fallback_clipboard
