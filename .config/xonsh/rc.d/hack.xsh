def _bad_file_descriptor_hack():
    # A hack for the annoying bad file descriptor error
    import gc
    gc.disable()

    @events.on_postcommand
    def _on_postcommand(cmd, rtn, out, ts):
        gc.collect()


_bad_file_descriptor_hack()
del _bad_file_descriptor_hack


def _indentation_hack():
    @events.on_transform_command
    def _on_transform_command(cmd):
        indent = 1000
        lines = cmd.splitlines()
        if len(lines) == 1:
            return cmd
        for i, line in enumerate(lines):
            if i == 0:
                first_indent = line.rstrip().endswith(':')
                continue
            line_len = len(line)
            strip_len = len(line.lstrip())
            if line_len == strip_len:
                return cmd
            indent = min(indent, line_len - strip_len)
        if first_indent:
            indent = max(0, indent - 4)
        cmd = '\n'.join([lines[0]] + [line[indent:] for line in lines[1:]])
        return cmd


_indentation_hack()
del _indentation_hack
