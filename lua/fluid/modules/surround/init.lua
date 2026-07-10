local M = {}

function M:init()
  self:use('kylechui/nvim-surround')
    .providing('nvim-surround')
    .as('surround')
end

function M:setup(deps)
  deps.surround.setup()
end

return M
