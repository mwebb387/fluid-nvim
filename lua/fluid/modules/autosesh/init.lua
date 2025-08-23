local M = {}

local function getSessionFile()
  local root = vim.fs.root(0, '.git')

  if not root then
    return nil
  end

  local sessionPath = root .. '/.vim/'
  local sessionFile = root .. '/.vim/session.vim'
  if vim.fn.isdirectory(sessionPath) == 0 then
    vim.fn.mkdir(sessionPath, 'p')
  end
  return sessionFile
end

local function writeSession()
  local sessionFile = getSessionFile()
  if not sessionFile then
    return
  end
  vim.cmd('mks! ' .. sessionFile)
end

local readSession = function()
  local sessionFile = getSessionFile()
  if not sessionFile or vim.fn.filereadable(sessionFile) == 0 then
    return
  end
  vim.cmd('source ' .. sessionFile)
end

function M:init()
  self:depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim:map('n', '<leader>aa', ':argadd | argdedupe<CR>', {silent = true})
    :map('n', '<leader>ad', ':argd<CR>', {silent = true})
    :map('n', '<leader>aD', ':%argd<CR>', {silent = true})
    :map('n', '<leader>al', ':arglocal<CR>', {silent = true})
    :map('n', '<leader>ag', ':argglobal<CR>', {silent = true})
    :map('n', '<leader>1', ':argument 1<CR>')
    :map('n', '<leader>2', ':argument 2<CR>')
    :map('n', '<leader>3', ':argument 3<CR>')
    :map('n', '<leader>4', ':argument 4<CR>')
    :map('n', '<leader>5', ':argument 5<CR>')
    :map('n', '<leader>6', ':argument 6<CR>')
    :map('n', '<leader>7', ':argument 7<CR>')
    :map('n', '<leader>8', ':argument 8<CR>')
    :map('n', '<leader>9', ':argument 9<CR>')
    :map('n', '<leader>0', ':argument 10<CR>')
    :map('n', '<leader>an', ':argn<CR>')
    :autocmd({'VimEnter'}, {
      callback = readSession
    })
    :autocmd({'VimLeave'}, {
      callback = writeSession
    })
    :autocmd({'TabNew'}, {
      callback = function()
        vim.cmd('arglocal')
        -- vim.cmd('argdelete *')
      end
    })
    -- :autocmd({'BufNew'}, {
    --   callback = function()
    --     vim.cmd('argadd')
    --     vim.cmd('argdedupe')
    --   end
    -- })
    -- :autocmd({'BufDelete'}, {
    --   callback = function()
    --     vim.cmd('.argdelete')
    --   end
    -- })
end

return M
