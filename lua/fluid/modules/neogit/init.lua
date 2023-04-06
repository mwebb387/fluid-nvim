local M = {}

function M:init()
  self:depends_on('neogit').from('TimUntersberger/neogit')
end

function M:setup(deps)
  deps.neogit.setup()
end

return M
