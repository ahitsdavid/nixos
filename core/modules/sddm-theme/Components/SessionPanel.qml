import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    // Store selected index at root level - initialize from lastIndex or find hyprland
    property int selectedSession: {
        // Try to find hyprland.desktop index
        for (var i = 0; i < sessionModel.count; i++) {
            var name = sessionModel.data(sessionModel.index(i, 0), Qt.UserRole + 4)
            if (name && name.toLowerCase().indexOf("hyprland") >= 0) {
                return i
            }
        }
        // Fallback to lastIndex or 0
        return sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    }

    // Expose as currentIndex for LoginPanel
    property alias currentIndex: root.selectedSession

    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"
    readonly property color colSurface1: "#45475A"
    readonly property color colOverlay0: "#6C7086"

    implicitWidth: sessionButton.implicitWidth
    implicitHeight: sessionButton.implicitHeight

    Button {
        id: sessionButton
        implicitWidth: 40
        implicitHeight: 40

        background: Rectangle {
            radius: height / 2
            color: sessionButton.hovered ? colSurface1 : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        contentItem: Text {
            text: "\ue8b8" // desktop_windows
            font.family: "Material Symbols Rounded"
            font.pixelSize: 22
            color: colSubtext0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: sessionPopup.open()

        ToolTip {
            visible: sessionButton.hovered
            text: sessionModel.data(sessionModel.index(root.selectedSession, 0), Qt.UserRole + 4) || ""
            delay: 500
        }
    }

    Popup {
        id: sessionPopup
        x: sessionButton.x - width + sessionButton.width
        y: -height - 10
        width: 200
        padding: 8

        background: Rectangle {
            color: "#313244"
            radius: 12
            border.color: colOverlay0
            border.width: 1
        }

        contentItem: ListView {
            id: sessionList
            implicitHeight: contentHeight
            model: sessionModel
            currentIndex: root.selectedSession
            spacing: 4
            clip: true

            delegate: ItemDelegate {
                id: sessionDelegate
                width: sessionList.width
                height: 36

                required property int index
                required property string name

                highlighted: root.selectedSession === index

                background: Rectangle {
                    radius: 8
                    color: sessionDelegate.hovered || sessionDelegate.highlighted ?
                           colSurface1 : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }

                contentItem: Text {
                    text: sessionDelegate.name
                    font.pixelSize: 14
                    font.family: config.Font
                    color: colText
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.selectedSession = sessionDelegate.index
                        sessionPopup.close()
                    }
                }
            }
        }
    }
}
