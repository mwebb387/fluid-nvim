local M = {}

function M:init()
  self
    -- Plugins
    :use('tris203/precognition.nvim').providing('precognition')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.precognition.setup()
  deps.nvim:map('n', '<leader>p', ':Precognition toggle<CR>')
  deps.nvim:map('n', '<leader>P', ':Precognition peek<CR>')
end

return M
