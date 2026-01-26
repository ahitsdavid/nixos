#!/usr/bin/env python3
"""
Hyprland keybind parser for Nix-generated configurations.
Reads keybinds from keybinds.nix extraConfig and outputs JSON for quickshell cheatsheet.
"""
import argparse
import re
import os
import json
from typing import Dict, List

TITLE_REGEX = "#+!"
HIDE_COMMENT = "[hidden]"
MOD_SEPARATORS = ['+', ' ']
COMMENT_BIND_PATTERN = "#/#"

# Always read from the Nix source file (ignore --path argument from quickshell service)
NIX_KEYBINDS_PATH = "/etc/nixos/home/modules/hyprland/keybinds.nix"

parser = argparse.ArgumentParser(description='Hyprland keybind reader for Nix files')
parser.add_argument('--path', type=str, default=NIX_KEYBINDS_PATH,
                    help='ignored - always reads from Nix source')
args = parser.parse_args()
content_lines = []
reading_line = 0


class KeyBinding(dict):
    def __init__(self, mods, key, dispatcher, params, comment) -> None:
        self["mods"] = mods
        self["key"] = key
        self["dispatcher"] = dispatcher
        self["params"] = params
        self["comment"] = comment


class Section(dict):
    def __init__(self, children, keybinds, name) -> None:
        self["children"] = children
        self["keybinds"] = keybinds
        self["name"] = name


def read_nix_extraconfig(path: str) -> str:
    """Read a Nix file and extract the content from extraConfig = ''...''"""
    expanded_path = os.path.expanduser(os.path.expandvars(path))
    if not os.access(expanded_path, os.R_OK):
        return "error"

    with open(expanded_path, "r") as file:
        content = file.read()

    # Find extraConfig = '' and extract content until closing '';
    # Handle the Nix multiline string format
    match = re.search(r"extraConfig\s*=\s*''(.*?)'';", content, re.DOTALL)
    if match:
        return match.group(1)
    return "error"


def autogenerate_comment(dispatcher: str, params: str = "") -> str:
    match dispatcher:
        case "resizewindow":
            return "Resize window"

        case "movewindow":
            if params == "":
                return "Move window"
            else:
                return "Window: move in {} direction".format({
                    "l": "left",
                    "r": "right",
                    "u": "up",
                    "d": "down",
                }.get(params, "null"))

        case "pin":
            return "Window: pin (show on all workspaces)"

        case "splitratio":
            return "Window split ratio {}".format(params)

        case "togglefloating":
            return "Float/unfloat window"

        case "resizeactive":
            return "Resize window by {}".format(params)

        case "killactive":
            return "Close window"

        case "fullscreen":
            return "Toggle {}".format(
                {
                    "0": "fullscreen",
                    "1": "maximization",
                    "2": "fullscreen on Hyprland's side",
                }.get(params, "null")
            )

        case "fakefullscreen":
            return "Toggle fake fullscreen"

        case "workspace":
            if params == "+1":
                return "Workspace: focus right"
            elif params == "-1":
                return "Workspace: focus left"
            return "Focus workspace {}".format(params)

        case "movefocus":
            return "Window: move focus {}".format(
                {
                    "l": "left",
                    "r": "right",
                    "u": "up",
                    "d": "down",
                }.get(params, "null")
            )

        case "swapwindow":
            return "Window: swap in {} direction".format(
                {
                    "l": "left",
                    "r": "right",
                    "u": "up",
                    "d": "down",
                }.get(params, "null")
            )

        case "movetoworkspace":
            if params == "+1":
                return "Window: move to right workspace (non-silent)"
            elif params == "-1":
                return "Window: move to left workspace (non-silent)"
            return "Window: move to workspace {} (non-silent)".format(params)

        case "movetoworkspacesilent":
            if params == "+1":
                return "Window: move to right workspace"
            elif params == "-1":
                return "Window: move to right workspace"
            return "Window: move to workspace {}".format(params)

        case "togglespecialworkspace":
            return "Workspace: toggle special"

        case "exec":
            return "Execute: {}".format(params)

        case _:
            return ""


