local M = {
  config = {
    load = {
      ['core.defaults'] = {},
      ['core.norg.dirman'] = {
        config = {
          workspaces = { work = '~/.norg/work' }
        }
      },
      ['core.norg.completion'] = {
        config = {
          engine = 'nvim-cmp'
        }
      },
      ['core.norg.concealer'] = {},
      ['core.norg.qol.toc'] = {}
    }
  }
}

function M:init(fluid)
  self
    :use('nvim-neorg/neorg')
    :depends_on('fluid.nvim').as('nvim')

  -- Neorg treesitter parsers
  fluid:treesitter():options('lang:norg', 'lang:norg_meta')

  -- TODO: options for neorg...
end

function M:setup(deps)
  deps.nvim:map('n', '<leader>LN', function()
    require('neorg').setup(self.config)
    vim.keymap.del('n', '<leader>LN')
  end, { desc = 'Load Neorg'})
end

return M
