# NoteVim Plugin Plan

## Overview
A minimalist Neovim plugin for note-taking with Git synchronization, written in pure Lua.

## Core Architecture

### Plugin Structure
```
notevim/
├── lua/
│   └── notevim/
│       ├── init.lua          # Main plugin logic, setup, and commands
│       └── search.lua        # Search functionality with Telescope
├── plugin/
│   └── notevim.lua          # Plugin initialization
└── doc/
    └── notevim.txt          # Help documentation
```

### Design Principles
- Minimal complexity - only essential features
- No unnecessary abstractions
- Convention over configuration
- Let Git handle Git things (conflicts, etc.)

## Features Breakdown

### 1. Note Creation
**What's Needed:**
- `:Note <path>` - Create/open note at path (path required)
- Automatically insert `tags: ` as first line for new notes
- Create directories as needed
- No auto-save

**Implementation:**
- Simple buffer creation with path
- Direct template insertion (no template system)

### 2. Organization
**What's Needed:**
- S3-style paths (e.g., `personal/house/renovation.md`)
- Convention: first line is always `tags: #tag1 #tag2`
- Single configuration: notes root directory

**Implementation:**
- Path validation within notes root
- No tag autocomplete (unnecessary complexity)

### 3. Search
**What's Needed:**
- `:NoteSearch` - Unified search, defaults to recent notes if no query
- Search content, filenames, and tags when query provided
- Telescope integration with fallback to quickfix

**Implementation:**
- Single search command using ripgrep
- Show 10 recent notes when called without arguments

### 4. Git Sync
**What's Needed:**
- `:NoteSync` - Combined pull, commit, and push
- Simple timestamp commit messages
- Let Git handle errors/conflicts

**Implementation:**
- Simple synchronous Git commands
- No auto-pull before search


## Configuration
```lua
require('notevim').setup({
  notes_dir = "~/notes"  -- Your git repo location
})
```

## Commands
- `:Note <path>` - Create/open note at path
- `:NoteSearch [query]` - Search notes (recent if no query)
- `:NoteSync` - Pull, commit, and push changes

## Keybindings
- `<leader>ns` - Search notes (shows recent if no query)
- `<leader>ng` - Git sync

## Implementation Plan

### Single Implementation Phase
1. Note creation with `:Note <path>` command
2. Unified search with `:NoteSearch` (recent notes as default)
3. Git sync with `:NoteSync`
4. Basic documentation

Total estimated effort: ~250 lines of Lua code

## Technical Notes
- No external dependencies except optional Telescope
- Auto-detect Telescope availability
- Use vim.notify for error messages
- Keep it simple and focused