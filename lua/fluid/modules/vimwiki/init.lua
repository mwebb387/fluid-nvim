local M = {}

function M:init()
  self
    :use('vimwiki/vimwiki')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim
    :map('n', 'glx', '<Plug>VimwikiToggleListItem')
end

return M
