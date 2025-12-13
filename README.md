# fluid-nvim

Framework for expressive and "fluid" Neovim configuration using fluent syntax

## Overview

Fluid-nvim is a modular Neovim configuration framework that provides a chainable, fluent API for configuring plugins and settings. It emphasizes readability, maintainability, and modularity by breaking functionality into opt-in modules with automatic dependency resolution.

## Key Features

- **Fluent API**: Chainable syntax for readable configuration
- **Modular Architecture**: 71 opt-in modules for different functionality
- **Automatic Plugin Management**: Handles plugin installation and updates
- **Dependency Resolution**: Automatic resolution between modules
- **Clean Separation**: Each module is self-contained with clear interfaces

## Installation

1. Clone to your Neovim configuration directory:
```bash
git clone https://github.com/yourusername/fluid-nvim ~/.config/nvim/pack/config/opt/fluid
```

2. Add to your `init.lua`:
```lua
vim.opt.rtp:prepend('~/.config/nvim/pack/config/opt/fluid')

local fluid = require('fluid')
fluid:setup(function(f)
  -- Your configuration here
  f:telescope()
    :lsp():options('icons', 'server_management')
    :treesitter()
    :cmp()
end)
```

## Usage

The fluent syntax supports multiple operators for chaining:

```lua
local fluid = require('fluid')
fluid:setup(function(f)
  -- Function call syntax
  f:telescope():lsp():treesitter()
  
  -- Alternative operators
  f + telescope + lsp + treesitter  -- Addition
  f % telescope % lsp % treesitter  -- Modulo
  f / telescope / lsp / treesitter  -- Division
  
  -- Options can be added with multiplication or subtraction
  f:lsp() * 'icons' * 'server_management'
  f:lsp() - 'unwanted_option'
end)
```

## Documentation

Complete documentation is available via Neovim's help system:
- `:help fluid-nvim` - Main documentation
- `:help fluid-module-{name}` - Individual module documentation

## Available Modules

Fluid includes 71 modules covering various aspects of Neovim functionality:

### Core Development
- **lsp** - Language Server Protocol with server management
- **cmp** - Intelligent completion with multiple sources  
- **treesitter** - Advanced syntax highlighting and parsing
- **telescope** - Powerful fuzzy finder with git integration
- **copilot** - GitHub Copilot AI assistance
- **ai** - AI coding assistant integration

### Language Support
- **typescript** - TypeScript/JavaScript development
- **csharp** - C# development with OmniSharp
- **fsharp** - F# development with FsAutoComplete  
- **css** - CSS development with language server
- **html** - HTML development with SuperHTML
- **lualang** - Lua language development
- **deno** - Deno runtime support
- **vue** - Vue.js framework support
- **svelte** - Svelte framework support
- **graphql** - GraphQL development
- **markdown** - Markdown rendering and editing
- **fennel** - Fennel Lisp dialect support
- **yue** - Yuescript language support
- **polyglot** - Multi-language syntax pack

### File Management
- **oil** - Buffer-based file management
- **nvimtree** - Modern tree file explorer
- **telescope** - Fuzzy file finding
- **fzf** - Alternative fuzzy finder
- **dirvish** - Minimal directory navigation
- **netrw** - Enhanced built-in file explorer
- **vifm** - Vifm file manager integration

### Git Integration  
- **fugitive** - Comprehensive git commands
- **gitsigns** - Git status indicators and hunks
- **lazygit** - LazyGit TUI integration
- **neogit** - Magit-inspired git interface
- **diffview** - Git diff visualization

### Navigation & Motion
- **harpoon** - File bookmark navigation
- **hop** - Quick motion with character hints
- **leap** - Motion with character sequences
- **arrow** - File bookmarking system
- **portal** - Enhanced jumplist navigation
- **precognition** - Motion hints for learning

