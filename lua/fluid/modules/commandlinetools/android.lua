local util = require('fluid.modules.commandlinetools.util')
local M = {}

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

function M.get_process_id(application_name)
  local adb = get_adb_path()
  if not adb then
    vim.notify('adb not found', vim.log.levels.ERROR)
    return {}
  end

  -- 'adb shell pidof com.your.package.name'
  local systemlist_args = { adb, 'shell', 'pidof', application_name }
  local lines = vim.fn.systemlist(systemlist_args)
  if #lines == 0 then
    return nil
  end

  local process_id = vim.fn.trim(lines[1])
  return process_id
end

function M.complete_processes(args)
  local adb = get_adb_path()
  if not adb then
    vim.notify('adb not found', vim.log.levels.ERROR)
    return {}
  end

  local lines = vim.fn.systemlist({ adb, 'shell', 'ps'})
  local processes = vim.tbl_map(function(line)
    local line_parts = vim.fn.split(line, ' ', false)
    if #line_parts >= 2 and string.match(line_parts[1], '^u0_') and (
      args == nil or #args == 0 or string.match(line_parts[#line_parts], args[1])
    ) then
      return vim.fn.trim(line_parts[#line_parts])
    end
    return nil
  end, lines)

  processes = vim.tbl_filter(function(process)
    return process ~= nil
  end, processes)

  return processes
end

function M.complete_emulator()
  -- Create select memo for emaultor selection
  local emulator = get_emulator_path()
  if not emulator then
    vim.notify('emulator not found', vim.log.levels.ERROR)
    return {}
  end

  local avds = vim.fn.systemlist({emulator, '-list-avds'})
  avds = vim.tbl_map(function(avd) return vim.fn.trim(avd) end, avds)

  if #avds == 0 then
    vim.notify('No emulators found', vim.log.levels.ERROR)
    return {}
  end

  return avds
end

function M.complete_device()
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

local function run_logcat(args)
  local adb = get_adb_path()
  if not adb then
    vim.notify('adb not found', vim.log.levels.ERROR)
    return {}
  end

  local process_id = nil
  if args and #args > 0 then
    process_id = M.get_process_id(args[1])
    if process_id == nil then
      vim.notify('No process found', vim.log.levels.ERROR)
      return
    end
  end

  local runArgs = { adb, 'logcat' }
  if process_id then
    runArgs = { adb, 'logcat', '--pid=' .. process_id }
  end

  util.open_terminal_buffer(
    runArgs,
    { title = 'Logcat' }
  )
end

local completeMap = {
  ['Emulator'] = M.complete_emulator,
  ['Device'] = M.complete_device,
  ['Logcat'] = M.complete_processes,
}

local runMap = {
  ['Emulator'] = run_emulator,
  ['Device'] = run_device,
  ['Logcat'] = run_logcat,
}

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
