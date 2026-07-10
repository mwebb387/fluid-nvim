local M = {
  config = {
    keymap = {
      builtin = {
        ['c-f'] = 'preview-page-down',
        ['c-b'] = 'preview-page-up',
      },
      fzf = {
        ['ctrl-f'] = 'preview-page-down',
        ['ctrl-b'] = 'preview-page-up',
      }
    }
  }
}

function M:init()
  self:use('junegunn/fzf')

  if self:has('lua') then
    self:use('ibhagwan/fzf-lua')
      .providing('fzf-lua')
      .as('fzf_lua')
  else
    self:use('junegunn/fzf.vim')
  end

  self:use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  if self:has('lua') then
    deps.fzf_lua.setup(self.config)

    -- Keymaps
    deps.nvim:map('n', '<C-p>', '<cmd>FzfLua git_files<CR>')
    deps.nvim:map('n', '<M-p>', '<cmd>FzfLua args<CR>')
    deps.nvim:map('n', '<leader>ff', '<cmd>FzfLua files<CR>')
    deps.nvim:map('n', '<leader>fb', '<cmd>FzfLua buffers<CR>')
    deps.nvim:map('n', '<leader>fh', '<cmd>FzfLua helptags<CR>')
    deps.nvim:map('n', '<leader>fo', '<cmd>FzfLua oldfiles<CR>')

    -- Grep
    deps.nvim:map('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>')
    deps.nvim:map('n', '<leader>fG', '<cmd>FzfLua grep_last<CR>')
    deps.nvim:map('v', '<leader>fg', '<cmd>FzfLua grep_visual<CR>')

  else
    -- Keymaps
    deps.nvim:map('n', '<C-p>', '<cmd>GFiles<CR>')
    deps.nvim:map('n', '<M-p>', '<cmd>Files<CR>')
    deps.nvim:map('n', '<M-b>', '<cmd>Buffers<CR>')

    -- Grep
    deps.nvim:map('n', '<leader>fg', '<cmd>RG<CR>')
  end
end

return M
