local M = {}

function M:init()
  self:depends_on('gitsigns').from('lewis6991/gitsigns.nvim')
end

function M:setup(deps)
  deps.gitsigns.setup()
end

return M
