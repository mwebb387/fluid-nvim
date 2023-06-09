local M = {}

function M:init()
  self:depends_on('dirbuf').from('elihunter173/dirbuf.nvim')
end

function M:setup(deps)
  deps.dirbuf.setup()
end

return M
