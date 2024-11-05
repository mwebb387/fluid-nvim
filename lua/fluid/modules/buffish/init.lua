local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('buffish').from('mong8se/buffish.nvim')
    :depends_on('fluid.nvim').as('nvim')
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
