local M = {}

function M:init(fluid)
  self:depends('lspconfig')
end

function M:setup(deps)
  if deps.lspconfig then
    deps.lspconfig.tailwindcss.setup{}
  end
end

return M
