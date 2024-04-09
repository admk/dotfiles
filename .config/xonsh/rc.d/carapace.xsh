import os
import shutil


_carapace_exec = shutil.which('carapace')
if _carapace_exec:
    exec($(@(_carapace_exec) _carapace xonsh))
    # Fix error when using python completer
    XSH.completers.pop('python', None)

# if _carapace_exec:
#     if ${...}.get('KXH_VERBOSE') == '1':
#         print(f'kxh: carapace: using {_carapace_exec!r}')
#     $COMPLETIONS_CONFIRM = True
#     _carapace_src = $(@(_carapace_exec) _carapace xonsh).split('\n')
#     _line_to_patch = [
#         i for i, line in enumerate(_carapace_src)
#         if line.strip().startswith('exec(compile(subprocess.run')][0]
#     _carapace_name = os.path.basename(_carapace_exec)
#     _carapace_src[_line_to_patch] = f"""
#         _src = subprocess.run(
#             [{_carapace_exec!r}, context.command.args[0].value, 'xonsh'],
#             stdout=subprocess.PIPE).stdout.decode('utf-8')
#         _src = _src.replace("Popen(['{_carapace_name}'", "Popen([{_carapace_exec!r}")
#         exec(compile(_src, "", "exec"))
#     """
#     exec('\n'.join(_carapace_src))
#     # Fix error when using python completer
#     XSH.completers.pop('python', None)
#     del _carapace_name, _carapace_src, _line_to_patch
del _carapace_exec
