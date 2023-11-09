local M = {}

function M:init()
  self:depends_on('nvim-devdocs')
    .from('luckasRanarison/nvim-devdocs')
    .as('devdocs')
end

function M:setup(deps)
  deps.devdocs.setup()
end

return M
