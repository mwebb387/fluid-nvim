local M = {}

function M:init()
  self
    -- Plugins
    :use('lewis6991/gitsigns.nvim')
    :depends('gitsigns')
end

function M:setup(deps)
  deps.gitsigns.setup()
end

return M
