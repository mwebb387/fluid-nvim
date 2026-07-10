local M = {}

function M:init()
  self:use('lewis6991/gitsigns.nvim').providing('gitsigns')
end

function M:setup(deps)
  deps.gitsigns.setup()
end

return M
