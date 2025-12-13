local M = {}

function M:init(fluid)
  self
    -- Plugins
    --:depends_on('fluid.nvim').as('nvim')
    :depends_on('opencode').from('sudo-tee/opencode.nvim')
    -- :depends_on('codecompanion').from('olimorris/codecompanion.nvim')
    -- fluid:treesitter():option('lang:markdown', 'lang:markdown_inline')
end

function M:setup(deps)
  deps.opencode.setup()
  -- deps.codecompanion.setup()
end

return M
