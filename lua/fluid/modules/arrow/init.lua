local M = {}

function M:init()
  self
    -- Plugins
    :use('otavioschwanck/arrow.nvim').providing('arrow')
    :use('fluid.nvim').as('nvim')
end
  -- :nullls()

function M:setup(deps)
  deps.arrow.setup({
    show_icons = true,
    leader_key = '\\', -- Recommended to be a single key
    buffer_leader_key = 'm', -- Per Buffer Mappings
  })
end

return M
