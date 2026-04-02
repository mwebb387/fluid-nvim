# AI Module — CodeCompanion Setup Design

## Overview

Configure the fluid.nvim `ai` module to set up [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) with multi-provider support: two always-on HTTP adapters (Anthropic, OpenAI Responses API) and two opt-in ACP adapters (Claude Code, OpenCode) for agentic workflows.

## Module API

```lua
-- Base: HTTP adapters only (Anthropic + OpenAI Responses)
f:ai()

-- Opt-in ACP adapters
f:ai() + 'claude_code'
f:ai() + 'opencode'

-- Both ACP adapters
f:ai() + 'claude_code' + 'opencode'
```

HTTP adapters are always available because they only require API keys. ACP adapters are opt-in because they require external binaries.

## Dependencies

### Always installed

- `olimorris/codecompanion.nvim` — core plugin, declared via `depends_on().from()`

### Conditional

- `sudo-tee/opencode.nvim` — installed via `self:use()` only when `opencode` option is set
- Claude Code ACP does not require an extra Neovim plugin; codecompanion ships the adapter natively

## Configuration

### Adapters

| Adapter              | Type | Condition          | API / Binary                        |
|----------------------|------|--------------------|-------------------------------------|
| `anthropic`          | HTTP | Always             | `ANTHROPIC_API_KEY` env var         |
| `openai`             | HTTP | Always             | `OPENAI_API_KEY` env var (uses `openai_responses` adapter under the hood) |
| `claude_code`        | ACP  | `+ 'claude_code'`  | `claude-agent-acp` binary on `$PATH` |
| `opencode`           | ACP  | `+ 'opencode'`     | `opencode` binary on `$PATH`        |

### Defaults

- **Default chat adapter:** `openai` (OpenAI Responses API)
- **Models:** Provider defaults — no model pinning
- **Keybindings:** Codecompanion defaults — no custom mappings

## Startup Warnings

The module validates the environment after calling `codecompanion.setup()` and emits `vim.notify` warnings (level WARN) for missing requirements, scoped to what is enabled:

| Condition                                          | Warning message                                              |
|----------------------------------------------------|--------------------------------------------------------------|
| `OPENAI_API_KEY` not set                           | `OPENAI_API_KEY not set — OpenAI adapter will not work`      |
| `ANTHROPIC_API_KEY` not set                        | `ANTHROPIC_API_KEY not set — Anthropic adapter will not work` |
| `claude_code` option + `claude-agent-acp` missing  | `claude-agent-acp not found on $PATH — Claude Code ACP will not work` |
| `opencode` option + `opencode` binary missing      | `opencode not found on $PATH — OpenCode ACP will not work`  |

Warnings are non-blocking. The module loads fully regardless; warnings are informational.

## Implementation Sketch

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

  -- Startup warnings
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

## Out of Scope

- Custom keybindings (use codecompanion defaults, configure later)
- Model pinning (use provider defaults)
- API key management (user's responsibility to set env vars)
- codecompanion display/UI customization
