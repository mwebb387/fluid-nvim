local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:typescript')
  end

  if self:has('lsp') then -- also check module registration
    self
      :depends_on('lspconfig')
      :depends_on('fluid.modules.lsp').as('lsp')
      :depends_on('fluid.modules.lsp.util').as('lsp_util')
  end
end

function M:setup(deps)
  if self:has('lsp') then
    deps.lsp:addServerConfig({
      name = "vtsls",
      package = '@vtsls/language-server',
      manager = 'node'
    })

    vim.lsp.enable('vtsls')
  end
end

return M
