import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property var user: userField.text
    property var password: passwordField.text
    property var session: sessionPanel.session  // Use original pattern that works

    property var inputHeight: 56
    property var inputWidth: Screen.width * 0.16

    // Catppuccin Mocha colors
    readonly property color colBase: "#1E1E2E"
    readonly property color colMantle: "#181825"
    readonly property color colSurface0: "#313244"
    readonly property color colSurface1: "#45475A"
    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"
    readonly property color colMauve: "#CBA6F7"
    readonly property color colOverlay0: "#6C7086"

    // Bottom toolbar row
    Row {
        id: toolbarRow
        spacing: 10
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 30
        }

        // User pill
        Rectangle {
            width: userContent.width + 32
            height: inputHeight
            radius: inputHeight / 2
            color: colSurface0

            Row {
                id: userContent
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: "\ue853"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 28
                    color: colSubtext0
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: userField
                    width: 140
                    text: userModel.lastUser
                    placeholderText: "Username"
                    font.pixelSize: 14
                    font.family: config.Font
                    color: colText
                    placeholderTextColor: colOverlay0
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle { color: "transparent" }
                }
            }
        }

        // Password pill
        Rectangle {
            width: passwordContent.width + 32
            height: inputHeight
            radius: inputHeight / 2
            color: colSurface0

            Row {
                id: passwordContent
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: "\ue897"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: colSubtext0
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: passwordField
                    width: 180
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    font.pixelSize: 14
                    font.family: config.Font
                    color: colText
                    placeholderTextColor: colOverlay0
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle { color: "transparent" }
                    onAccepted: loginButton.clicked()
                }

                Button {
                    id: loginButton
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: user != "" && password != ""

                    background: Rectangle {
                        radius: 20
                        color: loginButton.enabled ?
                            (loginButton.hovered ? "#B794F4" : colMauve) : colSurface1
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: "\ue5c8"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: loginButton.enabled ? colBase : colOverlay0
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        sddm.login(user, password, session)
                    }
                }
            }
        }

        // Controls pill
        Rectangle {
            width: controlsContent.width + 24
            height: inputHeight
            radius: inputHeight / 2
            color: colSurface0

            Row {
                id: controlsContent
                anchors.centerIn: parent
                spacing: 4

                // Session selector - uses original SessionPanel
                SessionPanel {
                    id: sessionPanel
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Divider
                Rectangle {
                    width: 1
                    height: 32
                    color: colOverlay0
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Sleep
                Button {
                    width: 40
                    height: 40
                    background: Rectangle {
                        radius: 20
                        color: parent.hovered ? colSurface1 : "transparent"
                    }
                    contentItem: Text {
                        text: "\ue51c"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 22
                        color: colSubtext0
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: sddm.suspend()
                }

                // Power
                Button {
                    width: 40
                    height: 40
                    background: Rectangle {
                        radius: 20
                        color: parent.hovered ? colSurface1 : "transparent"
                    }
                    contentItem: Text {
                        text: "\ue8ac"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 22
                        color: colSubtext0
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: sddm.powerOff()
                }

                // Reboot
                Button {
                    width: 40
                    height: 40
                    background: Rectangle {
                        radius: 20
                        color: parent.hovered ? colSurface1 : "transparent"
                    }
                    contentItem: Text {
                        text: "\ue042"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 22
                        color: colSubtext0
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: sddm.reboot()
                }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = ""
            passwordField.focus = true
        }
    }

    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
