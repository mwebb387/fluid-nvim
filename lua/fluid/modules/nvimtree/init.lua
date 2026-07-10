local M = {}

function M:init()
  self
    -- Plugins
    :use('kyazdani42/nvim-tree.lua')
      .providing('nvim-tree')
      .as('nvimtree')
end

function M:setup(deps)
  deps.nvimtree.setup()
end

return M
