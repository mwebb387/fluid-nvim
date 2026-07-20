local M = {}

function M:setup()
  -- Create user command for npm run
  if self:has('android') then
    require('fluid.modules.commandlinetools.android').setup()
  end

  if self:has('ionic') then
    require('fluid.modules.commandlinetools.ionic').setup()
  end

  if self:has('npm') then
    require('fluid.modules.commandlinetools.npm').setup()
  end
end

return M
