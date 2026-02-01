import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

Item {
    id: root
    property var session: sessionList.currentIndex
    implicitHeight: sessionButton.height
    implicitWidth: sessionButton.width

    // Catppuccin Mocha colors
    readonly property color colSurface0: "#313244"
    readonly property color colSurface1: "#45475A"
    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"

    DelegateModel {
        id: sessionWrapper
        model: sessionModel
        delegate: ItemDelegate {
            id: sessionEntry
            height: 48
            width: sessionPopup.width - sessionPopup.padding * 2
            highlighted: sessionList.currentIndex == index
            contentItem: Text {
                renderType: Text.NativeRendering
                font {
                    family: config.Font
                    pointSize: config.FontSize
                    bold: true
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: colText
                text: name
            }
            background: Rectangle {
                id: sessionEntryBackground
                color: sessionEntry.highlighted ? colSurface1 : colSurface0
                radius: 8
            }
            states: [
                State {
                    name: "hovered"
                    when: sessionEntry.hovered && !sessionEntry.highlighted
                    PropertyChanges {
                        target: sessionEntryBackground
                        color: "#585B70"
                    }
                }
            ]
            transitions: Transition {
                PropertyAnimation {
                    property: "color"
                    duration: 150
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    sessionList.currentIndex = index
                    sessionPopup.close()
                }
            }
        }
    }

    Button {
        id: sessionButton
        width: 40
        height: 40
        hoverEnabled: true

        background: Rectangle {
            id: sessionButtonBackground
            radius: 20
            color: sessionPopup.visible || sessionButton.hovered ? colSurface1 : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        contentItem: Text {
            text: "\ue8b8"  // settings gear icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: 22
            color: colSubtext0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            sessionPopup.visible ? sessionPopup.close() : sessionPopup.open()
        }
    }

    Popup {
        id: sessionPopup
        width: 200
        x: (sessionButton.width - width) / 2
        y: -(contentHeight + padding * 2 + 8)
        padding: 8
        background: Rectangle {
            radius: 12
            color: colSurface0
        }
        contentItem: ListView {
            id: sessionList
            implicitHeight: contentHeight
            spacing: 4
            model: sessionWrapper
            currentIndex: sessionModel.lastIndex
            clip: true
        }
        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "y"
                    from: sessionPopup.y + 10
                    to: sessionPopup.y
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
