local M = {}

function M:init()
  self
    :use('phaazon/hop.nvim')
    :depends('hop')
end

function M:setup(deps)
  deps.hop.setup()
end

return M
