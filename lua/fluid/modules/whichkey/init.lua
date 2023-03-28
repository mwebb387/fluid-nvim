local M = {}

function M:init()
  self
    :use('folke/which-key.nvim')
    :depends('which-key', 'wk')
end

function M:setup(deps)
  deps.wk.setup()
end

return M