def get_keybind_at_line(line_number, line_start=0):
    global content_lines
    line = content_lines[line_number].strip()

    # Handle the line starting after any comment pattern prefix
    if line.startswith(COMMENT_BIND_PATTERN):
        line = line[len(COMMENT_BIND_PATTERN):].lstrip()

    # Split on first = to separate bind type from the rest
    if '=' not in line:
        return None
    bind_type, keys = line.split("=", 1)
    bind_type = bind_type.strip()
    keys, *comment = keys.split("#", 1)

    # Bind types with 'd' have an extra description field: bindd/bindld/bindde = Mods, Key, Description, Dispatcher, Params
    # Regular bind types: bind/bindl/binde/bindm/bindr/bindn/bindp = Mods, Key, Dispatcher, Params
    # The 'd' can appear anywhere after 'bind', e.g.: bindd, bindld, binddle, bindrde
    is_bindd = 'd' in bind_type[4:] if len(bind_type) > 4 else False

    if is_bindd:
        parts = list(map(str.strip, keys.split(",", 5)))
        if len(parts) < 4:
            return None
        mods, key, description, dispatcher, *params = parts
        params = ", ".join(map(str.strip, params))
    else:
        parts = list(map(str.strip, keys.split(",", 4)))
        if len(parts) < 3:
            return None
        mods, key, dispatcher, *params = parts
        params = ", ".join(map(str.strip, params))
        description = ""

    # Remove empty spaces from comment
    comment = list(map(str.strip, comment))
    # Add comment if it exists, else use description or generate it
    if comment:
        comment = comment[0]
        if comment.startswith("[hidden]"):
            return None
    elif description:
        comment = description
    else:
        comment = autogenerate_comment(dispatcher, params)

    if mods:
        modstring = mods + MOD_SEPARATORS[0]  # Add separator at end to ensure last mod is read
        mods = []
        p = 0
        for index, char in enumerate(modstring):
            if char in MOD_SEPARATORS:
                if index - p > 1:
                    mods.append(modstring[p:index])
                p = index + 1
    else:
        mods = []

    return KeyBinding(mods, key, dispatcher, params, comment)


def get_binds_recursive(current_content, scope):
    global content_lines
    global reading_line

    while reading_line < len(content_lines):
        line = content_lines[reading_line]
        stripped_line = line.strip()
        heading_search_result = re.search(TITLE_REGEX, stripped_line)

        if (heading_search_result is not None) and (heading_search_result.start() == 0):
            # Determine scope - count # before !
            heading_scope = stripped_line.find('!')
            # Lower or equal scope? Return to parent
            if heading_scope <= scope:
                reading_line -= 1
                return current_content

            section_name = stripped_line[(heading_scope + 1):].strip()
            reading_line += 1
            current_content["children"].append(get_binds_recursive(Section([], [], section_name), heading_scope))

        elif stripped_line.startswith(COMMENT_BIND_PATTERN):
            keybind = get_keybind_at_line(reading_line, line_start=len(COMMENT_BIND_PATTERN))
            if keybind is not None:
                current_content["keybinds"].append(keybind)

        elif stripped_line == "" or not stripped_line.startswith("bind"):
            pass

        else:
            keybind = get_keybind_at_line(reading_line)
            if keybind is not None:
                current_content["keybinds"].append(keybind)

        reading_line += 1

    return current_content


def parse_keys(path: str) -> Dict[str, List[KeyBinding]]:
    global content_lines
    global reading_line
    reading_line = 0

    raw_content = read_nix_extraconfig(path)
    if raw_content == "error":
        return {"children": [], "keybinds": [], "name": ""}

    content_lines = raw_content.splitlines()
    return get_binds_recursive(Section([], [], ""), 0)


if __name__ == "__main__":
    # Always use Nix source path, ignore any --path argument
    ParsedKeys = parse_keys(NIX_KEYBINDS_PATH)
    print(json.dumps(ParsedKeys))
