local M = {}

function M:init()
  self:use('https://codeberg.org/andyg/leap.nvim').providing('leap')
end

function M:setup(deps)
  -- deps.leap.add_default_mappings()
end

return M
