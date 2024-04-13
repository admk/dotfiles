# Xitong's Dot Files

## Installation

Paste and run the following line in your terminal:
```shell
cd ~ && git clone https://github.com/admk/dotfiles .kxh && .kxh/.local/bin/kxh +s
```

## Features

### Portable Shell

Connect to your SSH server with the following command:
```shell
k your-server [ssh-args] [kxh-args]
```
where `ssh-args` is a list of arguments
to be passed to `ssh`,
and `kxh-args` is a list of arguments
prefixed with `+`
to be passed to `kxh`.
See `k --help` for more information.
`your-server` is the name of your server
as defined in `~/.ssh/config`
or the full address of your server,
and the optional `+s` is a flag to indicate
that you want to use semi-hermetic mode.
This will sync your configs in the `.kxh/` folder
to the server,
and then start a Xonsh shell session on the server
with the same configs.
