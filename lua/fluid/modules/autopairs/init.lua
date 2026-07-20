local M = {}

function M:init()
  self
    :use('windwp/nvim-autopairs')
      .opt()
      .providing('nvim-autopairs')
      .as('ap')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  deps.nvim:autocmd('InsertEnter', {
    callback = function()
      deps.lazy.ap.setup()
    end
  })
end

return M
