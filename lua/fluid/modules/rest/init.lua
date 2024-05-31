local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('rest-nvim')
      .as('rest')
      .from('rest-nvim/rest.nvim')
end

function M:setup(deps)
  deps.rest.setup()
end

return M
