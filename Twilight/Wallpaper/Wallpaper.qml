import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Twilight.Core

// The wallpaper, drawn on the background layer of every screen. The picture is
// `wallpaper` in theme.toml, shared with the theme because the colors can be
// picked from it; the rest is in wallpaper.toml. Changing either file changes
// the wallpaper at once.
//
// IPC: `qs -c wallpaper ipc call wallpaper next`, `prev`, `set <path>`,
//      `palette <wallpaper|twilight|...>`, `live <stars|"">`
Scope {
    id: root

    // The picture; "" for the plain background color.
    readonly property string path: Theme.wallpaper
    // Where `next` and `prev` look for pictures.
    property string dir: expand(config.get("dir") ?? "")
    // A live wallpaper drawn over the picture: "" or "stars".
    property string live: config.get("live") ?? ""

    function expand(path: string): string {
        return path.startsWith("~") ? Quickshell.env("HOME") + path.slice(1) : path;
    }

    function set(path: string): void {
        theme.set("wallpaper", path);
    }

    function step(delta: int): void {
        const files = [];
        for (let i = 0; i < folder.count; i++)
            files.push(folder.get(i, "filePath"));
        if (files.length === 0)
            return;
        const at = files.indexOf(path);
        set(files[(at + delta + files.length) % files.length]);
    }

    ConfigFile {
        id: config

        name: "wallpaper"
        defaults: Qt.resolvedUrl("wallpaper.defaults.toml")
    }

    // Written to when the picture or the palette is changed from here; Theme
    // reads the same file and follows.
    ConfigFile {
        id: theme

        name: "theme"
    }

    // A live wallpaper is drawn in the palette's colors, so none are taken
    // from the picture under it.
    Binding {
        target: Theme
        property: "liveWallpaper"
        value: root.live !== ""
    }

    // Pictures in the wallpaper folder, for stepping through them.
    FolderListModel {
        id: folder

        folder: root.dir !== "" ? "file://" + root.dir : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    IpcHandler {
        target: "wallpaper"

        function next(): void {
            root.step(1);
        }

        function prev(): void {
            root.step(-1);
        }

        function set(path: string): void {
            root.set(path);
        }

        function palette(mode: string): void {
            theme.set("palette", mode);
        }

        function live(name: string): void {
            config.set("live", name);
        }
    }

    Variants {
        model: Quickshell.screens

        WallpaperWindow {
            path: root.path
            live: root.live
            starsDot: Number(config.get("stars.dot"))
            starsCell: Number(config.get("stars.cell"))
            starsSpeed: Number(config.get("stars.speed"))
            starsGlow: Number(config.get("stars.glow"))
        }
    }
}
