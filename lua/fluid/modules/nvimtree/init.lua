local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('nvim-tree')
      .as('nvimtree')
      .from('kyazdani42/nvim-tree.lua')
end

function M:setup(deps)
  deps.nvimtree.setup()
end

return M
