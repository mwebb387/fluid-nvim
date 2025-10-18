local M = {}

function M:init()
  self:use('mhinz/vim-grepper')
  self:depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  -- Keymaps
  deps.nvim
    :map('n', '<leader>g', '<cmd>Grepper -tool rg<CR>')
    :map('n', '<leader>gg', '<cmd>Grepper -tool rg<CR>')
    :map('n', '<leader>G', '<cmd>Grepper -tool rg -cword -noprompt<CR>')
    :map('n', '<leader>gb', '<cmd>Grepper -tool rg -buffer<CR>')
    :map('n', '<leader>gB', '<cmd>Grepper -tool rg -buffers<CR>')
end

return M
