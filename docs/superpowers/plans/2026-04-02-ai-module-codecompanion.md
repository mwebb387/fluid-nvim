# AI Module CodeCompanion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure the fluid.nvim `ai` module with multi-provider codecompanion.nvim support — HTTP adapters (Anthropic, OpenAI Responses) always on, ACP adapters (Claude Code, OpenCode) opt-in via fluid options.

**Architecture:** Single module rewrite of `lua/fluid/modules/ai/init.lua`. The `init()` phase declares dependencies conditionally based on options. The `setup()` phase builds a config table, passes it to codecompanion, then validates the environment and warns about missing keys/binaries.

**Tech Stack:** Lua, Neovim API (`vim.notify`, `vim.fn.executable`, `os.getenv`), codecompanion.nvim, fluid.nvim module system

---

## File Structure

- Modify: `lua/fluid/modules/ai/init.lua` — the entire module, rewritten from scratch

No new files. No test files (project has no test infrastructure).

---

### Task 1: Rewrite the init phase

**Files:**
- Modify: `lua/fluid/modules/ai/init.lua`

- [ ] **Step 1: Replace the init function with dependency declarations**

Replace the entire contents of `lua/fluid/modules/ai/init.lua` with:

```lua
local M = {}

function M:init(fluid)
  self:depends_on('codecompanion').from('olimorris/codecompanion.nvim')

  if self:has('opencode') then
    self:use('sudo-tee/opencode.nvim')
  end
end

function M:setup(deps)
  deps.codecompanion.setup()
end

return M
```

This is an intermediate state — `setup()` is still minimal. We build it up in the next tasks.

- [ ] **Step 2: Commit**

```bash
git add lua/fluid/modules/ai/init.lua
git commit -m "refactor(ai): add conditional opencode dependency in init phase"
```

---

### Task 2: Build the adapter config in setup

**Files:**
- Modify: `lua/fluid/modules/ai/init.lua`

- [ ] **Step 1: Replace the setup function with adapter configuration**

Replace the `setup` function in `lua/fluid/modules/ai/init.lua`:

```lua
function M:setup(deps)
  local config = {
    adapters = {
      http = {
        anthropic = "anthropic",
        openai = "openai_responses",
      },
      acp = {},
    },
    interactions = {
      chat = {
        adapter = "openai",
      },
    },
  }

  if self:has('claude_code') then
    config.adapters.acp.claude_code = "claude_code"
  end

  if self:has('opencode') then
    config.adapters.acp.opencode = "opencode"
  end

  deps.codecompanion.setup(config)
end
```

- [ ] **Step 2: Commit**

```bash
git add lua/fluid/modules/ai/init.lua
git commit -m "feat(ai): configure multi-provider adapters for codecompanion"
```

---

### Task 3: Add startup environment warnings

**Files:**
- Modify: `lua/fluid/modules/ai/init.lua`

- [ ] **Step 1: Add warning logic after the `deps.codecompanion.setup(config)` call**

Insert the following at the end of the `setup` function, after `deps.codecompanion.setup(config)`:

```lua
  -- Startup warnings for missing environment
  local function warn(msg)
    vim.notify('[fluid.ai] ' .. msg, vim.log.levels.WARN)
  end

  if not os.getenv('OPENAI_API_KEY') then
    warn('OPENAI_API_KEY not set — OpenAI adapter will not work')
  end

  if not os.getenv('ANTHROPIC_API_KEY') then
    warn('ANTHROPIC_API_KEY not set — Anthropic adapter will not work')
  end

  if self:has('claude_code') then
    if vim.fn.executable('claude-agent-acp') == 0 then
      warn('claude-agent-acp not found on $PATH — Claude Code ACP will not work')
    end
  end

  if self:has('opencode') then
    if vim.fn.executable('opencode') == 0 then
      warn('opencode not found on $PATH — OpenCode ACP will not work')
    end
  end
```

- [ ] **Step 2: Commit**

```bash
git add lua/fluid/modules/ai/init.lua
git commit -m "feat(ai): add startup warnings for missing API keys and binaries"
```

---

### Task 4: Manual verification

- [ ] **Step 1: Review the final file**

The complete `lua/fluid/modules/ai/init.lua` should look like this:

```lua
local M = {}

function M:init(fluid)
  self:depends_on('codecompanion').from('olimorris/codecompanion.nvim')

  if self:has('opencode') then
    self:use('sudo-tee/opencode.nvim')
  end
end

function M:setup(deps)
  local config = {
    adapters = {
      http = {
        anthropic = "anthropic",
        openai = "openai_responses",
      },
      acp = {},
    },
    interactions = {
      chat = {
        adapter = "openai",
      },
    },
  }

  if self:has('claude_code') then
    config.adapters.acp.claude_code = "claude_code"
  end

  if self:has('opencode') then
    config.adapters.acp.opencode = "opencode"
  end

  deps.codecompanion.setup(config)

  -- Startup warnings for missing environment
  local function warn(msg)
    vim.notify('[fluid.ai] ' .. msg, vim.log.levels.WARN)
  end

  if not os.getenv('OPENAI_API_KEY') then
    warn('OPENAI_API_KEY not set — OpenAI adapter will not work')
  end

  if not os.getenv('ANTHROPIC_API_KEY') then
    warn('ANTHROPIC_API_KEY not set — Anthropic adapter will not work')
  end

  if self:has('claude_code') then
    if vim.fn.executable('claude-agent-acp') == 0 then
      warn('claude-agent-acp not found on $PATH — Claude Code ACP will not work')
    end
  end

  if self:has('opencode') then
    if vim.fn.executable('opencode') == 0 then
      warn('opencode not found on $PATH — OpenCode ACP will not work')
    end
  end
end

return M
```

- [ ] **Step 2: Verify in Neovim**

Open Neovim and confirm:
1. No errors on startup with `f:ai()` (base config)
2. `:CodeCompanion` command is available
3. `:messages` shows expected warnings for missing API keys (if not set)

- [ ] **Step 3: Verify with options**

Update your fluid config to use `f:ai() + 'claude_code' + 'opencode'` and restart Neovim. Confirm:
1. No errors on startup
2. Warnings appear for missing binaries (if not installed)
