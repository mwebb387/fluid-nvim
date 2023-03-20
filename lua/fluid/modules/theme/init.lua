local M = {}

function M:init()
  self
    -- Plugins
    :use(
      'EdenEast/nightfox.nvim',
      'talha-akram/noctis.nvim',
      'rose-pine/neovim')

    :depends('rose-pine', 'rosepine')
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
