local M = {}

function M:init()
  self
    -- Plugins
    :use('philt/vim-fsharp')

  if self:has('lsp') then -- also check module registration
    self
      :depends('lspconfig')
      :depends('lsp')
      :depends('cmp_nvim_lsp', 'cmp') -- opt-in completion?
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
      on_attach = deps.lsp.on_attach,
    }

    deps.lspconfig.fsautocomplete.setup(lsp)
  end
end

return M
