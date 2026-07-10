local M = {}

function M:init()
  self:use('phaazon/hop.nvim').providing('hop')
end

function M:setup(deps)
  deps.hop.setup()
end

return M
