local M = {}

function M:init()
  self
    :depends_on('nvim-autopairs')
      .from('windwp/nvim-autopairs')
      .as('ap')
    -- :use('windwp/nvim-autopairs')
    -- :depends('nvim-autopairs', 'ap')
end

function M:setup(deps)
  deps.ap.setup()
end

return M
