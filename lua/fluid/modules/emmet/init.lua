local M = {}

function M:init()
  self:use('mattn/emmet-vim')
end

function M:setup()
  vim.g.user_emmet_leader_key = '<A-e>'
end

return M
