local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:vue')
  else
    self:use('posva/vim-vue')
  end

  if self:has('lsp') then -- also check module registration
    self
      :use('lspconfig')
      :use('fluid.modules.lsp').as('lsp')
      :use('fluid.modules.lsp.util').as('lsp_util')
      :use('cmp_nvim_lsp').as('cmp') -- opt-in completion?
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
      on_attach = deps.lsp_util.on_attach,
    }

    deps.lsp:addServerConfig({
      name = "volar",
      package = '@vue/language-server',
      manager = 'node'
      -- version = "volar --version", -- TODO: Get version cmd
      -- install = "npm install -g @vue/language-server",
      -- update = "npm upgrade -g @vue/language-server",
      -- remove = "npm uninstall -g @vue/language-server",
    })

    deps.lspconfig.volar.setup(lsp)
  end
end

return M
