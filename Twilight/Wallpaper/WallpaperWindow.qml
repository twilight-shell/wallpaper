import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Twilight.Core
import "live"

// The wallpaper of one screen, on the background layer. A new picture is
// revealed through a circle growing from the middle of the screen.
PanelWindow {
    id: window

    required property ShellScreen modelData

    // The picture to show, "" for the plain background color.
    property string path: ""
    // A live wallpaper drawn over the picture: "" or "stars".
    property string live: ""
    property real starsDot: 9
    property real starsCell: 300
    property real starsSpeed: 1
    property real starsGlow: 0.45

    // Two pictures swap roles: the front one is shown, the other one
    // loads the next wallpaper and is revealed over it.
    property int front: 0
    readonly property Image shownImage: front === 0 ? imageA : imageB
    readonly property Image nextImage: front === 0 ? imageB : imageA
    property bool revealing: false
    property real reveal: 0

    screen: modelData
    color: Theme.bg
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "twilight-wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Component.onCompleted: shownImage.path = path

    onPathChanged: {
        if (path === shownImage.path)
            return;
        revealAnim.stop();
        revealing = false;
        reveal = 0;
        nextImage.path = "";

        // No wallpaper: fade the picture out to the background color.
        if (path === "") {
            fadeIn.stop();
            fadeOut.restart();
            return;
        }
        fadeOut.stop();

        // Nothing on screen yet: fade straight in, there's nothing to reveal over.
        if (shownImage.path === "") {
            shownImage.opacity = 0;
            shownImage.path = path;
            fadeIn.restart();
            return;
        }

        shownImage.opacity = 1;
        revealing = true;
        nextImage.path = path;
        if (nextImage.status === Image.Ready)
            revealAnim.start();
    }

    NumberAnimation {
        id: fadeOut

        target: window.shownImage
        property: "opacity"
        to: 0
        duration: 700
        easing.type: Easing.InOutQuad
        onFinished: {
            window.shownImage.path = "";
            window.shownImage.opacity = 1;
        }
    }

    NumberAnimation {
        id: fadeIn

        target: window.shownImage
        property: "opacity"
        to: 1
        duration: 700
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        id: revealAnim

        target: window
        property: "reveal"
        from: 0
        to: 1
        duration: 1100
        easing.type: Easing.InOutCubic
        onFinished: {
            const old = window.shownImage;
            window.front = 1 - window.front;
            window.revealing = false;
            window.reveal = 0;
            old.path = "";
        }
    }

    component Picture: Image {
        property string path: ""

        anchors.fill: parent
        source: path !== "" ? "file://" + path : ""
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(window.width, window.height)
        asynchronous: true
        cache: false

        // Start the reveal once the incoming picture has loaded; a
        // picture that can't be loaded is dropped instead of waited on.
        onStatusChanged: {
            if (status === Image.Ready && this === window.nextImage && window.revealing && !revealAnim.running)
                revealAnim.start();
            if (status === Image.Error) {
                if (this === window.nextImage)
                    window.revealing = false;
                path = "";
            }
        }
    }

    Picture {
        id: imageA

        visible: window.front === 0
        layer.enabled: window.front !== 0
    }

    Picture {
        id: imageB

        visible: window.front === 1
        layer.enabled: window.front !== 1
    }

    Item {
        id: circle

        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            readonly property real full: Math.hypot(window.width, window.height)

            anchors.centerIn: parent
            width: full * window.reveal
            height: width
            radius: width / 2
        }
    }

    // Live wallpaper over the picture, fading in and out.
    Loader {
        anchors.fill: parent
        z: 1
        active: opacity > 0
        opacity: window.live === "stars" ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 800 }
        }

        sourceComponent: LiveStars {
            dot: window.starsDot
            cell: window.starsCell
            speed: window.starsSpeed
            glow: window.starsGlow
        }
    }

    MultiEffect {
        anchors.fill: parent
        visible: window.revealing
        source: window.nextImage
        maskEnabled: true
        maskSource: circle
        maskSpreadAtMin: 0.2
        maskThresholdMin: 0.4
    }
}
