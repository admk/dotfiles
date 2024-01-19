def _bad_file_descriptor_hack():
    # A hack for the annoying bad file descriptor error
    import gc
    gc.disable()

    @events.on_postcommand
    def _on_postcommand(cmd, rtn, out, ts):
        gc.collect()


_bad_file_descriptor_hack()
del _bad_file_descriptor_hack
