local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:svelte')
  end

  if self:has('lsp') then -- also check module registration
    self
      :depends_on('lspconfig')
      :depends_on('fluid.modules.lsp.util').as('lsp')
      :depends_on('cmp_nvim_lsp').as('cmp')
  end

end

function M:setup(deps)
  if self:has('lsp') then
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
      on_attach = deps.lsp.on_attach,
    }

    deps.lspconfig.svelte.setup(lsp)
  end
end

return M
