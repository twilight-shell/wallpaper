# twilight-shell/wallpaper

[![ci](https://github.com/twilight-shell/wallpaper/actions/workflows/ci.yml/badge.svg)](https://github.com/twilight-shell/wallpaper/actions/workflows/ci.yml)

The wallpaper of the [twilight-shell](https://github.com/twilight-shell)
organization, drawn on the background layer of every screen. A new picture is
revealed through a circle growing from the middle of the screen. Instead of a
picture it can draw live stars: a wall of glowing, drifting, twinkling dots in
the colors of the palette. It works on its own or as a piece of the full shell.

## Requirements

[Quickshell](https://quickshell.org) 0.3 or newer, with
[twilight-shell/core](https://github.com/twilight-shell/core) installed.

## Running on its own

```sh
qs -p /path/to/wallpaper
```

If `Twilight.Core` is not in a directory Qt searches, point `QML_IMPORT_PATH` at
its parent directory.

## Using it in a shell

```sh
sudo make install        # to /usr/lib/qt6/qml/Twilight/Wallpaper
```

```qml
import Twilight.Wallpaper

Wallpaper {}
```

## Settings

The picture is `wallpaper` in `~/.config/twilight-shell/theme.toml`, the file
the theme reads too, since its colors can be picked from the picture:

```toml
wallpaper = "/home/me/Pictures/Wallpapers/twi.jpg"   # "" for the plain background
palette = "wallpaper"                                # or "twilight", a preset...
```

The rest is in `~/.config/twilight-shell/wallpaper.toml`, created with the
defaults the first time the wallpaper starts. Both files apply as soon as they
are saved:

```toml
# Where next and prev look for pictures.
dir = "~/Pictures/Wallpapers"

# A live wallpaper drawn over the picture: "stars", or "" for none. While it is
# on, the theme doesn't take colors from the picture.
live = ""

[stars]
# Size of a star, the distance between them, how fast the sky drifts, how far
# the glow reaches.
dot = 9
cell = 300
speed = 1
glow = 0.45
```

While `live` is on, the theme doesn't take colors from the picture: the stars
are drawn in the palette's colors, so they can't also lend them.

## IPC

The commands write to the files above, so what they set survives a restart.

```sh
qs -p /path/to/wallpaper ipc call wallpaper next
qs -p /path/to/wallpaper ipc call wallpaper prev
qs -p /path/to/wallpaper ipc call wallpaper set /path/to/picture.png
qs -p /path/to/wallpaper ipc call wallpaper palette twilight
qs -p /path/to/wallpaper ipc call wallpaper live stars     # "" turns it off
```

## Shaders

The stars are a shader, `Twilight/Wallpaper/live/shaders/stars.frag`. The
compiled `.qsb` next to it is committed; after editing the shader, run
`scripts/build-shaders.sh` (needs `qsb`, Void: `qt6-shadertools-devel`).

## Contributing

Contributions are welcome: see [CONTRIBUTING.md](CONTRIBUTING.md). Agents and the like: [AGENTS.md](AGENTS.md).

## License

MIT, see `LICENSE`.
