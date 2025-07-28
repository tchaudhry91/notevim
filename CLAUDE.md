# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NoteVim is a minimalist Neovim plugin for note-taking with Git synchronization. The plugin is currently in planning phase with no implementation yet.

## Architecture

The plugin follows a minimal Lua architecture:
- `lua/notevim/init.lua` - Main plugin logic, setup, and commands
- `lua/notevim/search.lua` - Search functionality with Telescope integration
- `plugin/notevim.lua` - Plugin initialization and command definitions

## Key Design Decisions

1. **S3-style paths**: Notes use nested paths like `personal/house/renovation.md` with no date prefixes
2. **No auto-save**: All saves are manual to give users control
3. **Minimal Git integration**: Single `:NoteSync` command, user manages repo setup
4. **Tag system**: First line of every note contains `tags: #tag1 #tag2`
5. **Unified search**: `:NoteSearch` shows recent notes by default, searches when given query
6. **Telescope optional**: Fallback to quickfix if not available

## Development Commands

Since this is a Neovim plugin in development:

```bash
# Run tests (when implemented)
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Manual testing in Neovim
:luafile lua/notevim/init.lua
:lua require('notevim').setup({ notes_dir = '~/test-notes' })
```

## Implementation Priorities

Single implementation phase:
1. Core note creation (`:Note <path>` command)
2. Unified search functionality (`:NoteSearch`)
3. Git sync (`:NoteSync`)
4. Basic documentation

## Testing Considerations

- Test with and without Telescope installed
- Verify S3-style path creation works across platforms
- Ensure Git operations handle errors gracefully
- Test unified search with various query types