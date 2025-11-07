local M = {}

function M:init()
  if self:has('lsp') then
    self
      :depends_on('fluid.modules.lsp.util').as('lsp_util')
      :depends_on('cmp_nvim_lsp').as('cmp') -- opt-in completion?
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local root_pattern = {'deno.json', 'deno.jsonp'}
    local lsp = {
      capabilities = deps.cmp.default_capabilities(),
      root_markers = root_pattern,
      autostart = false,
    }

    vim.lsp.config('denols', lsp)
    vim.lsp.enable('denols')
  end
end

return M
