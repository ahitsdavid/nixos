#!/usr/bin/env python3
"""
Neovim keybind parser for nixvim configurations.
Reads keybinds from nixvim.nix keymaps section and outputs JSON for quickshell cheatsheet.
"""
import argparse
import re
import os
import json
from typing import Dict, List, Any

NIX_NIXVIM_PATH = "/etc/nixos/home/modules/nixvim.nix"

parser = argparse.ArgumentParser(description='Neovim keybind reader for nixvim.nix')
parser.add_argument('--path', type=str, default=NIX_NIXVIM_PATH,
                    help='ignored - always reads from Nix source')
args = parser.parse_args()


def read_file(path: str) -> str:
    """Read a file and return its content."""
    expanded_path = os.path.expanduser(os.path.expandvars(path))
    if not os.access(expanded_path, os.R_OK):
        return ""
    with open(expanded_path, "r") as file:
        return file.read()


def parse_nixvim_keybinds(content: str) -> Dict[str, Any]:
    """Parse nixvim.nix content and extract keybinds from keymaps section."""
    result = {
        "children": []
    }

    # Pattern to match nixvim keymap entries:
    # { mode = "n"; key = "<leader>cc"; action = "<cmd>...<CR>"; options.desc = "..."; }
    keymap_pattern = r'\{\s*mode\s*=\s*"([^"]+)";\s*key\s*=\s*"([^"]+)";\s*action\s*=\s*"([^"]+)";\s*options\.desc\s*=\s*"([^"]+)";\s*\}'

    # Group keybinds by mode
    mode_keybinds = {
        'n': [],
        'i': [],
        't': [],
        'v': [],
        'x': [],
    }

    for match in re.finditer(keymap_pattern, content):
        mode = match.group(1)
        key = match.group(2)
        action = match.group(3)
        desc = match.group(4)

        # Parse the key into mods and key
        mods, main_key = parse_vim_key(key)

        keybind = {
            "mods": mods,
            "key": main_key,
            "action": action,
            "comment": desc
        }

        if mode in mode_keybinds:
            mode_keybinds[mode].append(keybind)
        else:
            mode_keybinds[mode] = [keybind]

    # Build result structure
    mode_names = {
        'n': "Normal Mode",
        'i': "Insert Mode",
        't': "Terminal Mode",
        'v': "Visual Mode",
        'x': "Visual Block Mode",
    }

    for mode, keybinds in mode_keybinds.items():
        if keybinds:
            mode_name = mode_names.get(mode, f"{mode.upper()} Mode")
            result["children"].append({
                "name": mode_name,
                "keybinds": keybinds,
                "children": []
            })

    return result


def parse_vim_key(key: str) -> tuple:
    """Parse a vim key notation into mods and main key."""
    mods = []
    main_key = key

    # Handle <leader> prefix
    if key.startswith("<leader>"):
        mods.append("Leader")
        main_key = key[8:]  # Remove <leader>

    # Handle modifier keys like <C-s>, <S-Tab>, <C-S-x>
    mod_pattern = r'^<([CSAM])-(.+)>$'
    match = re.match(mod_pattern, main_key)
    while match:
        mod_char = match.group(1)
        if mod_char == 'C':
            mods.append('Ctrl')
        elif mod_char == 'S':
            mods.append('Shift')
        elif mod_char == 'A':
            mods.append('Alt')
        elif mod_char == 'M':
            mods.append('Meta')
        main_key = match.group(2)
        # Check if there are more modifiers
        if main_key.startswith('<'):
            match = re.match(mod_pattern, main_key)
        else:
            break

    # Handle special keys
    special_keys = {
        '<Tab>': 'Tab',
        '<S-Tab>': 'Shift+Tab',
        '<CR>': 'Enter',
        '<Esc>': 'Esc',
        '<Space>': 'Space',
        '<BS>': 'Backspace',
    }

    if main_key in special_keys:
        main_key = special_keys[main_key]
    elif main_key.startswith('<') and main_key.endswith('>'):
        # Remove angle brackets for other special keys
        main_key = main_key[1:-1]

    return mods, main_key


if __name__ == "__main__":
    content = read_file(NIX_NIXVIM_PATH)
    if not content:
        print(json.dumps({"children": []}))
    else:
        parsed = parse_nixvim_keybinds(content)
        print(json.dumps(parsed))
