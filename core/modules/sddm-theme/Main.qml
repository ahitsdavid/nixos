import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "Components"

Item {
    id: root
    height: Screen.height
    width: Screen.width

    // Catppuccin Mocha colors
    readonly property color colBase: "#1E1E2E"

    // Background color fallback
    Rectangle {
        id: background
        anchors.fill: parent
        color: colBase
        z: 0
    }

    // Wallpaper image
    Image {
        id: wallpaperImage
        anchors.fill: parent
        source: config.Background
        fillMode: Image.PreserveAspectCrop
        visible: config.CustomBackground == "true"
        asynchronous: true
        cache: true
        mipmap: true
        clip: true
        z: 1
    }

    // Dark overlay (simulates blur darkening)
    Rectangle {
        anchors.fill: parent
        color: colBase
        opacity: 0.5
        visible: config.CustomBackground == "true"
        z: 2
    }

    // Main content
    Item {
        id: mainPanel
        z: 3
        anchors {
            fill: parent
            margins: 50
        }

        // Clock at top (using config visibility)
        Clock {
            id: time
            visible: config.ClockEnabled == "true"
        }

        // Login panel fills the area - it handles its own layout
        LoginPanel {
            id: loginPanel
            anchors.fill: parent
        }
    }
}
