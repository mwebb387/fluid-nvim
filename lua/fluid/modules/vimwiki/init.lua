local M = {}

function M:init()
  self
    :use('vimwiki/vimwiki')
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim
    :map('n', 'glx', '<Plug>VimwikiToggleListItem')
end

return M
