local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('oil').from('stevearc/oil.nvim')
end

function M:setup(deps)
  deps.oil.setup()
end

return M
