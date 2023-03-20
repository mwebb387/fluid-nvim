local M = {}

function M:init()
  self:use('neovim/nvim-lspconfig')
end

function M:setup()
  if self:has('icons') then
    vim.fn.sign_define('DiagnosticSignError', {text = '', texthl = 'DiagnosticSignError'})
    vim.fn.sign_define('DiagnosticSignHint', {text = '', texthl = 'DiagnosticSignHint'})
    vim.fn.sign_define('DiagnosticSignInfo', {text = '', texthl = 'DiagnosticSignInfo'})
    vim.fn.sign_define('DiagnosticSignWarn', {text = '', texthl = 'DiagnosticSignWarn'})
  end
end

return M
