# VSCode Guide

A guide to your custom VSCode setup for Python, C++, and web development.

---

## Getting Started

### Opening Projects

```bash
code .                  # Open current directory
code myfile.py          # Open specific file
code ~/projects/myapp   # Open project folder
```

### Command Palette

`Ctrl+Shift+P` - Access any command. Start typing to search.

---

## Essential Shortcuts

### Files

| Shortcut | Action |
|----------|--------|
| `Ctrl+s` | Save |
| `Ctrl+p` | Quick open file |
| `Ctrl+Shift+p` | Command palette |
| `Ctrl+w` | Close tab |
| `Ctrl+Tab` | Switch tabs |
| `Ctrl+\` | Split editor |

### Editing

| Shortcut | Action |
|----------|--------|
| `Ctrl+c` | Copy |
| `Ctrl+x` | Cut |
| `Ctrl+v` | Paste |
| `Ctrl+z` | Undo |
| `Ctrl+Shift+z` | Redo |
| `Ctrl+d` | Select word (repeat for more) |
| `Ctrl+/` | Toggle comment |
| `Alt+Up/Down` | Move line |
| `Shift+Alt+Up/Down` | Duplicate line |
| `Ctrl+Shift+k` | Delete line |

### Search

| Shortcut | Action |
|----------|--------|
| `Ctrl+f` | Find in file |
| `Ctrl+h` | Find and replace |
| `Ctrl+Shift+f` | Search all files |
| `Ctrl+Shift+h` | Replace in all files |

### Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+g` | Go to line |
| `Ctrl+p` | Go to file |
| `Ctrl+Shift+o` | Go to symbol in file |
| `Ctrl+t` | Go to symbol in workspace |
| `F12` | Go to definition |
| `Shift+F12` | Find all references |
| `Ctrl+click` | Go to definition |
| `Alt+Left/Right` | Navigate back/forward |

---

## Sidebar

| Shortcut | Action |
|----------|--------|
| `Ctrl+b` | Toggle sidebar |
| `Ctrl+Shift+e` | Explorer |
| `Ctrl+Shift+f` | Search |
| `Ctrl+Shift+g` | Source Control (Git) |
| `Ctrl+Shift+d` | Debug |
| `Ctrl+Shift+x` | Extensions |

---

## Terminal

| Shortcut | Action |
|----------|--------|
| `` Ctrl+` `` | Toggle terminal |
| `` Ctrl+Shift+` `` | New terminal |
| `Ctrl+Shift+5` | Split terminal |

---

## Code Intelligence (LSP)

Your setup includes language servers for Python, C++, Nix, TypeScript, and more.

| Shortcut | Action |
|----------|--------|
| `F12` | Go to definition |
| `Shift+F12` | Find references |
| `Ctrl+Space` | Trigger autocomplete |
| `Ctrl+.` | Quick fix / Code actions |
| `F2` | Rename symbol |
| `Ctrl+Shift+Space` | Parameter hints |
| `Ctrl+k Ctrl+i` | Show hover |

### Error Navigation

| Shortcut | Action |
|----------|--------|
| `F8` | Next error/warning |
| `Shift+F8` | Previous error/warning |

Errors appear inline (Error Lens is enabled).

---

## Git Integration

### Source Control View

`Ctrl+Shift+g` to open.

| Action | How |
|--------|-----|
| Stage file | Click `+` |
| Unstage | Click `-` |
| Commit | Type message, `Ctrl+Enter` |
| Push | Click `...` menu |

### GitLens Features

- **Hover** over lines to see last change
- **Click gutter** for line history
- **Blame annotations** in editor

### Git Graph

`Ctrl+Shift+p` → "Git Graph: View Git Graph"

Visualize branches, commits, and history.

### Diff Navigation

| Shortcut | Action |
|----------|--------|
| `F7` | Next change in diff |
| `Shift+F7` | Previous change |

---

## Working with Claude Code

Your setup auto-reloads files when Claude edits them.

### Workflow

