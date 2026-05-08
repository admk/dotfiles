# Xitong's Dot Files

This repository is a portable,
mostly XDG-style home directory.
It is not only a small set of declarative dotfiles;
it is also a live working shell environment
with helper scripts,
tool state,
and a remote-sync workflow.

The main ideas are:

- personalized app configs live under `.config/`
- `kxh` syncs this tree to remote SSH hosts
- Xonsh is the interactive shell on both local and remote setups
- `.local/bin/_kxh_init` bootstraps the shell runtime
- uv provides the isolated Python/Xonsh environment
- Ghostty delegates tab management to `tmux`
- `tmux/prewarm/bin/prewarm` keeps a warm spare shell ready

## Bootstrap

Clone into `~/.kxh`
and run the bootstrap entrypoint:

```shell
cd ~ && git clone https://github.com/admk/dotfiles .kxh && .kxh/.local/bin/kxh +s
```

For remote usage,
the normal workflow is to connect through `kxh`
so the same dotfile tree is synced to the target host
before starting the shell.

## Top-Level Layout

```text
~/.kxh/
├── .config/         # main XDG config tree
├── .local/bin/      # launchers and helper scripts
├── .venv/           # hermetic Python + Xonsh runtime
├── .cache/          # caches shared by local tools
├── .private.git/    # private overlay repo synced with the public tree
├── .gitconfig       # classic non-XDG Git entrypoint
├── .vimrc           # classic Vim entrypoint
└── README.md
```

Most of the hand-maintained configuration lives in `.config/`.
The rest of the tree exists
to make that config portable, bootstrappable, and usable
on remote machines.

## Portable Shell Model

### `kxh`

`kxh` is the transport layer for this setup.
It is responsible for syncing the dotfile tree,
passing selected environment variables,
and starting the shell on the target machine.

- `.local/bin/kxh` is the main CLI entrypoint
- `.config/kxh/config.toml`
  stores repo URLs, sync settings, default mode, and env passthrough
- `.private.git/`
  acts as a private overlay on top of the public repo
- supported runtime modes
  are `hermetic`, `semi-hermetic`, and `non-hermetic`

The default mode in this repo is `hermetic`,
which means the synced tree
can behave like its own small home directory.

### `_kxh_init`

`.local/bin/_kxh_init`
is the bootstrap script that actually starts the shell.
It does the heavy lifting:

- sets `KXH_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`,
  and related variables
- chooses the runtime mode
  (`hermetic`, `semi-hermetic`, or `non-hermetic`)
- installs uv and `starship` if they are missing
- syncs the Xonsh runtime into `.venv/`
- creates `~/.local/bin/xh` as a convenient shell entrypoint
- starts Xonsh directly,
  or routes through the prewarmer when enabled

In practice,
this script is the reason a fresh remote host
can be turned into a usable shell environment quickly.

### uv

uv is the bootstrap runtime for shell environments.
This repo uses it as a self-contained Python base
so that Xonsh and shell-side Python dependencies
do not need to rely on the remote machine's system Python.

- `.venv/` holds the actual local Python/Xonsh environment
- `pyproject.toml` declares the shell runtime dependencies
- `.config/uv/uv.toml` keeps uv defaults and Python/PyPI mirrors
- `_kxh_init`
  downloads uv and `starship`
  and syncs dependencies into `.venv/`
  on first run

This makes the shell runtime reproducible enough
to move between machines
without assuming much about the target host.

## Shell Structure

### Xonsh

Xonsh is the interactive shell for this setup.
The main entrypoint is `.config/xonsh/rc.xsh`.
That file adds `.config/xonsh/`
to Python's import path,
calls `common.kxh.main()`,
and then loads the desired xontribs.

The shell is split into small pieces under
`.config/xonsh/rc.d/`.
Important pieces include:

- `aliases.xsh` for command aliases and wrappers
- `carapace.xsh` for shell completion integration
- `conda.xsh` for lazy external Conda hook setup
- `envs.xsh` for environment defaults and tracing
- `prompt.xsh` for prompt and Atuin integration
- `vimode.xsh` for modal editing behavior
- `platform/darwin.xsh` and `platform/linux.xsh` for OS-specific tweaks

So the shell story is:
`kxh` syncs the tree,
`_kxh_init` bootstraps the runtime,
and Xonsh loads the user-facing behavior.

## Ghostty, `tmux`, and Prewarmed Tabs

Ghostty is configured to hand control to `tmux`
instead of treating terminal tabs as the primary abstraction.
This is intentional as Yabai cannot deal with tabbed apps in macOS.

### Ghostty

`.config/ghostty/config`
sets:

```text
command = /Users/$USER/.config/tmux/prewarm/bin/session
```

That means a new Ghostty window starts by entering
the tmux prewarm session manager.
In this setup,
`tmux` effectively owns tab and window management.

### Prewarming

`.config/tmux/prewarm/bin/session`
starts or attaches to a dedicated tmux server
for Ghostty.

`.config/tmux/prewarm/bin/prewarm`
maintains two kinds of tmux sessions:

- an active session for visible work
- a reserve session containing a hidden, already-started shell

When a new tab is requested,
the reserve window is moved into the active session,
and another reserve window is created immediately.
That is what makes new tabs feel instant.

`.config/tmux/prewarm/default.conf`
is the tmux config for that prewarm server.
It sets `~/.local/bin/xh`
as the default shell,
binds `M-t` to dispense a prewarmed window,
and loads the same general plugin stack.

## `.config/` Directory Index

`.config/` is the main body of this repo.
It contains personalized per-tool directories,
plus some live state, plugin data,
and logs produced by those tools.

## TL;DR

This repo is a dotfile tree with three central ideas:

- `.config/` is the main home for personalized tool config
- `kxh`
  turns the repo into a portable SSH shell environment
- `kxh` (aliased to `k` in shell)
  make the shell fast to bootstrap,
  sync all settings across machines,
  and pleasant to reuse across machines
