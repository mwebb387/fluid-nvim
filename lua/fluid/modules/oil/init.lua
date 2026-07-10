local M = {}

function M:init()
  self
    -- Plugins
    :use('stevearc/oil.nvim').providing('oil')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.oil.setup()
  deps.nvim:map('n', '<leader>e', ':Oil<CR>')
  deps.nvim:map('n', '-', ':Oil<CR>')
end

return M
