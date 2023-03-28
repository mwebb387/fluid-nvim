local M = {}

function M:init()
  self
    :use('numToStr/Comment.nvim')
    :depends('Comment')
end

function M:setup(deps)
  deps.Comment.setup()
end

return M
