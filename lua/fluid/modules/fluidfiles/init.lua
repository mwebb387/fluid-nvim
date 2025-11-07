local M = {}

-- Functions to setup commands for searching files using `rg` and `fd`
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

local function readSession()
  local sessionFile = getSessionFile()
  if not sessionFile or vim.fn.filereadable(sessionFile) == 0 then
    return
  end
  vim.cmd('source ' .. sessionFile)
end

local function rgFiles(opts)
  local filesCmd = "rg --files "
  if opts.nargs == 2 then
    filesCmd = filesCmd .. "-t " .. opts.fargs[2]
  end
  local cmd = filesCmd .. " | rg .*" .. opts.fargs[1] .. ".*"
  local paths = vim.fn.systemlist(cmd)

  -- Build quickfix entries: { filename = <path>, lnum = 0 }
  local items = vim.tbl_map(function(path)
    return { filename = path, lnum = 0 }
  end, paths)

  vim.fn.setqflist(items)
  vim.cmd("copen")
end

local function rgAllFiles(opts)
  local args = opts.args
  local cmd = "rg --files -t " .. args .. " | rg .*"
  local paths = vim.fn.systemlist(cmd)

  -- Build quickfix entries: { filename = <path>, lnum = 0 }
  local items = vim.tbl_map(function(path)
    return { filename = path, lnum = 0 }
  end, paths)

  vim.fn.setqflist(items)
  vim.cmd("copen")
end

function M:init()
  self
    -- Dependencies
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  -- :FdList {pattern}
  deps.nvim:command("RgFiles", rgFiles, { nargs = "+" })
  deps.nvim:command("RgAllFiles", rgAllFiles, { nargs = 1 })

  -- :Fd {pattern}  (with completion from `fd`)
  deps.nvim:command("Fd", function(opts)
    local args = opts.args
    vim.cmd("edit " .. args)
  end, {
    nargs = 1,
    complete = function(arglead, cmdline, cursorpos)
      -- Return a list of paths from `fd` for completion
      return vim.fn.systemlist("fd " .. arglead)
    end,
  })

  deps.nvim:map('n', '<leader>aa', ':argadd | argdedupe<CR>', {silent = true})
    :map('n', '<c-p>', ':Fd ')
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
    :map('n', '<leader>ao', readSession)
    :autocmd({'VimLeave'}, {
      callback = writeSession
    })
    :autocmd({'TabNew'}, {
      callback = function()
        vim.cmd('arglocal')
      end
    })

  if self:has('autoload') then
    deps.nvim:autocmd({'VimEnter'}, {
      callback = readSession
    })
  end
end

return M