### UI & Interface
- **aerial** - Code outline sidebar
- **whichkey** - Key binding discovery
- **dressing** - Enhanced UI elements
- **devicons** - File type icons
- **theme** - Color scheme management
- **statusline** - Custom status line
- **fluidline** - Advanced status line builder
- **winbar** - Window bar configuration

### Editing & Text Objects
- **autopairs** - Automatic bracket pairing
- **surround** - Text surrounding operations
- **comment** - Code commenting
- **emmet** - HTML/CSS abbreviation expansion
- **undotree** - Undo history visualization

### Completion & Snippets
- **cmp** - Main completion engine
- **coq** - Alternative completion (experimental)
- **vimcompletesme** - Simple completion

### Terminal & External Tools
- **fterm** - Floating terminal
- **asyncrun** - Asynchronous command execution
- **dispatch** - Build system integration
- **grepper** - Enhanced search with ripgrep
- **rest** - REST API client
- **dadbod** - Database integration

### Development Tools
- **images** - Image viewing support
- **devdocs** - Documentation lookup
- **syspackman** - System package management
- **qbuf** - Buffer-quickfix integration
- **buffish** - Advanced buffer navigation

### Specialized
- **vimwiki** - Personal wiki system
- **neorg** - Advanced organization tool
- **tailwindcss** - Tailwind CSS integration
- **quickfix** - Enhanced quickfix management
- **vimslash** - Search highlighting improvements
- **fluidfiles** - Enhanced file operations
- **fluidmotion** - Advanced motion commands

## Configuration Examples

### Real-World Configuration
Here's a comprehensive example based on an actual Fluid configuration:

```lua
vim.cmd.packadd 'fluid'
require 'fluid'
-- UI
  :theme()
    :option('rose-pine')
  :devicons()
  :dressing()
  :statusline()
  :winbar()

-- Nvim
  :quickfix()

-- Editor
  :comment()
  :autopairs()
  :cmp()
  :fluidfiles()
  :lsp()
    :options('icons', 'server_management')
  :surround()
  :treesitter()
    :option('highlight', 'indent')
  :qbuf()
  :undotree()
  :vimslash()
  :ai()

-- Motion
  :aerial()
  :fluidmotion()
    :options('win', 'log')
  :leap()

-- Languages
  :csharp()
    :options('treesitter', 'lsp', 'fold')
  :css()
    :options('treesitter', 'lsp')
  :emmet()
  :fsharp()
    :options('lsp')
  :html()
  :lualang()
    :options('lsp')
  :markdown()
  :typescript()
    :options('treesitter', 'lsp')
  :tailwindcss()

-- Tools
  :copilot()
  :dispatch()
  
  -- Git
  :gitsigns()
  :fugitive()
  
  -- System
  :syspackman()
    :options('scoop')
  
  -- File Management
  :oil()
  
  -- Search
  :fzf()
  :grepper()
  
  -- Database
  :dadbod()
    :options('ui', 'completion')
  
  -- Terminal
  :fterm()

  :setup()
```

### Basic Setup
```lua
vim.cmd.packadd 'fluid'
require 'fluid'
  :lsp()
  :treesitter()
  :cmp()
  :telescope()
  :setup()
```

### Language Development Setup
```lua
vim.cmd.packadd 'fluid'
require 'fluid'
  :lsp():options('icons', 'server_management')
  :treesitter():option('highlight', 'indent')
  :cmp()
  
  -- Language support
  :typescript():options('treesitter', 'lsp')
  :csharp():options('treesitter', 'lsp', 'fold')
  :css():options('treesitter', 'lsp')
  :html()
  
  -- Tools
  :copilot()
  :gitsigns()
  :oil()
  :setup()
```

## Module Documentation

Each module has detailed documentation available in Neovim:
```vim
:help fluid-module-telescope
:help fluid-module-lsp  
:help fluid-module-treesitter
```

For a complete list of modules and their capabilities, see `:help fluid-nvim-modules`.

## License

MIT License - see [LICENSE](LICENSE) for details.
