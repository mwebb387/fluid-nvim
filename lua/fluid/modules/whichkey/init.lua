local M = {}

function M:init()
  self
    :depends_on('which-key')
      .as('wk')
      .from('folke/which-key.nvim')
end

function M:setup(deps)
  deps.wk.setup()
end

return M
