local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:svelte')
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
      name = "svelte",
      package = 'svelte-language-server',
      manager = 'node'
      -- version = "svelte --version", -- TODO: Get version cmd
      -- install = "npm install -g svelte-language-server",
      -- update = "npm upgrade -g svelte-language-server",
      -- remove = "npm uninstall -g svelte-language-server",
    })

    vim.lsp.config('svelte', lsp)
    vim.lsp.enable('svelte')
  end
end

return M
