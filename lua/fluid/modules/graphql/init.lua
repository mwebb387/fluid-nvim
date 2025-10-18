local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:graphql')
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
    }

    deps.lsp:addServerConfig({
      name = "graphql",
      package = 'graphql-language-service-cli',
      manager = 'node'
      -- version = "graphql-language-service-cli --version", -- TODO: Get version cmd
      -- install = "npm install -g graphql-language-service-cli",
      -- update = "npm upgrade -g graphql-language-service-cli",
      -- remove = "npm uninstall -g graphql-language-service-cli",
    })
    deps.lspconfig.graphql.setup(lsp)
  end
end

return M
