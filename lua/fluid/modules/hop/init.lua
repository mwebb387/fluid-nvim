local M = {}

function M:init()
  self:depends_on('hop').from('phaazon/hop.nvim')
end

function M:setup(deps)
  deps.hop.setup()
end

return M
