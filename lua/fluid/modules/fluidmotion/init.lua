local M = {
  -- TODO: options for starting mode
  n_cmd = 'bnext',
  N_cmd = 'bprevious'
}

function M:set_cur_cmd(cmd_fwd, cmd_back)
  self.n_cmd = cmd_fwd
  self.N_cmd = cmd_back
end

function M:run_cur_cmd_fwd()
  vim.cmd(self.n_cmd)
end

function M:run_cur_cmd_back()
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
  self:depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  -- General purpose motion maps
  deps.nvim
    :map('n', 'H', '^')
    :map('n', 'L', '$')
    :map('n', '<c-d>', '<c-d>zz')
    :map('n', '<c-u>', '<c-u>zz')
    :map('n', '<tab>', '<c-w>w')
    :map('n', '<s-tab>', '<c-w>W')

  -- ; Next/Previous maps
    :map('n', ']b', function() self:set_and_run_cmd('bnext', 'bprevious') end)
    :map('n', '[b', function() self:set_and_run_cmd('bnext', 'bprevious', true) end)
    :map('n', ']t', function() self:set_and_run_cmd('tabnext', ':tabprevious') end)
    :map('n', '[t', function() self:set_and_run_cmd('tabnext', ':tabprevious', true) end)
    :map('n', ']q', function() self:set_and_run_cmd('cnext', ':cprevious') end)
    :map('n', '[q', function() self:set_and_run_cmd('cnext', ':cprevious', true) end)
    :map('n', ']l', function() self:set_and_run_cmd('lnext', ':lprevious') end)
    :map('n', '[l', function() self:set_and_run_cmd('lnext', 'lprevious', true) end)
    -- TODO: How to handle window switching...
    -- :map('n', ']w', function() self:set_and_run_cmd('<c-w>w', '<c-w>W') end)
    -- :map('n', '[w', function() self:set_and_run_cmd('<c-w>w', '<c-w>W', true) end)

    :map('n', ';', function() self:run_cur_cmd_fwd() end)
    :map('n', ',', function() self:run_cur_cmd_back() end)
end

return M
