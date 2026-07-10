local M = {}

function M:init()
  self
    :use('cbochs/portal.nvim').providing('portal')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim:map('n', '<leader>o', '<cmd>Portal jumplist backward<cr>')
  deps.nvim:map('n', '<leader>i', '<cmd>Portal jumplist forward<cr>')
end

return M
