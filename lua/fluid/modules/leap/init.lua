local M = {}

function M:init()
  self
    :use('ggandor/leap.nvim')
    :depends('leap')
end

function M:setup(deps)
  deps.leap.add_default_mappings()
end

return M
