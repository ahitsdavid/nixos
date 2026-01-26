pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * A service that provides access to Terminal (Kitty) keybinds and shell aliases.
 * Uses the `get_terminal_keybinds.py` script to parse nix configs and convert to JSON.
 */
Singleton {
    id: root
    property string keybindParserPath: FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland/get_terminal_keybinds.py`)
    property var keybinds: {"children": []}

    Component.onCompleted: {
        getTerminalKeybinds.running = true
    }

    Process {
        id: getTerminalKeybinds
        running: true
        command: [root.keybindParserPath]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.keybinds = JSON.parse(data)
                } catch (e) {
                    console.error("[TerminalKeybinds] Error parsing keybinds:", e)
                }
            }
        }
    }
}
