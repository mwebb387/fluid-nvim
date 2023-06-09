local M = {}

function M:init()
  self:depends_on('nvim-surround')
    .as('surround')
    .from('kylechui/nvim-surround')
end

function M:setup(deps)
  deps.surround.setup()
end

return M
