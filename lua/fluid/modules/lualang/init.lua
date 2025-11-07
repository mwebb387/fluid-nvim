local M = {}

function M:init()
  if self:has('lsp') then -- also check module registration
    self
      :depends_on('fluid.modules.lsp.util').as('lsp_util')
      :depends_on('cmp_nvim_lsp').as('cmp')
  end
end

function M:setup(deps)
  if self:has('lsp') then
    local runtime = vim.api.nvim_get_runtime_file('', true)
    local settings = {
      Lua = {
        version = 'LuaJIT',
        diagnostics = {
          globals = { 'vim' }
        },
        workspace = {
          library = runtime
        },
        telemetry = {
          enable = false
        }
      }
    }

    local lsp = {
      capabilities = deps.cmp.default_capabilities(), -- TODO: Opt-in for cmp?
      settings = settings
    }

    vim.lsp.config('lua_ls', lsp)
    vim.lsp.enable('lua_ls')
  end
end

return M
