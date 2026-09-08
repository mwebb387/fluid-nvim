local M = {}

function M:init()
  self:use('nvim-flutter/flutter-tools.nvim')
    .opt()
    .providing('flutter-tools')
    .as('flutter')

  self:use('fluid.nvim').as('nvim')
  self:use('fluid.modules.lsp.util').as('lsp_util')
end

function M:setup(deps)
  deps.nvim:autocmd('FileType', {
    pattern = 'dart',
    callback = function()
      vim.cmd.compiler('dart')
      deps.lazy.flutter.setup {
        lsp = {
          on_attach = deps.lsp_util.on_attach,
        }
      }
    end
  })
end

return M
