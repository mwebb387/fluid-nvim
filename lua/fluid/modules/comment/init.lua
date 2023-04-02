local M = {}

function M:init()
  self:depends_on('Comment').from('numToStr/Comment.nvim')
end

function M:setup(deps)
  deps.Comment.setup()
end

return M
