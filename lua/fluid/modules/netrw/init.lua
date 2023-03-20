local M = {}

function M:init()
  self
    -- Plugins
    :use('prichrd/netrw.nvim')
    :depends('netrw')
end

function M:setup(deps)
  deps.netrw.setup()

  vim.g.netrw_banner = 0
end

return M
