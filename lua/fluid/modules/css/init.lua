local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:css')
  end

  if self:has('lsp') then -- also check module registration
    self
      :depends_on('lspconfig')
      :depends_on('fluid.modules.lsp').as('lsp')
      :depends_on('fluid.modules.lsp.util').as('lsp_util')
      :depends_on('cmp_nvim_lsp').as('cmp')
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
      on_attach = deps.lsp_util.on_attach,
    }

    deps.lsp:addServerConfig({
      name = "cssls",
      package = 'vscode-langservers-extracted',
      manager = 'node'
    })

    deps.lspconfig.cssls.setup(lsp)
  end
end

return M
