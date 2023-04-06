local M = {}

function M:init()
  if self:has('lsp') then
    self
      :depends('lspconfig')
      :depends('lsp')
      :depends('cmp_nvim_lsp', 'cmp') -- opt-in completion?
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local root_pattern = {'deno.json', 'deno.jsonp'}
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
      on_attach = deps.lsp.on_attach,
      root_dir = deps.lspconfig.util.root_pattern(root_pattern),
      autostart = false,
    }

    deps.lspconfig.denols.setup(lsp)
  end
end

return M