#!/usr/bin/env python3
"""
Neovim keybind parser for nvf.nix configurations.
Reads keybinds from nvf.nix maps section and outputs JSON for quickshell cheatsheet.
"""
import argparse
import re
import os
import json
from typing import Dict, List, Any

NIX_NVF_PATH = "/etc/nixos/home/modules/nvf.nix"

parser = argparse.ArgumentParser(description='Neovim keybind reader for nvf.nix')
parser.add_argument('--path', type=str, default=NIX_NVF_PATH,
                    help='ignored - always reads from Nix source')
args = parser.parse_args()


def read_file(path: str) -> str:
    """Read a file and return its content."""
    expanded_path = os.path.expanduser(os.path.expandvars(path))
    if not os.access(expanded_path, os.R_OK):
        return ""
    with open(expanded_path, "r") as file:
        return file.read()


def parse_nvf_keybinds(content: str) -> Dict[str, Any]:
    """Parse nvf.nix content and extract keybinds from maps section."""
    result = {
        "children": []
    }

    # Find the maps section
    maps_match = re.search(r'maps\s*=\s*\{', content)
    if not maps_match:
        return result

    # Extract each mode section (normal, insert, terminal, visual)
    modes = ['normal', 'insert', 'terminal', 'visual']

    for mode in modes:
        # Find the mode section
        mode_pattern = rf'{mode}\s*=\s*\{{'
        mode_match = re.search(mode_pattern, content)
        if not mode_match:
            continue

        # Find the content of this mode section
        start = mode_match.end()
        brace_count = 1
        end = start

        while brace_count > 0 and end < len(content):
            if content[end] == '{':
                brace_count += 1
            elif content[end] == '}':
                brace_count -= 1
            end += 1

        mode_content = content[start:end-1]
        keybinds = parse_mode_keybinds(mode_content)

        if keybinds:
            # Capitalize mode name for display
            mode_name = mode.capitalize()
            if mode == 'normal':
                mode_name = "Normal Mode"
            elif mode == 'insert':
                mode_name = "Insert Mode"
            elif mode == 'terminal':
                mode_name = "Terminal Mode"
            elif mode == 'visual':
                mode_name = "Visual Mode"

            result["children"].append({
                "name": mode_name,
                "keybinds": keybinds,
                "children": []
            })

    # Group keybinds by category based on comments in the nix file
    result = group_by_category(content, result)

    return result


def parse_mode_keybinds(mode_content: str) -> List[Dict[str, Any]]:
    """Parse keybinds from a mode section."""
    keybinds = []

    # Pattern to match keybind definitions like:
    # "<leader>cc" = { action = "..."; desc = "..."; };
    # or "<C-s>" = { action = "..."; desc = "..."; };
    keybind_pattern = r'"([^"]+)"\s*=\s*\{\s*action\s*=\s*"([^"]+)";\s*desc\s*=\s*"([^"]+)";\s*\}'

    for match in re.finditer(keybind_pattern, mode_content):
        key = match.group(1)
        action = match.group(2)
        desc = match.group(3)

        # Parse the key into mods and key
        mods, main_key = parse_vim_key(key)

        keybinds.append({
            "mods": mods,
            "key": main_key,
            "action": action,
            "comment": desc
        })

    return keybinds


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


def group_by_category(content: str, result: Dict) -> Dict:
    """Group keybinds by category based on comments in the source."""
    # Define categories based on common patterns
    categories = {
        "Claude Code": ["cc", "ch"],
        "Terminal": ["tv", "th", "tt"],
        "File Operations": ["C-s", "C-q"],
        "Navigation": ["C-p", "C-f", "e", "o"],
        "Buffers": ["Tab", "S-Tab", "x", "b"],
        "Windows": ["C-h", "C-j", "C-k", "C-l"],
        "LSP": ["gd", "gr", "K", "rn", "ca", "d"],
        "Git": ["gg", "gb", "gd", "gl"],
    }

    # For now, just return the mode-based grouping
    # A more sophisticated implementation could re-organize by category
    return result


if __name__ == "__main__":
    content = read_file(NIX_NVF_PATH)
    if not content:
        print(json.dumps({"children": []}))
    else:
        parsed = parse_nvf_keybinds(content)
        print(json.dumps(parsed))
