local M = {}

function M:init()
  self
    -- Plugins
    :use('ayoubelmhamdi/qbuf.nvim').providing('qbuf')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim:map('n', '<leader>b', function()
    deps.qbuf.quickfix();
    vim.cmd.copen()
  end)
end

return M
