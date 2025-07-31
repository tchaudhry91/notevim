# NoteVim

A minimalist Neovim plugin for note-taking with Git synchronization.

## Features

- **S3-style paths**: Organize notes with nested paths like `personal/house/renovation.md`
- **Unified search**: Search recent notes or search content with ripgrep
- **Git sync**: Simple bidirectional sync with your git repository
- **Telescope integration**: Beautiful search interface with quickfix fallback
- **Tag system**: Automatic tag line insertion for new notes

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "your-username/notevim",
  config = function()
    require("notevim").setup({
      notes_dir = "~/Notes",  -- Default: ~/Notes
    })
  end,
}
```

## Commands

- `:Note <path>` - Create or open a note (e.g., `:Note personal/ideas`)
- `:NoteSearch [query]` - Search notes (no query shows recent notes)
- `:NoteSync` - Sync notes with git repository

## Dependencies

- **Required**: Neovim 0.7+
- **Optional**: [ripgrep](https://github.com/BurntSushi/ripgrep) for content search
- **Optional**: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for enhanced search UI
- **Optional**: git for sync functionality

## Usage

### Creating Notes

```
:Note personal/journal
:Note work/meeting-notes
:Note project/ideas
```

### Searching Notes

```
:NoteSearch                    " Show recent notes
:NoteSearch project            " Search for 'project' in all notes
:NoteSearch #personal          " Search for #personal tag
```

### Git Sync

```
:NoteSync                      " Pull, commit, and push changes
```

## Configuration

```lua
require("notevim").setup({
  notes_dir = "~/Documents/Notes",  -- Custom notes directory
})
```

## Testing

Run basic tests:

```bash
./run_basic_tests.sh
```
