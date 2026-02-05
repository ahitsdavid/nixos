# Neovim Guide

A practical guide to your custom Neovim setup.

---

## Getting Started

### Modes

| Mode | Enter With | Purpose |
|------|------------|---------|
| **Normal** | `Esc` | Navigation, commands |
| **Insert** | `i` | Typing text |
| **Visual** | `v` | Selecting text |
| **Command** | `:` | Running commands |

**When lost, press `Esc`**

### Leader Key

Your leader key is `Space`. When you see `Space+e`, press Space then e.

---

## Essential Shortcuts

### Save & Quit

| Shortcut | Action |
|----------|--------|
| `Ctrl+s` | Save |
| `Ctrl+q` | Close window |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |

### Find Files & Text

| Shortcut | Action |
|----------|--------|
| `Ctrl+p` | Find files |
| `Ctrl+f` | Search in project |
| `Space+b` | List open buffers |
| `Space+e` | Toggle file tree |

---

## Buffers (Open Files)

| Shortcut | Action |
|----------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `Space+x` | Close buffer |
| `Space+b` | Show all buffers |

---

## Windows (Splits)

### Create Splits

| Shortcut | Action |
|----------|--------|
| `Space+tv` | Terminal vertical |
| `Space+th` | Terminal horizontal |
| `Space+cc` | Claude Code vertical |
| `Space+ch` | Claude Code horizontal |

### Navigate Windows

| Shortcut | Action |
|----------|--------|
| `Ctrl+h` | Left window |
| `Ctrl+j` | Down window |
| `Ctrl+k` | Up window |
| `Ctrl+l` | Right window |

Mouse also works!

---

## File Tree (Neo-tree)

| Shortcut | Action |
|----------|--------|
| `Space+e` | Toggle tree |
| `Space+o` | Focus tree |

In the tree:
- `Enter` - Open file
- `a` - New file
- `d` - Delete
- `r` - Rename
- `q` - Close tree

---

## Code Navigation (LSP)

| Shortcut | Action |
|----------|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover info |
| `Space+rn` | Rename symbol |
| `Space+ca` | Code actions |
| `Space+d` | Show diagnostics |

---

## Git

| Shortcut | Action |
|----------|--------|
| `Space+gg` | Git status |
| `Space+gb` | Git blame |
| `Space+gd` | Git diff |
| `Space+gl` | Git log |

Line signs:
- Green `│` - Added
- Blue `│` - Changed
- Red `_` - Deleted

---

## Terminal

| Shortcut | Action |
|----------|--------|
| `Space+tt` | Terminal in new tab |
| `Space+tv` | Terminal vertical |
| `Space+th` | Terminal horizontal |
| `Esc` | Exit terminal mode |

Press `i` to type in terminal again.

---

## Claude Code Workflow

1. Open project: `nvim .`
2. Find file: `Ctrl+p`
3. Open Claude: `Space+cc`
4. Switch windows: `Ctrl+h` / `Ctrl+l`
5. Exit Claude terminal: `Esc`
6. Type to Claude: `i`
7. Save: `Ctrl+s`

Files auto-reload when Claude edits them.

---

## Editing Basics

### Movement

| Key | Movement |
|-----|----------|
| `h/j/k/l` | Left/Down/Up/Right |
| `w` / `b` | Next/prev word |
| `0` / `$` | Start/end of line |
| `gg` / `G` | Top/bottom of file |

Arrow keys and mouse work too!

### Editing

| Shortcut | Action |
|----------|--------|
| `i` | Insert at cursor |
| `o` | New line below |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `gcc` | Toggle comment |

### Surround

| Shortcut | Action |
|----------|--------|
| `ysiw"` | Surround word with " |
| `cs"'` | Change " to ' |
| `ds"` | Delete surrounding " |

---

## Search

| Shortcut | Action |
|----------|--------|
| `/pattern` | Search forward |
| `n` / `N` | Next/prev match |
| `*` | Search word under cursor |

---

## Quick Reference

```
BASICS
  Esc           Normal mode
  Ctrl+s        Save
  Ctrl+p        Find files
  Ctrl+f        Search project

FILES
  Space+e       File tree
  Tab/S-Tab     Next/prev buffer
  Space+x       Close buffer

WINDOWS
  Ctrl+h/j/k/l  Move between windows
  Space+cc      Claude Code
  Space+tv      Terminal

CODE
  gd            Go to definition
  gr            References
  K             Hover docs
  Space+ca      Code actions

GIT
  Space+gg      Status
  Space+gd      Diff
  gcc           Comment
```

---

## Tips

1. **Use the mouse** - it works for everything
2. **Press Space and wait** - shows available options
3. **When stuck, press Esc** - back to normal mode
4. **Ctrl+p is your friend** - find any file fast
5. **Files auto-reload** - Claude's changes appear automatically
