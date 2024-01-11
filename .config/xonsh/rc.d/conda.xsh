def _conda_main():
    import sys
    from types import ModuleType
    from shutil import which
    conda_path = which("conda")
    if not conda_path:
        return
    mod = ModuleType('xontrib.conda', f'Autogenerated from {__file__!r}.')
    __xonsh__.execer.exec(
        $(@(conda_path) "shell.xonsh" "hook"),
        glbs=mod.__dict__,
        filename="$(@(conda_path) shell.xonsh hook)")
    sys.modules["xontrib.conda"] = mod


_conda_main()
del _conda_main
