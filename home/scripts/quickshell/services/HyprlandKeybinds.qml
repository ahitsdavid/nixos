pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * A service that provides access to Hyprland keybinds.
 * Uses the `get_keybinds.py` script to parse comments in config files in a certain format and convert to JSON.
 * PATCHED: Added debug logging
 */
Singleton {
    id: root
    property string keybindParserPath: FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland/get_keybinds.py`)
    property string defaultKeybindConfigPath: FileUtils.trimFileProtocol(`${Directories.config}/hypr/hyprland/keybinds.conf`)
    property string userKeybindConfigPath: FileUtils.trimFileProtocol(`${Directories.config}/hypr/custom/keybinds.conf`)
    property var defaultKeybinds: {"children": []}
    property var userKeybinds: {"children": []}
    property var keybinds: ({
        children: [
            ...(defaultKeybinds.children ?? []),
            ...(userKeybinds.children ?? []),
        ]
    })

    Component.onCompleted: {
        console.log("[HyprlandKeybinds] Script path:", root.keybindParserPath)
        console.log("[HyprlandKeybinds] Config path:", root.defaultKeybindConfigPath)
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "configreloaded") {
                console.log("[HyprlandKeybinds] Config reloaded, refreshing keybinds")
                getDefaultKeybinds.running = true
                getUserKeybinds.running = true
            }
        }
    }

    Process {
        id: getDefaultKeybinds
        running: true
        command: [root.keybindParserPath, "--path", root.defaultKeybindConfigPath]

        onRunningChanged: {
            console.log("[HyprlandKeybinds] getDefaultKeybinds running:", running)
        }

        stdout: SplitParser {
            onRead: data => {
                console.log("[HyprlandKeybinds] Received data length:", data.length)
                console.log("[HyprlandKeybinds] First 200 chars:", data.substring(0, 200))
                try {
                    root.defaultKeybinds = JSON.parse(data)
                    console.log("[HyprlandKeybinds] Parsed successfully, sections:", root.defaultKeybinds.children?.length)
                    console.log("[HyprlandKeybinds] Final merged keybinds sections:", root.keybinds.children?.length)
                    if (root.keybinds.children?.length > 0) {
                        console.log("[HyprlandKeybinds] First section:", root.keybinds.children[0]?.name, "keybinds:", root.keybinds.children[0]?.keybinds?.length)
                    }
                } catch (e) {
                    console.error("[HyprlandKeybinds] Error parsing keybinds:", e)
                    console.error("[HyprlandKeybinds] Raw data:", data)
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("[HyprlandKeybinds] Script stderr:", data)
            }
        }
    }

    Process {
        id: getUserKeybinds
        running: true
        command: [root.keybindParserPath, "--path", root.userKeybindConfigPath]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.userKeybinds = JSON.parse(data)
                } catch (e) {
                    console.error("[HyprlandKeybinds] Error parsing user keybinds:", e)
                }
            }
        }
    }
}
