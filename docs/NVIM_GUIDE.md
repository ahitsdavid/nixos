# Neovim Guide

A practical guide to using your custom Neovim setup for everyday development.

---

## Getting Started

### The Basics: Modes

Neovim has different "modes" - this is what makes it powerful (and confusing at first):

| Mode | How to Enter | What It's For |
|------|--------------|---------------|
| **Normal** | Press `Esc` | Navigation, commands, most keybinds work here |
| **Insert** | Press `i` | Actually typing text |
| **Visual** | Press `v` | Selecting text |
| **Command** | Press `:` | Running commands like `:w` (save) or `:q` (quit) |

**Golden rule:** When in doubt, press `Esc` to get back to Normal mode.

### The Leader Key

Many shortcuts start with the **leader key**, which is `Space` in your config.

When you see `Space+e`, it means: press Space, then press e.

### Your First Session

```bash
nvim                    # Open nvim
nvim myfile.py          # Open a specific file
nvim .                  # Open in current directory
```

---

## Essential Shortcuts

### Saving and Quitting

| Shortcut | Action |
|----------|--------|
| `Ctrl+s` | Save file (works in Normal and Insert mode) |
| `Ctrl+q` | Close current window |
| `:w` | Save file |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:q!` | Quit without saving (force) |

### Finding Files and Text

| Shortcut | Action |
|----------|--------|
| `Ctrl+p` | **Find files** in project (fuzzy search) |
| `Ctrl+f` | **Search text** across all files |
| `Space+b` | List open buffers (files) |
| `Space+e` | Toggle file tree sidebar |
| `Space+o` | Focus file tree sidebar |

**Tip:** In the file finder, just start typing - it's fuzzy, so "mcon" matches "myconfig.nix".

---

## Working with Files (Buffers)

In Neovim, open files are called "buffers". Think of them as browser tabs.

| Shortcut | Action |
|----------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `Space+x` | Close current buffer |
| `Space+b` | Show all open buffers |

The buffer tabs are shown at the top of your screen.

---

## Windows (Split Views)

You can split your screen to see multiple files at once.

### Creating Splits

| Shortcut | Action |
|----------|--------|
| `Space+tv` | Terminal in vertical split |
| `Space+th` | Terminal in horizontal split |
| `Space+cc` | Claude Code in vertical split |
| `Space+ch` | Claude Code in horizontal split |
| `:vsplit filename` | Open file in vertical split |
| `:split filename` | Open file in horizontal split |

### Moving Between Windows

| Shortcut | Action |
|----------|--------|
| `Ctrl+h` | Move to left window |
| `Ctrl+j` | Move to bottom window |
| `Ctrl+k` | Move to top window |
| `Ctrl+l` | Move to right window |

**Tip:** You can also click with your mouse - mouse support is enabled!

---

## The File Tree (Neo-tree)

| Shortcut | Action |
|----------|--------|
| `Space+e` | Toggle file tree |
| `Space+o` | Focus file tree |

When in the file tree:
- `Enter` - Open file
- `a` - Create new file
- `d` - Delete file
- `r` - Rename file
- `c` - Copy file
- `m` - Move file
- `q` - Close file tree

---

## Code Navigation (LSP)

Your setup includes "Language Server Protocol" support, which gives you IDE-like features.

| Shortcut | Action |
|----------|--------|
| `gd` | **Go to definition** - jump to where something is defined |
| `gr` | **Find references** - see everywhere something is used |
| `K` | **Hover info** - show documentation popup |
| `Space+rn` | **Rename** symbol across all files |
| `Space+ca` | **Code actions** - quick fixes, refactors |
| `Space+d` | Show **diagnostics** (errors/warnings) for current line |

### Diagnostics

Errors and warnings appear as icons in the left margin. Press `Space+d` to see details.

---

## Git Integration

| Shortcut | Action |
|----------|--------|
| `Space+gg` | Open Git status (fugitive) |
| `Space+gb` | Show Git blame for current file |

In Git status (`:Git`):
- `s` - Stage file
- `u` - Unstage file
- `cc` - Commit
- `=` - Toggle diff
- `q` - Close

Signs in the left margin show changed lines:
- Green `│` - Added lines
- Blue `│` - Changed lines
- Red `_` - Deleted lines

---

## Terminal

| Shortcut | Action |
|----------|--------|
| `Space+tt` | Terminal in new tab |
| `Space+tv` | Terminal in vertical split |
| `Space+th` | Terminal in horizontal split |

**Important:** The terminal starts in "terminal mode". To get out:
- Press `Esc` to exit terminal mode (back to Normal)
- Then you can use `Ctrl+h/j/k/l` to move to other windows

To type in the terminal again, press `i` to enter Insert mode.

---

## Claude Code in Neovim

Your setup has shortcuts for working with Claude Code:

| Shortcut | Action |
|----------|--------|
| `Space+cc` | Open Claude Code in vertical split |
| `Space+ch` | Open Claude Code in horizontal split |

**Workflow:**
1. Open your project in nvim
2. Press `Space+cc` to open Claude in a split
3. Use `Ctrl+h/l` to switch between code and Claude
4. Press `Esc` when in Claude's terminal to move around
5. Press `i` to type to Claude again

---

## Editing Essentials

### Basic Movement (Normal Mode)

| Key | Movement |
|-----|----------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |
| `w` | Next word |
| `b` | Previous word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | Top of file |
| `G` | Bottom of file |

**Or just use arrow keys and mouse** - they work too!

### Editing

| Shortcut | Action |
|----------|--------|
| `i` | Insert at cursor |
| `a` | Insert after cursor |
| `o` | Insert new line below |
| `O` | Insert new line above |
| `dd` | Delete line |
| `yy` | Copy (yank) line |
| `p` | Paste below |
| `P` | Paste above |
| `u` | Undo |
| `Ctrl+r` | Redo |

### Selecting Text (Visual Mode)

1. Press `v` to start selecting
2. Move with `h/j/k/l` or arrow keys
3. Then:
   - `d` to delete
   - `y` to copy
   - `c` to change (delete and enter insert mode)

### Comments

| Shortcut | Action |
|----------|--------|
| `gcc` | Toggle comment on current line |
| `gc` + motion | Comment a range (e.g., `gc3j` comments 3 lines down) |

In Visual mode, select lines then press `gc` to toggle comments.

### Surround Text

| Shortcut | Action |
|----------|--------|
| `ysiw"` | Surround word with quotes |
| `cs"'` | Change surrounding `"` to `'` |
| `ds"` | Delete surrounding quotes |

