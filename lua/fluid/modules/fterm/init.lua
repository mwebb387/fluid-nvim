-- Helper functions
local function nextTerminal()
  vim.cmd('20new')
  local termBufs = vim.fn.filter(
    vim.api.nvim_list_bufs(),
    function(_, val)
      return string.find(vim.api.nvim_buf_get_name(val), 'term://')
    end
  )

  if #termBufs > 0 then
    vim.api.nvim_win_set_buf(0, termBufs[1])
  else
    vim.fn.termopen('powershell')
  end
end

local function termOpenAndRun(cmd)
  vim.cmd('enew')
  vim.fn.termopen(cmd)
end

local M = {
  config = {
    cmd = 'powershell'
  }
}

function M:init()
  self
    :depends_on('fluid.nvim').as('nvim')
    :depends_on('FTerm').from('numToStr/FTerm.nvim')
end

function M:setup(deps)
  deps.nvim
    :map('n', '<M-`>', ':FTermToggle<CR>')
    :map('t', '<M-`>', ':<c-\\><c-n>:FTermToggle<CR>')
    :command('FTermToggle', function() deps.FTerm.toggle() end)
    :command('NextTerminal', nextTerminal)
    :command('Powershell', function() termOpenAndRun('powershell') end)
    :command('DotnetWatchDev', function() termOpenAndRun('powershell Dotnet-Watch-Dev') end)
    :command('NpmRun', function() termOpenAndRun('powershell Npm-Run') end)
    :command('NpmStart', function() termOpenAndRun('powershell Npm-Start') end)

  deps.FTerm.setup(self.config)
end

return M
