local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:vue')
  else
    self:use('posva/vim-vue')
  end

  if self:has('lsp') then -- also check module registration
    self
      :depends_on('lspconfig')
      :depends_on('fluid.modules.lsp').as('lsp')
      :depends_on('fluid.modules.lsp.util').as('lsp_util')
      :depends_on('cmp_nvim_lsp').as('cmp') -- opt-in completion?
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
      version = "volar --version", -- TODO: Get version cmd
      install = "npm install -g @vue/language-server",
      update = "npm upgrade -g @vue/language-server",
      remove = "npm uninstall -g @vue/language-server",
    })

    deps.lspconfig.volar.setup(lsp)
  end
end

return M
