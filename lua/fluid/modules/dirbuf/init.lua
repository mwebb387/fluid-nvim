local M = {}

function M:init()
  self:use('elihunter173/dirbuf.nvim').providing('dirbuf')
end

function M:setup(deps)
  deps.dirbuf.setup()
end

return M
