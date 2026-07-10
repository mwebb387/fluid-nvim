local M = {}

function M:init()
  self
    -- Plugins
    :use('mong8se/buffish.nvim').providing('buffish')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim
    :map('n', '<a-p>', function()
      deps.buffish.open()
    end)
    :map('n', '<a-b>', function()
      require('buffish.shortcuts').follow()
    end)
end

return M
