local M = {}

function M:init(fluid)
  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:css')
  end
end

-- function M:setup()
-- end

return M
