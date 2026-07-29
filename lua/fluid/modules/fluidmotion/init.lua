local M = {
  -- TODO: options for starting mode
  n_cmd = 'bnext',
  N_cmd = 'bprevious',
  log = false
}

function M:set_cur_cmd(cmd_fwd, cmd_back)
  self.n_cmd = cmd_fwd
  self.N_cmd = cmd_back
end

function M:run_cur_cmd_fwd()
  vim.print('n_cmd = ' .. self.n_cmd)
  vim.cmd(self.n_cmd)
end

function M:run_cur_cmd_back()
  vim.print('N_cmd = ' .. self.N_cmd)
  vim.cmd(self.N_cmd)
end

function M:set_and_run_cmd(cmd_fwd, cmd_back, run_back)
  self:set_cur_cmd(cmd_fwd, cmd_back)
  if (run_back) then
    self:run_cur_cmd_back()
  else
    self:run_cur_cmd_fwd()
  end
end

function M:init()
  if self:has('tab') then
    self:set_cur_cmd('tabnext', 'tabprevious')
  elseif self:has('qf') or self:has('quickfix') then
    self:set_cur_cmd('cnext', 'cprevious')
  elseif self:has('loc') or self:has('locationlist') then
    self:set_cur_cmd('lnext', 'lprevious')
  elseif self:has('win') or self:has('window') then
    self:set_cur_cmd('wincmd w', 'wincmd W')
  end

  if self:has('log') then self.log = true end

  self:use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  -- General purpose motion maps
  deps.nvim
    :map('n', 'H', '^')
    :map('n', 'L', '$')
    :map('n', '<c-d>', '<c-d>zz')
    :map('n', '<c-u>', '<c-u>zz')
    :map('n', '<c-f>', '<c-f>zz')
    -- :map('n', '<c-b>', '<c-b>zz')
    :map('n', '<CR>', '<c-w>w')
    :map('n', '<s-CR>', '<c-w>W')
    :map('n', '<BS>', ':b#<CR>')

    :map('n', '<a-h>', '<c-w>h', { noremap = true })
    :map('n', '<a-j>', '<c-w>j', { noremap = true })
    :map('n', '<a-k>', '<c-w>k', { noremap = true })
    :map('n', '<a-l>', '<c-w>l', { noremap = true })
    :map('n', '<a-q>', '<c-w>q', { noremap = true })

    :map('n', '<a-H>', '<c-w>H', { noremap = true })
    :map('n', '<a-J>', '<c-w>J', { noremap = true })
    :map('n', '<a-K>', '<c-w>K', { noremap = true })
    :map('n', '<a-L>', '<c-w>L', { noremap = true })

    :map('i', '<a-h>', '<c-w>h', { noremap = true })
    :map('i', '<a-j>', '<c-w>j', { noremap = true })
    :map('i', '<a-k>', '<c-w>k', { noremap = true })
    :map('i', '<a-l>', '<c-w>l', { noremap = true })
    :map('n', '<a-q>', '<c-w>q', { noremap = true })


    :map('t', '<a-h>', '<c-\\><c-n><c-w>h', { noremap = true })
    :map('t', '<a-j>', '<c-\\><c-n><c-w>j', { noremap = true })
    :map('t', '<a-k>', '<c-\\><c-n><c-w>k', { noremap = true })
    :map('t', '<a-l>', '<c-\\><c-n><c-w>l', { noremap = true })
    :map('t', '<a-q>', '<c-\\><c-n><c-w>q', { noremap = true })
    :map('t', '<a-n>', '<c-\\><c-n>', { noremap = true })

  -- ; Next/Previous maps
    :map('n', ']b', function() self:set_and_run_cmd('bnext', 'bprevious') end)
    :map('n', '[b', function() self:set_and_run_cmd('bnext', 'bprevious', true) end)
    :map('n', ']d', function() self:set_and_run_cmd('lua vim.diagnostic.goto_next()', 'lua vim.diagnostic.goto_prev()') end)
    :map('n', '[d', function() self:set_and_run_cmd('lua vim.diagnostic.goto_next()', 'lua vim.diagnostic.goto_prev()', true) end)
    :map('n', ']l', function() self:set_and_run_cmd('lnext', 'lprevious') end)
    :map('n', '[l', function() self:set_and_run_cmd('lnext', 'lprevious', true) end)
    :map('n', ']q', function() self:set_and_run_cmd('cnext', 'cprevious') end)
    :map('n', '[q', function() self:set_and_run_cmd('cnext', 'cprevious', true) end)
    :map('n', ']t', function() self:set_and_run_cmd('tabnext', 'tabprevious') end)
    :map('n', '[t', function() self:set_and_run_cmd('tabnext', 'tabprevious', true) end)
    :map('n', ']w', function() self:set_and_run_cmd('wincmd w', 'wincmd W') end)
    :map('n', '[w', function() self:set_and_run_cmd('wincmd w', 'wincmd W', true) end)
    :map('n', ']z', function() self:set_and_run_cmd('zj', 'zk') end)
    :map('n', '[z', function() self:set_and_run_cmd('zj', 'zk', true) end)

    :map('n', '<leader>n', function() self:run_cur_cmd_fwd() end)
    :map('n', '<leader>p', function() self:run_cur_cmd_back() end)
end

return M
