local M = {}

function M:init()
  self
    -- Plugins
    :use('kyazdani42/nvim-tree.lua')
    :depends('nvim-tree', 'nvimtree')
end

function M:setup(deps)
  deps.nvimtree.setup()
end

return M
