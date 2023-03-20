local M = {}

function M:init()
  self
    -- Plugins
    :use('samodostal/image.nvim')
    :depends('image')
end

function M:setup(deps)
  deps.image.setup()
end

return M