1. Open terminal: `` Ctrl+` ``
2. Run `claude` in terminal
3. Work with Claude
4. Files update automatically in editor
5. Review changes in Source Control (`Ctrl+Shift+g`)

### Tips

- Split terminal to keep Claude visible
- Use Git diff to review changes
- GitLens shows what changed and when

---

## Language-Specific Features

### Python

- **Formatter:** Ruff (auto-formats on save)
- **Linting:** Ruff + Pylance
- **Type checking:** Basic mode enabled
- **Auto-imports:** Enabled

| Shortcut | Action |
|----------|--------|
| `F5` | Run/Debug |
| `F9` | Toggle breakpoint |
| `Ctrl+.` | Auto-import suggestion |

### C/C++

- **Formatter:** clangd
- **LSP:** clangd (cpptools intellisense disabled)
- **Debugging:** cpptools debugger

Generate `compile_commands.json` with `bear`:
```bash
bear -- make        # or
bear -- cmake ..    # in build dir
```

### Nix

- **LSP:** nil
- **Formatter:** nixfmt via nix-ide

### TypeScript/JavaScript

- **Formatter:** Prettier
- **LSP:** Built-in TypeScript

### Docker

- **Syntax:** Dockerfile support
- **Compose:** docker-compose.yml support

---

## Debugging

| Shortcut | Action |
|----------|--------|
| `F5` | Start debugging |
| `Shift+F5` | Stop |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Ctrl+Shift+d` | Debug sidebar |

---

## Multi-Cursor Editing

| Shortcut | Action |
|----------|--------|
| `Ctrl+d` | Select word, repeat for next occurrence |
| `Ctrl+Shift+l` | Select all occurrences |
| `Alt+Click` | Add cursor |
| `Ctrl+Alt+Up/Down` | Add cursor above/below |

---

## Useful Settings (Already Configured)

- **Auto-save:** 1 second delay
- **Format on save:** Enabled
- **Trim whitespace:** Enabled
- **Bracket colorization:** Enabled
- **Sticky scroll:** Function headers stay visible
- **Error Lens:** Inline error display
- **Minimap:** Disabled (more space)

---

## Installed Extensions

| Extension | Purpose |
|-----------|---------|
| **Python** | Python support |
| **Pylance** | Python intellisense |
| **Ruff** | Fast Python linting |
| **C/C++** | C++ support |
| **clangd** | C++ LSP |
| **CMake Tools** | CMake support |
| **Docker** | Container support |
| **Nix IDE** | Nix support |
| **GitLens** | Git supercharged |
| **Git Graph** | Visualize git |
| **Error Lens** | Inline errors |
| **Path Intellisense** | Path completion |
| **Todo Tree** | Track TODOs |
| **Prettier** | Code formatter |
| **Tailwind CSS** | CSS support |
| **Remote SSH** | Remote development |
| **Dev Containers** | Container development |

---

## Quick Reference

```
FILES
  Ctrl+p          Find file
  Ctrl+s          Save
  Ctrl+w          Close tab
  Ctrl+\          Split editor

EDIT
  Ctrl+d          Select word (multi)
  Ctrl+/          Comment
  Alt+Up/Down     Move line
  Ctrl+.          Quick fix

NAVIGATE
  F12             Go to definition
  Shift+F12       Find references
  Ctrl+g          Go to line
  Alt+Left        Go back

SEARCH
  Ctrl+f          Find
  Ctrl+Shift+f    Find in files

TERMINAL
  Ctrl+`          Toggle terminal

GIT
  Ctrl+Shift+g    Source control
  F7              Next change

DEBUG
  F5              Start debug
  F9              Breakpoint
  F10             Step over
```

---

## Tips

1. **Ctrl+p is fastest** for opening files
2. **Ctrl+Shift+p** accesses everything
3. **Ctrl+d** for quick multi-select edits
4. **Files auto-reload** when Claude edits them
5. **GitLens hover** shows who changed each line
6. **Error Lens** shows errors inline - no need to hover
7. **Split terminal** to keep Claude visible while coding
