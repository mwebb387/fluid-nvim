local M = {}

function M:init()
  self
    -- Plugins
    :use('stevearc/oil.nvim')
    :depends('oil')
end

function M:setup(deps)
  deps.oil.setup()
end

return M
