local util = require('fluid.modules.commandlinetools.util')

local function get_adb_path()
  local adb = vim.fn.expand('$LOCALAPPDATA\\Android\\Sdk\\platform-tools\\adb.exe')
  if vim.fn.filereadable(adb) == 1 then
    return adb
  end

  if vim.fn.executable('adb') == 1 then
    return 'adb'
  end

  return nil
end

local function get_emulator_path()
  local emulator = vim.fn.expand('$LOCALAPPDATA\\Android\\Sdk\\emulator\\emulator.exe')
  if vim.fn.filereadable(emulator) == 1 then
    return emulator
  end

  if vim.fn.executable('emulator') == 1 then
    return 'emulator'
  end

  return nil
end

local function complete_emulator()
  -- Create select memo for emaultor selection
  local emulator = get_emulator_path()
  if not emulator then
    vim.notify('emulator not found', vim.log.levels.ERROR)
    return {}
  end

  local avds = vim.fn.systemlist({emulator, '-list-avds'})

  if #avds == 0 then
    vim.notify('No emulators found', vim.log.levels.ERROR)
    return {}
  end

  return avds
end

local function complete_device()
  local adb = get_adb_path()
  if not adb then
    vim.notify('adb not found', vim.log.levels.ERROR)
    return {}
  end

  local lines = vim.fn.systemlist({ adb, 'devices' })
  if vim.v.shell_error ~= 0 then
    vim.notify('Failed to query adb devices', vim.log.levels.ERROR)
    return
  end

  local devices = {}
  for _, line in ipairs(lines) do
    local id, state = line:match('^%s*(%S+)%s+(%S+)%s*$')
    if id and state == 'device' then
      table.insert(devices, id)
    end
  end

  if #devices == 0 then
    vim.notify('No connected Android devices found')
    return {}
  end

  return devices
end

local function run_emulator(args)
  if args == nil or #args == 0 then
    vim.notify('No emulator selected', vim.log.levels.ERROR)
    return
  end

  local runArgs = { 'emulator', '-avd' }
  vim.list_extend(runArgs, args)

  vim.fn.jobstart(runArgs, { detatch = true })
end

local function run_device(args)
  if args == nil or #args == 0 then
    vim.notify('No device selected', vim.log.levels.ERROR)
    return
  end

  local runArgs = { 'adb', 'connect' }
  vim.list_extend(runArgs, args)

  vim.fn.jobstart(runArgs, { detatch = true })
end

local completeMap = {
  ['Emulator'] = complete_emulator,
  ['Device'] = complete_device,
}

local runMap = {
  ['Emulator'] = run_emulator,
  ['Device'] = run_device,
}

local M = {}

function M.setup()
  -- Create user command for Android
  vim.api.nvim_create_user_command(
    'Android',
    function(input)
      util.do_run(input.fargs, runMap)
    end,
    {
      desc = 'Android commands',
      complete = function(A, L, P)
        return util.do_complete(A, L, P, completeMap)
      end,
      nargs = '*',
    })
end

return M
