local M = {}

function M:init()
  self
    -- Plugins
    :use('rest-nvim/rest.nvim')
      .providing('rest-nvim')
      .as('rest')
end

function M:setup(deps)
  deps.rest.setup()
end

return M
