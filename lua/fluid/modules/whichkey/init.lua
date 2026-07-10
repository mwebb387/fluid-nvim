local M = {}

function M:init()
  self
    :use('folke/which-key.nvim')
      .providing('which-key')
      .as('wk')
end

function M:setup(deps)
  deps.wk.setup()
end

return M
