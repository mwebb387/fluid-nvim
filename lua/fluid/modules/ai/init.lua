local M = {}

function M:init(fluid)
  self:depends_on('codecompanion').from('olimorris/codecompanion.nvim')

  if self:has('opencode') then
    self:use('sudo-tee/opencode.nvim')
  end
end

function M:setup(deps)
  local config = {
    interactions = {
      chat = {
        adapter = "openai_responses",
      },
    },
  }

  if self:has('claude_code') or self:has('opencode') then
    config.adapters = { acp = {} }

    if self:has('claude_code') then
      config.adapters.acp.claude_code = "claude_code"
    end

    if self:has('opencode') then
      config.adapters.acp.opencode = "opencode"
    end
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
