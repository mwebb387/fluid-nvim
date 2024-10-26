local M = {}

function M:init()
  self
    :depends_on('portal').from('cbochs/portal.nvim')
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim:map('n', '<leader>o', '<cmd>Portal jumplist backward<cr>')
  deps.nvim:map('n', '<leader>i', '<cmd>Portal jumplist forward<cr>')
end

return M
