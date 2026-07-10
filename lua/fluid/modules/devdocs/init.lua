local M = {}

function M:init()
  self:use('luckasRanarison/nvim-devdocs')
    .providing('nvim-devdocs')
    .as('devdocs')
end

function M:setup(deps)
  deps.devdocs.setup()
end

return M
