local M = {}

function M:init()
  self:use('samodostal/image.nvim').providing('image')
end

function M:setup(deps)
  deps.image.setup()
end

return M
