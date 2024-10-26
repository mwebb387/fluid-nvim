local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('oil').from('stevearc/oil.nvim')
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.oil.setup()
  deps.nvim:map('n', '<leader>e', ':Oil<CR>')
  deps.nvim:map('n', '-', ':Oil<CR>')
end

return M
