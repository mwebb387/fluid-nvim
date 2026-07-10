local M = {
  config = {
    defaults = {
      prompt_prefix = ' ',
      selection_caret = ' '
    }
  }
}

function M:init()
  self
    :use('nvim-telescope/telescope.nvim')
      .providing('telescope')
      .providing('telescope.actions')
        .as('actions')
    :use('fluid.nvim')
      .as('nvim')
end

function M:setup(deps)
  -- General maps
  deps.nvim
    :map('n', '<leader>ff', '<cmd>Telescope find_files theme=ivy<CR>')
    :map('n', '<leader>fb', '<cmd>Telescope buffers theme=ivy<CR>')
    :map('n', '<leader>b', '<cmd>Telescope buffers theme=ivy<CR>')
    :map('n', '<leader>fg', '<cmd>Telescope live_grep theme=ivy<CR>')
    :map('n', '<leader>fh', '<cmd>Telescope help_tags theme=ivy<CR>')
    :map('n', '<leader>fo', '<cmd>Telescope oldfiles theme=ivy<CR>')
    :map('n', '<leader>fr', '<cmd>Telescope registers theme=ivy<CR>')
    :map('n', '<leader>fq', '<cmd>Telescope quickfix theme=ivy<CR>')
    :map('n', '<leader>fd', '<cmd>Telescope diagnostics bufnr=0 theme=ivy<CR>')
    :map('n', '<leader>fD', '<cmd>Telescope diagnostics theme=ivy<CR>')
    :map('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols theme=ivy<CR>')

    -- Git maps
    :map('n', '<leader>gb', '<cmd>Telescope git_branches theme=ivy<CR>')
    :map('n', '<leader>gc', '<cmd>Telescope git_commits theme=ivy<CR>')
    :map('n', '<c-p>', '<cmd>Telescope git_files theme=ivy<CR>')
    :map('n', '<leader>gf', '<cmd>Telescope git_files theme=ivy<CR>')
    :map('n', '<leader>gs', '<cmd>Telescope git_status theme=ivy<CR>')
    :map('n', '<leader>gS', '<cmd>Telescope git_stash theme=ivy<CR>')

    -- Terminal maps
    :map('t', '<a-f>', '<c-\\><c-n> <cmd>Telescope find_files theme=ivy<CR>')
    :map('t', '<a-/>', '<c-\\><c-n> <cmd>Telescope live_grep theme=ivy<CR>')

  local mappings = {
    i = {
      ['<esc>'] = deps.actions.close,
      ['<c-h>'] = deps.actions.move_to_top,
      ['<c-j>'] = deps.actions.move_selection_next,
      ['<c-k>'] = deps.actions.move_selection_previous,
      ['<c-l>'] = deps.actions.move_to_bottom,
      ['<c-z>'] = deps.actions.delete_buffer
    }
  }

  self.config.defaults.mappings = mappings
  deps.telescope.setup(self.config)
end

return M
