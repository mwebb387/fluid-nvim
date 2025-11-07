local M = {}

-- function M:init(fluid)
-- end

function M:setup(deps)
  if deps.lspconfig then
    vim.lsp.enable('tailwindcss')
  end
end

return M
