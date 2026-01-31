import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property var user: userField.text
    property var password: passwordField.text
    property int toolbarHeight: 56
    property int toolbarSpacing: 10

    // Session index - initialized from lastIndex, updated by user selection
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool sessionInitialized: false

    // Catppuccin Mocha colors
    readonly property color colSurface0: "#313244"
    readonly property color colSurface1: "#45475A"
    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"
    readonly property color colMauve: "#CBA6F7"
    readonly property color colOverlay0: "#6C7086"
    readonly property color colBase: "#1E1E2E"

    implicitWidth: mainToolbar.width
    implicitHeight: toolbarHeight

    // Find hyprland index when model is ready
    // Prefers hyprland-uwsm session (for programs.hyprland.withUWSM = true)
    function findHyprlandIndex() {
        // SDDM sessionModel exposes roles: file, name, exec, comment
        // Qt.UserRole is 256, NameRole = Qt.UserRole + 2 = 258
        var NameRole = 258
        var hyprlandUwsmIdx = -1
        var hyprlandIdx = -1

        for (var i = 0; i < sessionModel.rowCount(); i++) {
            var name = sessionModel.data(sessionModel.index(i, 0), NameRole)
            if (name) {
                var lowerName = name.toLowerCase()
                // Prefer hyprland-uwsm (UWSM-managed session)
                if (lowerName.indexOf("hyprland") >= 0 && lowerName.indexOf("uwsm") >= 0) {
                    hyprlandUwsmIdx = i
                }
                // Also track regular hyprland as fallback
                else if (lowerName.indexOf("hyprland") >= 0) {
                    hyprlandIdx = i
                }
            }
        }

        // Prefer UWSM variant, then regular hyprland, then lastIndex
        if (hyprlandUwsmIdx >= 0) return hyprlandUwsmIdx
        if (hyprlandIdx >= 0) return hyprlandIdx
        return sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    }

    // Toolbar component - pill-shaped container
    component Toolbar: Item {
        id: toolbar
        property alias content: toolbarLayout.data
        property color backgroundColor: colSurface0

        implicitWidth: toolbarBackground.implicitWidth
        implicitHeight: toolbarBackground.implicitHeight

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

    // Session button component
    component SessionButton: Button {
        id: sessBtn

        implicitWidth: root.toolbarHeight - 16
        implicitHeight: root.toolbarHeight - 16

        background: Rectangle {
            radius: height / 2
            color: sessBtn.hovered ? colSurface1 : "transparent"

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
            visible: sessBtn.hovered
            text: sessionModel.data(sessionModel.index(root.sessionIndex, 0), 258) || "Select Session"
            delay: 500
        }
    }

    // Session popup - defined at root level
    Popup {
        id: sessionPopup
        x: toolbarRow.x + rightToolbar.x + 8
        y: toolbarRow.y - height - 10
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
            currentIndex: root.sessionIndex
            spacing: 4
            clip: true

            delegate: ItemDelegate {
                id: sessionDelegate
                width: sessionList.width
                height: 36

                // Use model attached property for robust role access
                property int sessionIdx: index
                property string sessionName: model.name || ""

                highlighted: root.sessionIndex === sessionIdx

                background: Rectangle {
                    radius: 8
                    color: sessionDelegate.hovered || sessionDelegate.highlighted ?
                           colSurface1 : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }

                contentItem: Text {
                    text: sessionDelegate.sessionName
                    font.pixelSize: 14
                    font.family: config.Font
                    color: colText
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }

                onClicked: {
                    root.sessionIndex = sessionDelegate.sessionIdx
                    sessionPopup.close()
                }
            }
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
                        sddm.login(user, password, root.sessionIndex)
                    }
                }
            ]
        }

        // Right toolbar - Power controls
        Toolbar {
            id: rightToolbar

            content: [
                // Session selector
                SessionButton {
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

    // Initialize session once when model is ready
    Connections {
        target: sessionModel
        function onCountChanged() {
            // Only initialize once, don't override user selection
            if (!root.sessionInitialized && sessionModel.rowCount() > 0) {
                root.sessionIndex = root.findHyprlandIndex()
                root.sessionInitialized = true
            }
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
        // Try to find hyprland if model is already loaded
        if (!root.sessionInitialized && sessionModel.rowCount() > 0) {
            root.sessionIndex = findHyprlandIndex()
            root.sessionInitialized = true
        }
    }
}
