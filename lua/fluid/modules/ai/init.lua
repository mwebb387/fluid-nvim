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
