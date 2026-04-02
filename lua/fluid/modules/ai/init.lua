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
end

return M
