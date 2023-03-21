local M = {}

function M:init()
  self
    -- Plugins
    :use(':TimUntersberger/neogit')
    :depends('neogit')
end

function M:setup(deps)
  deps.neogit.setup()
end

return M
