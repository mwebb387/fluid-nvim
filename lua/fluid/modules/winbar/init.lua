local M = {}

function M:init(fluid)
  -- print('init for winbar')

  fluid:fluidline()
  self
    :use('fluid.modules.fluidline').as('fluidline')
    :use('kyazdani42/nvim-web-devicons')
      .providing('nvim-web-devicons')
      .as('icons')
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
