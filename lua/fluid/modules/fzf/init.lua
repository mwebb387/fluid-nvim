local M = {
  config = {
    keymap = {
      builtin = {
        ['ctrl-d'] = 'preview-page-down',
        ['ctrl-u'] = 'preview-page-up',
      }
    }
  }
}

function M:init()
  if self:has('lua') then
    self:depends_on('fzf-lua')
      .from('ibhagwan/fzf-lua')
      .as('fzf_lua')
  else
    self
      :use('junegunn/fzf')
      :depends_on('fzf-opts').as('fzf_o')
  end

  self:depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  if self:has('lua') then
    deps.fzf_lua.setup(self.config)

    -- Keymaps
    deps.nvim:map('n', '<C-p>', '<cmd>FzfLua git_files<CR>')
    deps.nvim:map('n', '<leader>ff', '<cmd>FzfLua files<CR>')
    deps.nvim:map('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>')
    deps.nvim:map('n', '<leader>fh', '<cmd>FzfLua helptags<CR>')
    deps.nvim:map('n', '<leader>fo', '<cmd>FzfLua oldfiles<CR>')
  else
    deps.nvim:map('n', '<C-p>', function()
      local opts = {
        sink = 'e',
        options = deps.fzf_o.create_opts()
      }
      vim.fn['fzf#run'](vim.fn['fzf#wrap'](opts))
    end)
  end
end

return M
