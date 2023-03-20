local M = {}

function M:init()
  self
    -- Plugins
    :use('elihunter173/dirbuf.nvim')
    :depends('dirbuf')
end

function M:setup(deps)
  deps.dirbuf.setup()
end

return M
