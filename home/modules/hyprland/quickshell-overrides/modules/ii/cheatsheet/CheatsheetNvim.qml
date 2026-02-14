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
    implicitWidth: mainRow.implicitWidth + padding * 2
    implicitHeight: mainRow.implicitHeight + padding * 2

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

    // Split mode sections into balanced columns
    property var columns: {
        var cols = [[], []];
        var colHeights = [0, 0];

        for (var i = 0; i < keybinds.children.length; i++) {
            var section = keybinds.children[i];
            var height = (section.keybinds ? section.keybinds.length : 0) + 2;

            // Find shortest column
            var minCol = 0;
            for (var c = 1; c < cols.length; c++) {
                if (colHeights[c] < colHeights[minCol]) {
                    minCol = c;
                }
            }

            cols[minCol].push(section);
            colHeights[minCol] += height;
        }

        return cols;
    }

    Row {
        id: mainRow
        anchors.centerIn: parent
        spacing: root.spacing

        Repeater {
            model: columns

            delegate: Column {
                spacing: root.spacing
                required property var modelData
                required property int index

                Repeater {
                    model: modelData

                    delegate: Item {
                        required property var modelData
                        implicitWidth: sectionColumn.implicitWidth
                        implicitHeight: sectionColumn.implicitHeight

                        Column {
                            id: sectionColumn
                            spacing: root.titleSpacing

                            StyledText {
                                font {
                                    family: Appearance.font.family.title
                                    pixelSize: Appearance.font.pixelSize.title
                                    variableAxes: Appearance.font.variableAxes.title
                                }
                                color: Appearance.colors.colOnLayer0
                                text: modelData.name
                            }

                            GridLayout {
                                columns: 2
                                columnSpacing: 4
                                rowSpacing: 4

                                Repeater {
                                    model: {
                                        var result = [];
                                        var kbs = modelData.keybinds || [];
                                        for (var i = 0; i < kbs.length; i++) {
                                            result.push({
                                                "type": "keys",
                                                "mods": kbs[i].mods,
                                                "key": kbs[i].key
                                            });
                                            result.push({
                                                "type": "comment",
                                                "comment": kbs[i].comment
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
                                                implicitWidth: commentText.implicitWidth + 16
                                                implicitHeight: commentText.implicitHeight

                                                StyledText {
                                                    id: commentText
                                                    anchors.centerIn: parent
                                                    font.pixelSize: Config.options.cheatsheet?.fontSize?.comment || Appearance.font.pixelSize.smaller
                                                    text: modelData.comment
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
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
}
