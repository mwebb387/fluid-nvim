local M = {}

function M:init(fluid)
  self
    -- Plugins
    :use('tpope/vim-dadbod')

  if self:has('ui') then -- also check module registration
    self:use('kristijanhusak/vim-dadbod-ui')
  end

  if self:has('completion') then -- also check module registration
    self:use('kristijanhusak/vim-dadbod-completion')
  end
end

function M:setup(deps)
  vim.g.dbs = {
    { name = 'master', url = 'sqlserver://localhost/BizStreamMaster' },
    { name = 'youthcenter', url = 'sqlserver://localhost/YouthCenter_Local' }
  }
end

return M
