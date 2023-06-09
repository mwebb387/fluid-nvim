local M = {}

function M:init()
  -- print('init for winbar')

  self
    :depends_on('fluidline')
    :depends_on('nvim-web-devicons').as('icons')
end

function M:setup(deps)
  _G.SLFileIcon = function()
    return deps.icons.get_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e')) or ''
  end

  vim.opt.winbar = tostring(deps.fluidline
    :new()
    :append ' '
    :highlight 'Number'
    :filename_relative()
    :append ' '
    :eval_lua 'SLFileIcon'
    -- :highlight 'Comment'
    -- :append ' [ '
    -- :eval 'nvim_treesitter#statusline()'
    -- :append ' ]'
  )
end

return M
