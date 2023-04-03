local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('netrw').from('prichrd/netrw.nvim')
    .and_also('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.netrw.setup()

  vim.g.netrw_banner = 0

  deps.nvim:map('n', '<leader>e', ':Explore<CR>')

end

return M
