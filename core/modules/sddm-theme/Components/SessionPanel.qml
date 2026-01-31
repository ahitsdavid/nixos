import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property string currentSession: sessionModel.lastIndex >= 0 ? sessionModel.data(sessionModel.index(sessionModel.lastIndex, 0), Qt.UserRole + 4) : ""
    property int currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

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
            text: root.currentSession
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
            currentIndex: root.currentIndex
            spacing: 4

            delegate: ItemDelegate {
                id: sessionDelegate
                width: sessionList.width
                height: 36

                required property int index
                required property string name

                background: Rectangle {
                    radius: 8
                    color: sessionDelegate.hovered || sessionList.currentIndex === sessionDelegate.index ?
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

                onClicked: {
                    root.currentIndex = index
                    root.currentSession = sessionModel.data(sessionModel.index(index, 0), Qt.UserRole + 4)
                    sessionPopup.close()
                }
            }
        }
    }
}
