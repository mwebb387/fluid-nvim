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
  self:use('junegunn/fzf')

  if self:has('lua') then
    self:depends_on('fzf-lua')
      .from('ibhagwan/fzf-lua')
      .as('fzf_lua')
  end

  self:depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  if self:has('lua') then
    deps.fzf_lua.setup(self.config)

    -- Keymaps
    deps.nvim:map('n', '<C-p>', '<cmd>FzfLua git_files<CR>')
    deps.nvim:map('n', '<leader>ff', '<cmd>FzfLua files<CR>')
    deps.nvim:map('n', '<leader>fb', '<cmd>FzfLua buffers<CR>')
    deps.nvim:map('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>')
    deps.nvim:map('n', '<leader>fh', '<cmd>FzfLua helptags<CR>')
    deps.nvim:map('n', '<leader>fo', '<cmd>FzfLua oldfiles<CR>')
  end
end

return M
