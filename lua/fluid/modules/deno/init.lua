local M = {}

function M:init()
  self
    :depends('lspconfig')
    :depends('lsp')
    :depends('cmp_nvim_lsp', 'cmp') -- opt-in completion?
end

function M:setup(deps)
  local root_pattern = {'deno.json', 'deno.jsonp'}
  local lsp = {
    capabilities = deps.cmp.default_capabilities(),
    on_attach = deps.lsp.on_attach,
    root_dir = deps.lspconfig.util.root_pattern(root_pattern),
    autostart = false,
  }

  deps.lspconfig.denols.setup(lsp)
end

return M
