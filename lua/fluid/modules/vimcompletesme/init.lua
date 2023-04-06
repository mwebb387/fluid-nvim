local M = {}

function M:init()
  self
    :use('ackyshake/VimCompletesMe')
    :depends_on('fluid.nvim').as('nvim')

end

function M:setup(deps)
  deps.nvim:map(
    'i',
    '<CR>',
    'pumvisible() ? "\\<C-y>" : "\\<C-g>u\\<CR>"',
    {expr = true}
  )
end

return M
