# Contributing to wallpaper

Thank you for helping. The guide for every repository of the organization is [here](https://github.com/twilight-shell/.github/blob/main/CONTRIBUTING.md): how to propose a change, the commit messages, the checks and the code style. What follows is what is particular to this repository.

## Working on it

- **What it needs:** Twilight.Core. Clone them next to this one and put their parent folders on `QML_IMPORT_PATH`, separated by `:`, as full paths (not `~`).
- **Run it:** `XDG_CONFIG_HOME=$(mktemp -d) QML_IMPORT_PATH=$HOME/src/core:$HOME/src/wallpaper qs -p .` (the first part keeps your real settings out of it). Change it with `qs -p . ipc call wallpaper next` (or `prev`, `set <path>`, `palette <name>`, `live stars`).
- **Tests:** there is no test for the screen: run it and look, and say in the pull request what you tried and on which compositor.
- **Before sending:** run the checks of the guide (`ci/run-tests.sh`, `check-settings.sh`, `check-depends.sh`, `check-install.sh` from the `.github` repository) and add a line to `CHANGELOG.md` under `## Unreleased`.

## Good to know

- The picture is `wallpaper` in `theme.toml` (the palette can take its colors from it); the rest is in `wallpaper.toml`. The commands write to those files.
- The compiled `.qsb` is committed. After editing a `.frag` run `scripts/build-shaders.sh` and commit both.

For security problems, please don't open an issue: see [SECURITY.md](https://github.com/twilight-shell/.github/blob/main/SECURITY.md).
