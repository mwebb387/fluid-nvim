local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('qbuf').from('ayoubelmhamdi/qbuf.nvim')
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim:map('n', '<leader>b', function()
    deps.qbuf.quickfix();
    vim.cmd.copen()
  end)
end

return M
