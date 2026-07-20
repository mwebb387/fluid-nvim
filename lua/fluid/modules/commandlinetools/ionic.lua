local android = require('fluid.modules.commandlinetools.android')
local util = require('fluid.modules.commandlinetools.util')

local function complete_build_and_run(args)
  if (args == nil or #args == 0) then
    return { 'development', 'emulator', 'production' }
  end

  if #args == 1 then
    return android.complete_device()
  end

  return {}

end

local function run_build_and_run(args)
  if args == nil or #args == 0 then
    vim.notify('No build or device selected', vim.log.levels.ERROR)
    return
  end

  if #args == 1 then
    vim.notify('No device selected', vim.log.levels.ERROR)
    return
  end

  local run_cmd = table.concat({
    'npm run build -- --configuration=' .. args[1],
    'npx cap run android --target=' .. args[2],
  }, ' && ')

  util.open_floating_terminal(
    run_cmd,
    { title = 'Build and run' }
  )
end

local completeMap = {
  ['BuildAndRun'] = complete_build_and_run,
}

local runMap = {
  ['BuildAndRun'] = run_build_and_run,
}

local M = {}

function M.setup()
  -- Create user command for Ionic
  vim.api.nvim_create_user_command(
    'Ionic',
    function(input)
      util.do_run(input.fargs, runMap)
    end,
    {
      desc = 'Ionic commands',
      complete = function(A, L, P)
        return util.do_complete(A, L, P, completeMap)
      end,
      nargs = '*',
    })
end

return M
