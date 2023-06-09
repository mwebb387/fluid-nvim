local M = {}

function M:init()
  self
    -- Plugins
    :use(
      'catppuccin/nvim',
      'rebelot/kanagawa.nvim',
      'EdenEast/nightfox.nvim',
      'talha-akram/noctis.nvim',
      'maxmx03/fluoromachine.nvim',
      'folke/tokyonight.nvim',
      'rose-pine/neovim')

    :depends_on('rose-pine').as('rosepine')
end

function M:setup(deps)
  -- TODO: should this be a module?
  deps.rosepine.setup({
    variant = 'moon',
    disable_italics = true
  })

  vim.o.termguicolors = true -- TODO: update to fluid config
  vim.cmd.colorscheme(self.options[1] or 'default')
end

return M
