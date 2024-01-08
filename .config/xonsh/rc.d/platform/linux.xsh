xontrib load apt_tabcomplete

aliases |= {
    'ns': 'nvidia-smi',
    'st': 'gpustat -cup',
}

@aliases.register('vd')
def _cuda_visible_devices(args):
    vd, *args = args
    if not args:
        $CUDA_VISIBLE_DEVICES = vd
        return
    with ${...}.swap(CUDA_VISIBLE_DEVICES=vd):
        execx(' '.join(args))
