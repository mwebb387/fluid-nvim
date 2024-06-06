local M = {}

function M:init()
  self
    -- Plugins
    :use('philt/vim-fsharp')

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
      name = "FsAutoComplete",
      version = "fsautocomplete --version", -- TODO: Get version cmd
      install = "dotnet tool install --global fsautocomplete",
      update = "dotnet tool update --global fsautocomplete",
      remove = "dotnet tool uninstall --global fsautocomplete",
    })

    deps.lspconfig.fsautocomplete.setup(lsp)
  end
end

return M
