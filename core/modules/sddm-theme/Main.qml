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
    readonly property color colMantle: "#181825"
    readonly property color colSurface0: "#313244"
    readonly property color colSurface1: "#45475A"
    readonly property color colSurface2: "#585B70"
    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"
    readonly property color colSubtext1: "#BAC2DE"
    readonly property color colMauve: "#CBA6F7"
    readonly property color colPink: "#F5C2E7"
    readonly property color colRed: "#F38BA8"
    readonly property color colPeach: "#FAB387"
    readonly property color colYellow: "#F9E2AF"
    readonly property color colGreen: "#A6E3A1"
    readonly property color colTeal: "#94E2D5"
    readonly property color colBlue: "#89B4FA"
    readonly property color colOverlay0: "#6C7086"

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
        asynchronous: true
        cache: true
        z: 1
    }

    // Dark overlay (simulates blur darkening)
    Rectangle {
        anchors.fill: parent
        color: colBase
        opacity: 0.6
        z: 2
    }

    // Main content
    Item {
        id: mainPanel
        z: 3
        anchors.fill: parent

        // Clock at top
        Clock {
            id: clock
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 60
            }
        }

        // Login panel at bottom
        LoginPanel {
            id: loginPanel
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 30
            }
        }
    }
}
