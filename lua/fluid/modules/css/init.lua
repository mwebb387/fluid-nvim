local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:css')
  end

  if self:has('lsp') then -- also check module registration
    self
      :use('fluid.modules.lsp').as('lsp')
      :use('fluid.modules.lsp.util').as('lsp_util')
      :use('cmp_nvim_lsp').as('cmp')
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
    }

    deps.lsp:addServerConfig({
      name = 'cssls',
      package = 'vscode-langservers-extracted',
      manager = 'node'
    })

    vim.lsp.config('cssls', lsp)
    vim.lsp.enable('cssls')
  end
end

return M
