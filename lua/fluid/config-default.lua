local M = {}

function M.setup(nvim)
  -- General options
  nvim(
    'splitbelow', 'splitright',
    'hidden',
    'number',
    'noshowmode',
    'noshowcmd')
      :set('cmdheight', 1)
      :set('signcolumn', 'yes')
      :set('updatetime', 300)

  -- Mouse
  nvim:set('mouse', 'a')

    -- Searching
  nvim('ignorecase')
      :append('path', '**')
      :set('wildignore', 'obj/**,bin/**,node_modules/**,CMS/**')
      :set('shellpipe', '>')

  -- Tab settings
  nvim('expandtab', 'autoindent')
      :set('tabstop', 2)
      :set('shiftwidth', 2)

  -- Complete and Omnifunc
  nvim
      :set('completeopt', 'menuone,noinsert,noselect')
      :set('omnifunc', 'syntaxcomplete#Complete')

  -- Nvim Help
  nvim:autocmd('FileType', {
    pattern = 'help',
    command = 'set conceallevel=0'
  })
end

return M
