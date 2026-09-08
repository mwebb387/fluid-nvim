local util = require('fluid.modules.commandlinetools.util')
local M = {}

local function get_listener_app_path()
  return 'C:\\repos\\other\\ios-console-tail\\ios-console-tail.mjs'
end

local function run_logtail(args)
  vim.notify('Make sure you have installed and started ios_webkit_debug_proxy')

  local listener_app_path = get_listener_app_path()
  if not listener_app_path then
    vim.notify('listener_app_path not found', vim.log.levels.ERROR)
    return
  end

  local runArgs = { 'node', listener_app_path }
  vim.list_extend(runArgs, args)

  util.open_terminal_buffer(
    runArgs,
    { title = 'Logtail' }
  )
end

local completeMap = {
  ['Logtail'] = {},
}

local runMap = {
  ['Logtail'] = run_logtail,
}

function M.setup()
  -- Create user command for Android
  vim.api.nvim_create_user_command(
    'Ios',
    function(input)
      util.do_run(input.fargs, runMap)
    end,
    {
      desc = 'iOS commands',
      complete = function(A, L, P)
        return util.do_complete(A, L, P, completeMap)
      end,
      nargs = '*',
    })
end

return M
