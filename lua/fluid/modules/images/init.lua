local M = {}

function M:init()
  self:depends_on('image').from('samodostal/image.nvim')
end

function M:setup(deps)
  deps.image.setup()
end

return M
