local M = {}

function M:init()
  self
    :use('kylechui/nvim-surround')
    :depends('nvim-surround', 'surround')
end

function M:setup(deps)
  deps.surround.setup()
end

return M
