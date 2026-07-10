local M = {}

function M:init()
  self:use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim
    :map('n', '<C-_>', 'gcl', { remap = true })
    :map('v', '<C-_>', 'gc', { remap = true })
end

return M
