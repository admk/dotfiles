import sys
import subprocess
import threading
from typing import List, Union, Optional, TextIO, BinaryIO, Mapping


def _open_file(file_obj: Optional[Union[str, TextIO, BinaryIO]], mode: str, default):
    """Open file if needed, return file object."""
    if file_obj is not None:
        if isinstance(file_obj, str):
            return open(file_obj, mode)
        elif hasattr(file_obj, "read") if "r" in mode else hasattr(file_obj, "write"):
            return file_obj
        else:
            raise ValueError(f"file_obj must be a file path or file object")
    return default


def _close_file_if_needed(file_obj, original_param):
    """Close file if it was opened from a string path."""
    if isinstance(original_param, str) and hasattr(file_obj, "close"):
        file_obj.close()


def _stream_stdin_to_proc(proc, stdin_chunk_size: int, stdin_file):
    """Stream stdin source to subprocess stdin in a separate thread."""
    try:
        # Use a reasonable default chunk size if 0
        chunk_size = stdin_chunk_size if stdin_chunk_size > 0 else 4096
        while True:
            if hasattr(stdin_file, "buffer"):
                chunk = stdin_file.buffer.read(chunk_size)
            else:
                chunk = stdin_file.read(chunk_size)
            if not chunk:
                break
            proc.stdin.write(chunk)
            proc.stdin.flush()
    finally:
        proc.stdin.close()
        _close_file_if_needed(stdin_file, stdin_file)


def _stream_proc_to_stdout(
    proc, chunk_size: int, stdout_file, use_stderr: bool = False
):
    """Stream subprocess stdout/stderr to destination in a separate thread."""
    try:
        # Use a reasonable default chunk size if 0
        actual_chunk_size = chunk_size if chunk_size > 0 else 4096
        stream = proc.stderr if use_stderr else proc.stdout
        while True:
            chunk = stream.read(actual_chunk_size)
            if not chunk:
                break
            if hasattr(stdout_file, "buffer"):
                stdout_file.buffer.write(chunk)
                stdout_file.buffer.flush()
            else:
                stdout_file.write(chunk)
                stdout_file.flush()
    finally:
        _close_file_if_needed(stdout_file, stdout_file)


def _create_stream_thread(target_func, proc, chunk_size, file_obj, *extra_args):
    """Create and start a daemon thread for streaming."""
    thread = threading.Thread(
        target=target_func, args=(proc, chunk_size, file_obj, *extra_args)
    )
    thread.daemon = True
    thread.start()
    return thread


def pipe_through_subprocess(
    cmd: List[str],
    stdin: Optional[Union[str, TextIO, BinaryIO]] = None,
    stdout: Optional[Union[str, TextIO, BinaryIO]] = None,
    stderr: Optional[Union[str, TextIO, BinaryIO]] = None,
    stdin_chunk_size: int = 0,
    stdout_chunk_size: int = 0,
    stderr_chunk_size: int = 0,
    env: Optional[Mapping] = None,
) -> int:
    """
    Pipe stdin through a subprocess command to stdout.

    Args:
        cmd: Command and arguments as list
        stdin_chunk_size: Buffer size for reading stdin
        stdout_chunk_size: Buffer size for writing stdout
        stderr_chunk_size: Buffer size for writing stderr
        stdin: File path or file object to use as stdin instead of sys.stdin
        stdout: File path or file object to use as stdout instead of sys.stdout
        stderr: File path or file object to use as stderr instead of sys.stderr

    Returns:
        Exit code of the subprocess
    """
    # Determine stdin source - automatically detect if stdin is available
    use_stdin = stdin is not None or not sys.stdin.isatty()
    stdin_file = _open_file(stdin, "rb", sys.stdin) if use_stdin else None
    stdout_file = _open_file(stdout, "wb", sys.stdout)
    stderr_file = _open_file(stderr, "wb", sys.stderr)

    proc = subprocess.Popen(
        cmd,
        stdin=None if not use_stdin else subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        bufsize=0,  # Unbuffered
    )

    if use_stdin and proc.stdin is None:
        raise RuntimeError("Failed to create subprocess with stdin")
    if proc.stdout is None:
        raise RuntimeError("Failed to create subprocess with stdout")
    if proc.stderr is None:
        raise RuntimeError("Failed to create subprocess with stderr")

    threads = []

    if use_stdin:
        if proc.stdin is None:
            raise RuntimeError("Failed to create subprocess with stdin")
        threads.append(_create_stream_thread(_stream_stdin_to_proc, proc, stdin_chunk_size, stdin_file))

    threads.append(_create_stream_thread(_stream_proc_to_stdout, proc, stdout_chunk_size, stdout_file))
    threads.append(_create_stream_thread(_stream_proc_to_stdout, proc, stderr_chunk_size, stderr_file, True))
    # Wait for all threads to complete
    for thread in threads:
        thread.join()

    # Wait for process to complete
    return proc.wait()


if __name__ == "__main__":
    cmd = sys.argv[1:]  # Get command from command line arguments
    exit_code = pipe_through_subprocess(cmd)
    sys.exit(exit_code)
