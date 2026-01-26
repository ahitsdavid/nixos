pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    readonly property var keybinds: NvimKeybinds.keybinds
    property real spacing: 20
    property real titleSpacing: 7
    property real padding: 4
    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: row.implicitHeight + padding * 2

    property var keySubstitutions: ({
        "Leader": "␣",
        "Ctrl": "C",
        "Shift": "S",
        "Alt": "A",
        "Meta": "M",
        "Tab": "⇥",
        "Enter": "↵",
        "Esc": "⎋",
        "Space": "␣",
        "Backspace": "⌫",
    })

    Row {
        id: row
        spacing: root.spacing

        Repeater {
            model: keybinds.children

            delegate: Column {
                spacing: root.spacing
                required property var modelData
                anchors.top: row.top

                Item {
                    id: keybindSection
                    implicitWidth: sectionColumn.implicitWidth
                    implicitHeight: sectionColumn.implicitHeight

                    Column {
                        id: sectionColumn
                        anchors.centerIn: parent
                        spacing: root.titleSpacing

                        StyledText {
                            id: sectionTitle
                            font {
                                family: Appearance.font.family.title
                                pixelSize: Appearance.font.pixelSize.title
                                variableAxes: Appearance.font.variableAxes.title
                            }
                            color: Appearance.colors.colOnLayer0
                            text: modelData.name
                        }

                        GridLayout {
                            id: keybindGrid
                            columns: 2
                            columnSpacing: 4
                            rowSpacing: 4

                            Repeater {
                                model: {
                                    var result = [];
                                    for (var i = 0; i < modelData.keybinds.length; i++) {
                                        const keybind = modelData.keybinds[i];
                                        result.push({
                                            "type": "keys",
                                            "mods": keybind.mods,
                                            "key": keybind.key,
                                        });
                                        result.push({
                                            "type": "comment",
                                            "comment": keybind.comment,
                                        });
                                    }
                                    return result;
                                }

                                delegate: Item {
                                    required property var modelData
                                    implicitWidth: keybindLoader.implicitWidth
                                    implicitHeight: keybindLoader.implicitHeight

                                    Loader {
                                        id: keybindLoader
                                        sourceComponent: (modelData.type === "keys") ? keysComponent : commentComponent
                                    }

                                    Component {
                                        id: keysComponent
                                        Row {
                                            spacing: 2
                                            Repeater {
                                                model: modelData.mods
                                                delegate: Row {
                                                    spacing: 2
                                                    required property var modelData
                                                    required property int index
                                                    KeyboardKey {
                                                        key: keySubstitutions[modelData] || modelData
                                                        pixelSize: Config.options.cheatsheet?.fontSize?.key || Appearance.font.pixelSize.small
                                                    }
                                                    StyledText {
                                                        visible: true
                                                        text: "+"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }
                                            }
                                            KeyboardKey {
                                                key: keySubstitutions[modelData.key] || modelData.key
                                                pixelSize: Config.options.cheatsheet?.fontSize?.key || Appearance.font.pixelSize.small
                                                color: Appearance.colors.colOnLayer0
                                            }
                                        }
                                    }

                                    Component {
                                        id: commentComponent
                                        Item {
                                            id: commentItem
                                            implicitWidth: commentText.implicitWidth + 8 * 2
                                            implicitHeight: commentText.implicitHeight

                                            StyledText {
                                                id: commentText
                                                anchors.centerIn: parent
                                                font.pixelSize: Config.options.cheatsheet?.fontSize?.comment || Appearance.font.pixelSize.smaller
                                                text: modelData.comment
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