---

## Searching Within a File

| Shortcut | Action |
|----------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `*` | Search for word under cursor |

Press `Esc` or `:noh` to clear search highlighting.

---

## Telescope (Fuzzy Finder)

Telescope is your Swiss Army knife for finding things:

| Shortcut | Opens |
|----------|-------|
| `Ctrl+p` | File finder |
| `Ctrl+f` | Live grep (search in files) |
| `Space+b` | Buffer list |
| `gr` | LSP references |

In Telescope:
- Type to filter
- `Ctrl+j/k` or arrows to move
- `Enter` to select
- `Ctrl+v` to open in vertical split
- `Ctrl+x` to open in horizontal split
- `Esc` to close

---

## Quick Reference Card

```
SURVIVAL
  Esc         → Normal mode (when lost)
  :w          → Save
  :q          → Quit
  Ctrl+s      → Save (easier)

FILES
  Ctrl+p      → Find files
  Ctrl+f      → Search in project
  Space+e     → File tree
  Tab/S-Tab   → Next/prev buffer

WINDOWS
  Ctrl+h/j/k/l → Move between windows
  Space+tv     → Terminal (vertical)
  Space+cc     → Claude Code

CODE
  gd          → Go to definition
  gr          → Find references
  K           → Hover docs
  Space+ca    → Code actions

GIT
  Space+gg    → Git status
  gcc         → Toggle comment
```

---

## Getting Help

| Command | Description |
|---------|-------------|
| `Space+/` | Open cheatsheet |
| `:help keyword` | Open help for keyword |
| `:Telescope help_tags` | Search help topics |

---

## Tips for Beginners

1. **Start simple** - Use `Ctrl+p` to open files, `Ctrl+s` to save. That's enough to start.

2. **Use the mouse** - It's enabled! Click to position cursor, scroll, resize windows.

3. **When stuck, press `Esc`** - This gets you back to Normal mode.

4. **Press `Space` and wait** - Which-key will show you available options.

5. **Don't memorize everything** - Learn shortcuts as you need them.

6. **The cheatsheet is your friend** - Press `Space+/` anytime.

---

## Your Workflow with Claude Code

A suggested workflow for using nvim with Claude:

1. **Open your project:**
   ```bash
   cd ~/myproject
   nvim .
   ```

2. **Find the file you want to work on:**
   - Press `Ctrl+p` and type part of the filename

3. **Open Claude Code:**
   - Press `Space+cc` for a vertical split

4. **Work together:**
   - `Ctrl+l` to focus Claude
   - `i` to type to Claude
   - `Esc` then `Ctrl+h` to go back to your code
   - Changes Claude makes appear in real-time

5. **Save your work:**
   - `Ctrl+s` to save current file
   - `:wa` to save all files

---

*Remember: Neovim is a skill that improves with practice. Start with the basics and add more shortcuts as they become natural.*
