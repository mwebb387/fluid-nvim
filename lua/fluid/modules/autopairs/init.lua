local M = {}

function M:init()
  self
    :use('windwp/nvim-autopairs')
      .providing('nvim-autopairs')
      .as('ap')
end

function M:setup(deps)
  deps.ap.setup()
end

return M
