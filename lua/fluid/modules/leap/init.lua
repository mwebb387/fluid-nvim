local M = {}

function M:init()
  self:depends_on('leap').from('ggandor/leap.nvim')
end

function M:setup(deps)
  deps.leap.add_default_mappings()
end

return M
