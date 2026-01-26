#!/usr/bin/env python3
"""
Terminal keybind and alias parser for Nix configurations.
Reads keybinds from kitty.nix and aliases from various shell configs.
Outputs JSON for quickshell cheatsheet.
"""
import argparse
import re
import os
import json
from typing import Dict, List, Any

NIX_BASE_PATH = "/etc/nixos/home/modules"

parser = argparse.ArgumentParser(description='Terminal keybind reader for Nix files')
parser.add_argument('--path', type=str, default=NIX_BASE_PATH, help='ignored')
args = parser.parse_args()


def read_file(path: str) -> str:
    """Read a file and return its content."""
    expanded_path = os.path.expanduser(os.path.expandvars(path))
    if not os.access(expanded_path, os.R_OK):
        return ""
    with open(expanded_path, "r") as file:
        return file.read()


def parse_kitty_keybinds(content: str) -> List[Dict[str, Any]]:
    """Parse kitty.nix extraConfig for keybinds."""
    keybinds = []

    # Find extraConfig section
    extra_match = re.search(r"extraConfig\s*=\s*''(.*?)'';", content, re.DOTALL)
    if not extra_match:
        return keybinds

    extra_content = extra_match.group(1)
    current_section = "General"

    for line in extra_content.split('\n'):
        line = line.strip()

        # Check for section comments
        if line.startswith('#') and not line.startswith('#map'):
            section_text = line.lstrip('#').strip()
            if section_text and len(section_text) < 30:
                current_section = section_text
            continue

        # Parse map statements
        # Format: map <key> <action> [args]
        map_match = re.match(r'^map\s+(\S+)\s+(\S+)(.*)$', line)
        if map_match:
            key = map_match.group(1)
            action = map_match.group(2)
            args = map_match.group(3).strip() if map_match.group(3) else ""

            # Check for inline comment
            comment = ""
            if '#' in args:
                args, comment = args.split('#', 1)
                args = args.strip()
                comment = comment.strip()

            # Generate description if no comment
            if not comment:
                comment = format_kitty_action(action, args)

            mods, main_key = parse_kitty_key(key)

            keybinds.append({
                "mods": mods,
                "key": main_key,
                "action": action,
                "comment": comment,
                "section": current_section
            })

    return keybinds


def parse_kitty_key(key: str) -> tuple:
    """Parse kitty key notation into mods and main key."""
    mods = []
    parts = key.split('+')

    mod_map = {
        'ctrl': 'Ctrl',
        'shift': 'Shift',
        'alt': 'Alt',
        'super': 'Super',
    }

    main_key = parts[-1]
    for part in parts[:-1]:
        mod = mod_map.get(part.lower(), part)
        mods.append(mod)

    return mods, main_key


def format_kitty_action(action: str, args: str) -> str:
    """Generate human-readable description for kitty actions."""
    action_map = {
        'paste_from_selection': 'Paste from selection',
        'scroll_line_up': 'Scroll up one line',
        'scroll_line_down': 'Scroll down one line',
        'scroll_page_up': 'Scroll page up',
        'scroll_page_down': 'Scroll page down',
        'scroll_home': 'Scroll to top',
        'scroll_end': 'Scroll to bottom',
        'show_scrollback': 'Show scrollback',
        'new_window_with_cwd': 'New window (same dir)',
        'new_os_window': 'New OS window',
        'close_window': 'Close window',
        'next_window': 'Next window',
        'previous_window': 'Previous window',
        'move_window_forward': 'Move window forward',
        'move_window_backward': 'Move window backward',
        'move_window_to_top': 'Move window to top',
        'first_window': 'Go to window 1',
        'second_window': 'Go to window 2',
        'third_window': 'Go to window 3',
        'fourth_window': 'Go to window 4',
        'fifth_window': 'Go to window 5',
        'sixth_window': 'Go to window 6',
        'seventh_window': 'Go to window 7',
        'eighth_window': 'Go to window 8',
        'ninth_window': 'Go to window 9',
        'tenth_window': 'Go to window 10',
        'next_tab': 'Next tab',
        'previous_tab': 'Previous tab',
        'new_tab': 'New tab',
        'close_tab': 'Close tab',
        'next_layout': 'Next layout',
        'move_tab_forward': 'Move tab forward',
        'move_tab_backward': 'Move tab backward',
        'increase_font_size': 'Increase font size',
        'decrease_font_size': 'Decrease font size',
        'restore_font_size': 'Restore font size',
    }

    if action in action_map:
        return action_map[action]

    if action == 'launch':
        if '--location=hsplit' in args:
            return 'Horizontal split'
        elif '--location=vsplit' in args:
            return 'Vertical split'
        return f'Launch: {args}'

    return action.replace('_', ' ').title()


def parse_shell_aliases(content: str, source_name: str) -> List[Dict[str, Any]]:
    """Parse shellAliases from a Nix file."""
    aliases = []

    # Find shellAliases blocks
    patterns = [
        r'shellAliases\s*=\s*\{([^}]+)\}',
        r'home\.shellAliases\s*=\s*\{([^}]+)\}',
    ]

    for pattern in patterns:
        for match in re.finditer(pattern, content, re.DOTALL):
            block = match.group(1)

            # Parse each alias
            alias_pattern = r'(\w+(?:-\w+)*)\s*=\s*"([^"]+)"'
            for alias_match in re.finditer(alias_pattern, block):
                name = alias_match.group(1)
                command = alias_match.group(2)

                aliases.append({
                    "name": name,
                    "command": command,
                    "source": source_name
                })

    return aliases


def group_keybinds_by_section(keybinds: List[Dict]) -> List[Dict]:
    """Group keybinds by their section."""
    sections = {}
    for kb in keybinds:
        section = kb.get('section', 'General')
        if section not in sections:
            sections[section] = []
        sections[section].append({
            "mods": kb['mods'],
            "key": kb['key'],
            "comment": kb['comment']
        })

    return [{"name": name, "keybinds": kbs, "children": []} for name, kbs in sections.items()]


def main():
    result = {"children": []}

    # Parse kitty keybinds
    kitty_content = read_file(f"{NIX_BASE_PATH}/kitty.nix")
    if kitty_content:
        kitty_keybinds = parse_kitty_keybinds(kitty_content)
        if kitty_keybinds:
            kitty_sections = group_keybinds_by_section(kitty_keybinds)
            result["children"].append({
                "name": "Kitty",
                "keybinds": [],
                "children": kitty_sections
            })

    # Parse shell aliases from various sources
    all_aliases = []

    alias_sources = [
        (f"{NIX_BASE_PATH}/zsh/default.nix", "ZSH"),
        (f"{NIX_BASE_PATH}/eza.nix", "Eza"),
        (f"{NIX_BASE_PATH}/claude.nix", "Claude"),
    ]

    for path, source in alias_sources:
        content = read_file(path)
        if content:
            aliases = parse_shell_aliases(content, source)
            all_aliases.extend(aliases)

    if all_aliases:
        # Deduplicate aliases by name (keep first occurrence)
        seen = set()
        unique_aliases = []
        for alias in all_aliases:
            if alias['name'] not in seen:
                seen.add(alias['name'])
                unique_aliases.append(alias)

        # Convert aliases to keybind-like format for display
        alias_keybinds = []
        for alias in unique_aliases:
            alias_keybinds.append({
                "mods": [],
                "key": alias['name'],
                "comment": alias['command']
            })

        result["children"].append({
            "name": "Shell Aliases",
            "keybinds": alias_keybinds,
            "children": []
        })

    print(json.dumps(result))


if __name__ == "__main__":
    main()
