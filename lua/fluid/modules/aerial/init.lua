local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('aerial').from('stevearc/aerial.nvim')
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.aerial.setup({
    on_attach = function(bufnr)
      -- Jump forwards/backwards with '{' and '}'
      deps.nvim
        :map('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
        :map('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
    end,
  })
  deps.nvim:map('n', '<leader>a', '<cmd>AerialToggle!<CR>')
end

return M
