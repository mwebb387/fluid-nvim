local M = {}

function M:init(fluid)
  self
    -- Plugins
    :use('jlcrochet/vim-razor')

  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:c_sharp')
  end

  if self:has('lsp') then -- also check module registration
    self
      :use('Hoffs/omnisharp-extended-lsp.nvim')
      :depends_on('lspconfig')
      :depends_on('omnisharp_extended')
      :depends_on('fluid.modules.lsp.util').as('lsp')
      :depends_on('cmp_nvim_lsp').as('cmp')
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local handlers = {
      ['textDocument/publishDiagnostics'] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        { virtual_text = false }),
      ['textDocument/definition'] = deps.omnisharp_extended.handler
    }

    local lsp = {
      cmd = {'omnisharp.exe'},
      capabilities = deps.cmp.default_capabilities(),
      enable_roslyn_analyzers = true,
      on_attach = deps.lsp.on_attach,
      handlers = handlers
    }

    deps.lspconfig.omnisharp.setup(lsp)
  end
end

return M
