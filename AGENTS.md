AGENTS guidance for this repository

- Build / Lint / Test commands
  - Format: `stylua .` (recommended; use `stylua.toml` if present)
  - Lint: `luacheck .` or `selene` (if configured)
  - Run tests with Busted: `busted` (install via luarocks)
  - Run a single busted test file: `busted spec/path/to/file_spec.lua`
  - Run a single test by pattern: `busted -p "pattern"`
  - Run Plenary (Neovim) tests headless: `nvim --headless -c 'lua require("plenary.test_harness").test_directory("./spec")' -c 'qa!'`
  - Run one Plenary test file: `nvim --headless -c 'lua require("plenary.test_harness").test_file("./spec/that_spec.lua")' -c 'qa!'`

- Code style & conventions
  - Language: Lua for Neovim plugins; prefer 2-space indent and small, focused modules
  - Naming: use `snake_case` for functions/locals, `PascalCase` or `M` for module tables (existing code uses `M`)
  - Modules: return a table at end; expose only needed API
  - Locals: always use `local` for variables and functions unless intentionally global
  - Imports: use `local foo = require('foo')`; avoid long inline requires in hot paths
  - Types & checks: validate inputs with `type()` and explicit checks; fail fast with `error()` or return `nil, err`
  - Error handling: surface user-facing problems with `vim.notify()`; prefer returning `(nil, err)` for library functions
  - Formatting: run `stylua` before committing; keep lines < 120 chars

- Tooling / rules found
  - No `.cursor/rules/` or `.cursorrules` found in repo root.
  - No `.github/copilot-instructions.md` found.

Follow these rules when making edits and writing tests; ask if you want me to run linters or create test scaffolding.