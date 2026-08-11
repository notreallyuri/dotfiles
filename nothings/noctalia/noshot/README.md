# noshot

Screenshots, OCR, reverse search and screen recording for Noctalia: a bar widget
for the recording state, a launcher provider, a capture panel, a settings page,
and an IPC surface.

The work is done by [`noshot`](bin/noshot.lua), a plain Lua CLI that only needs
Hyprland, grim and slurp. A copy ships in `bin/`, so the plugin stands on its own.

## Why the script is still a script

Nothing about a capture goes through the shell. Hyprland keybinds call
`noshot region` directly, so screenshots keep working while Noctalia is
restarting, and the script survives a move to another shell.

What the plugin adds is a face, a settings page, and a way in through the
Noctalia CLI. It talks to the script two ways:

- **commands** — every button runs `noshot <command> --flags`
- **status** — `service.luau` reads `$XDG_RUNTIME_DIR/noshot-record.state`, the
  same file the script writes, and publishes it for the widget and panel

`service.luau` finds the script once and publishes the path: the **Script ·
noshot.lua** setting first, then `bin/noshot.lua`, then `noshot` on `$PATH`.

## IPC

Anything the CLI takes, the service takes:

```sh
noctalia msg plugin nothings/noshot:state all region --edit
noctalia msg plugin nothings/noshot:state all window --pick
noctalia msg plugin nothings/noshot:state all record --audio --mic
noctalia msg plugin nothings/noshot:state all replay-save

noctalia msg plugin nothings/noshot:state all run "screen --delay=5 --ocr=por"
noctalia msg plugin nothings/noshot:state all panel     # toggle the capture panel
noctalia msg plugin nothings/noshot:state all sync      # rewrite the config drop-in
noctalia msg plugin nothings/noshot:state all rescan    # look for the script again
```

`all` is the target every service-style entry uses. Bare commands take their
flags as the payload; `run` takes the whole command line as one string.

## Settings

With *Own noshot's settings* on, `service.luau` mirrors the options into
`~/.local/state/noshot/50-noctalia.lua` whenever they change. The script loads
that as one of its config layers, so the values apply to keybinds too — not just
to captures started from the panel:

```
noshot/config.lua defaults
  ↓
~/.config/nothings/noshot.conf.lua
~/.config/nothings/noshot.conf.d/*.lua
  ↓
~/.local/state/noshot/*.lua          ← written here
  ↓
$NOSHOT_<OPTION>
  ↓
--option=value, --set option=value
```

Turn the sync off and the file is deleted, leaving the script entirely to its own
config. Options the plugin doesn't manage (`upload_hosts`, `lens_url`) always come
from the conf file.

`noshot config` prints every option with the layer it came from.

The defaults declared in `plugin.toml` mirror the ones in `noshot/config.lua` —
change one, change the other.

## Install

In this repo `bin/noshot.lua` and `bin/noshot/` are symlinks to
`nothings/scripts/`, which is the copy Hyprland calls; the plugin is symlinked
into Noctalia's local plugin dir:

```sh
ln -s ~/projects/dotfiles/nothings/noctalia/noshot \
      ~/.local/share/noctalia/plugins/noshot
```

Packaged on its own, `bin/` holds the real files instead (`cp -rL`), and the
plugin needs nothing outside its own directory.
