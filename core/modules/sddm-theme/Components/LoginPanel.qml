import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var user: userField.text
    property var password: passwordField.text
    property var session: sessionPanel.currentSession
    property int toolbarHeight: 56
    property int toolbarSpacing: 10

    // Catppuccin Mocha colors (inherited from Main.qml via parent)
    readonly property color colSurface0: "#313244"
    readonly property color colSurface1: "#45475A"
    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"
    readonly property color colMauve: "#CBA6F7"
    readonly property color colOverlay0: "#6C7086"
    readonly property color colBase: "#1E1E2E"

    implicitWidth: mainToolbar.width
    implicitHeight: toolbarHeight

    // Toolbar component
    component Toolbar: Item {
        id: toolbar
        property alias content: toolbarLayout.data
        property color backgroundColor: colSurface0

        implicitWidth: toolbarBackground.implicitWidth
        implicitHeight: toolbarBackground.implicitHeight

        // Shadow
        DropShadow {
            anchors.fill: toolbarBackground
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            color: "#40000000"
            source: toolbarBackground
        }

        Rectangle {
            id: toolbarBackground
            color: toolbar.backgroundColor
            implicitHeight: root.toolbarHeight
            implicitWidth: toolbarLayout.implicitWidth + 16
            radius: height / 2

            RowLayout {
                id: toolbarLayout
                spacing: 4
                anchors {
                    fill: parent
                    margins: 8
                }
            }
        }
    }

    // Icon button component
    component IconButton: Button {
        id: iconBtn
        property string iconText: ""
        property color iconColor: colSubtext0
        property color bgColor: "transparent"
        property color bgHoverColor: colSurface1

        implicitWidth: root.toolbarHeight - 16
        implicitHeight: root.toolbarHeight - 16

        background: Rectangle {
            radius: height / 2
            color: iconBtn.hovered ? bgHoverColor : bgColor

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        contentItem: Text {
            text: iconBtn.iconText
            font.family: "Material Symbols Rounded"
            font.pixelSize: 24
            color: iconBtn.iconColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Main row of toolbars
    Row {
        id: toolbarRow
        spacing: toolbarSpacing
        anchors.horizontalCenter: parent.horizontalCenter

        // Left toolbar - User info
        Toolbar {
            id: leftToolbar

            content: [
                // User icon
                Text {
                    text: "\ue853" // account_circle
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 28
                    color: colSubtext0
                    Layout.leftMargin: 8
                    Layout.alignment: Qt.AlignVCenter
                },
                // Username field
                TextField {
                    id: userField
                    Layout.preferredWidth: 120
                    Layout.alignment: Qt.AlignVCenter
                    text: userModel.lastUser
                    placeholderText: "Username"
                    font.pixelSize: 14
                    font.family: config.Font
                    color: colText
                    placeholderTextColor: colOverlay0
                    horizontalAlignment: TextInput.AlignLeft
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            ]
        }

        // Main toolbar - Password
        Toolbar {
            id: mainToolbar

            content: [
                // Password field with custom characters
                PasswordField {
                    id: passwordField
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    onAccepted: loginButton.clicked()
                },
                // Login button
                Button {
                    id: loginButton
                    implicitWidth: root.toolbarHeight - 16
                    implicitHeight: root.toolbarHeight - 16
                    Layout.alignment: Qt.AlignVCenter

                    enabled: user !== "" && password !== ""

                    background: Rectangle {
                        radius: height / 2
                        color: loginButton.enabled ?
                            (loginButton.hovered ? "#B794F4" : colMauve) : colSurface1

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: "\ue5c8" // arrow_forward
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
            ]
        }

        // Right toolbar - Power controls
        Toolbar {
            id: rightToolbar

            content: [
                // Session selector
                SessionPanel {
                    id: sessionPanel
                    Layout.alignment: Qt.AlignVCenter
                },
                // Sleep
                IconButton {
                    iconText: "\ue51c" // dark_mode (sleep)
                    onClicked: sddm.suspend()
                },
                // Power off
                IconButton {
                    iconText: "\ue8ac" // power_settings_new
                    onClicked: sddm.powerOff()
                },
                // Reboot
                IconButton {
                    iconText: "\ue042" // restart_alt
                    Layout.rightMargin: 4
                    onClicked: sddm.reboot()
                }
            ]
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            passwordField.clear()
            passwordField.shake()
            passwordField.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
