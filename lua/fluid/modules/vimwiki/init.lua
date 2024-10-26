local M = {}

function M:init()
  self:depends_on('vimwiki').from('vimwiki/vimwiki')
end

return M
