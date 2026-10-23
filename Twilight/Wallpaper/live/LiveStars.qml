import QtQuick
import Twilight.Core

// Live wallpaper: an LED wall of glowing, drifting, twinkling stars in the
// palette's colors (shaders/stars.frag, compiled with scripts/build-shaders.sh).
ShaderEffect {
    id: root

    property real dot: 9
    property real cell: 300
    property real speed: 1
    property real glow: 0.45

    property real time: 0
    property vector2d resolution: Qt.vector2d(width, height)
    property color background: Theme.bg
    property color colorA: Theme.primary
    property color colorB: Theme.star
    property color colorC: Theme.secondary

    // The shader's own names for the knobs.
    property real dotSize: dot
    property real cellSize: cell

    fragmentShader: Qt.resolvedUrl("shaders/stars.frag.qsb")

    // 30 frames a second is plenty for a slow drift and keeps the load low.
    Timer {
        interval: 33
        repeat: true
        running: root.visible
        // Speed scales the step, so changing it doesn't make the sky jump.
        onTriggered: root.time += interval / 1000 * root.speed
    }
}
