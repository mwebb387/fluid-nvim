local M = {}

function M:init()
  self:use('TimUntersberger/neogit').providing('neogit')
end

function M:setup(deps)
  deps.neogit.setup()
end

return M
