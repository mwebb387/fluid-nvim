local M = {
  config = {
    ensure_installed = {'vim', 'lua'}, -- Move to lang plugins once 
    highlight = { enable = false },
    incremental_selection = {
      enable = false,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm'
      }
    },
    indent = { enable = false }
  }
}

-- Module methods
function M:ensure_installed(lang)
  table.insert(self.config.ensure_installed, lang)
  return self
end

function M:highlight(enable)
  self.config.highlight.enable = enable
  return self
end

function M:incremental_selection(enable)
  self.config.incremental_selection.enable = enable
  return self
end

function M:indent(enable)
  self.config.indent.enable = enable
  return self
end

function M:init()
  -- plugin register treesitter
  self
    -- Plugins
    -- :use('nvim-treesitter/nvim-treesitter')

    -- Dependencies
    :depends_on('nvim-treesitter.configs')
      .as('treesitter')
      .from('nvim-treesitter/nvim-treesitter')

    -- Config based on opts
    :highlight(self:has('highlight'))
    :incremental_selection(self:has('incremental_selection'))
    :indent(self:has('indent'))

    -- Get ensured languages
    for _, op in ipairs(self.options) do
      local _, e = string.find(op, 'lang:')
      if e then
        local lang = string.sub(op, e + 1)
        self:ensure_installed(lang)
      end
    end
end

function M:setup(deps)
  deps.treesitter.setup(self.config)

  if self:has('folding') then
    vim.opt.foldmethod = 'expr'
    vim.opt.foldlevel = 99
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  end
end

return M
