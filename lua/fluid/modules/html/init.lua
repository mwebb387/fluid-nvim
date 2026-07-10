local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:html')
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
      name = 'html',
      package = 'superhtml',
      manager = 'scoop'
    })

    vim.lsp.config('superhtml', lsp)
    vim.lsp.enable('superhtml')
  end
end

return M
