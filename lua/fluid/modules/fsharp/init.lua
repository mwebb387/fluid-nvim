local M = {}

function M:init()
  self
    -- Plugins
    :use('philt/vim-fsharp')

  if self:has('lsp') then -- also check module registration
    self
      :depends_on('fluid.modules.lsp').as('lsp')
      :depends_on('fluid.modules.lsp.util').as('lsp_util')
      :depends_on('cmp_nvim_lsp').as('cmp') -- opt-in completion?
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
    }

    deps.lsp:addServerConfig({
      name = "FsAutoComplete",
      package = 'fsautocomplete',
      manager = 'dotnet'
      -- install = "dotnet tool install --global fsautocomplete",
      -- update = "dotnet tool update --global fsautocomplete",
      -- remove = "dotnet tool uninstall --global fsautocomplete",
    })

    vim.lsp.config('fsautocomplete', lsp)
    vim.lsp.enable('fsautocomplete')
  end
end

return M
