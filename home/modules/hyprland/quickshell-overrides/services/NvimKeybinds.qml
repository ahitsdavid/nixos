pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * A service that provides access to Neovim keybinds from nvf.nix.
 * Uses the `get_nvim_keybinds.py` script to parse the nix config and convert to JSON.
 */
Singleton {
    id: root
    property string keybindParserPath: FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland/get_nvim_keybinds.py`)
    property var keybinds: {"children": []}

    Component.onCompleted: {
        getNvimKeybinds.running = true
    }

    Process {
        id: getNvimKeybinds
        running: true
        command: [root.keybindParserPath]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.keybinds = JSON.parse(data)
                } catch (e) {
                    console.error("[NvimKeybinds] Error parsing keybinds:", e)
                }
            }
        }
    }
}
