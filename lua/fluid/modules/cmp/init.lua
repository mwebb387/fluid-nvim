local M = {
  config = {
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
  }
}

function M:init()
  self:use(
   'hrsh7th/cmp-nvim-lsp',
   'hrsh7th/cmp-buffer',
   'hrsh7th/cmp-path',
   'hrsh7th/cmp-cmdline',
   'hrsh7th/cmp-vsnip',
   'hrsh7th/vim-vsnip',
   'rafamadriz/friendly-snippets'
  )
  self:depends_on('cmp').from('hrsh7th/nvim-cmp')
end

function M:setup(deps)
  self.config.window = {
    completion = deps.cmp.config.window.bordered(),
    documentation = deps.cmp.config.window.bordered(),
  }

  self.config.mapping = deps.cmp.mapping.preset.insert({
    ['<C-u>'] = deps.cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = deps.cmp.mapping.scroll_docs(4),
    ['<A-o>'] = deps.cmp.mapping.complete(),
    ['<C-e>'] = deps.cmp.mapping.abort(),
    ['<TAB>'] = deps.cmp.mapping.select_next_item(),
    ['<S-TAB>'] = deps.cmp.mapping.select_prev_item(),
    ['<CR>'] = deps.cmp.mapping.confirm({ select = true }) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  })

  self.config.sources = deps.cmp.config.sources(
    {
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
      { name = 'path' },
      { name = 'neorg' } -- TODO: Only set this up if Neorg is set to be used
    }, {
      { name = 'buffer' },
    }
  )

  deps.cmp.setup(self.config)
end

return M
