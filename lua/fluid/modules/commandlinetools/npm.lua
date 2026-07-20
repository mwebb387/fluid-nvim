local util = require('fluid.modules.commandlinetools.util')

local function complete_script()
  local package = vim.fs.find({'package.json'}, { upward = true, type = 'file' })

  if not package or #package == 0 then
    vim.notify('No package.json found', vim.log.levels.ERROR)
    return {}
  end

  local json = vim.fn.json_decode(table.concat(vim.fn.readfile(package[1]), '\n'))
  local scripts = vim.tbl_keys(json.scripts or {})

  table.sort(scripts)

  return scripts
end


local function run_script(args)
  if args == nil or #args == 0 then
    vim.notify('No npm script selected', vim.log.levels.ERROR)
    return
  end

  local package = vim.fs.find({'package.json'}, { upward = true, type = 'file' })

  if not package or #package == 0 then
    vim.notify('No package.json found', vim.log.levels.ERROR)
    return {}
  end

  local runArgs = { 'npm', 'run' }
  vim.list_extend(runArgs, args)

  util.open_floating_terminal(
    { title = 'npm run', cwd = vim.fs.dirname(package[1]) }
  )
end

local completeMap = {
  ['Run'] = complete_script,
}

local runMap = {
  ['Run'] = run_script,
}

local M = {}

function M.setup()
  --
  -- Create user command for npm run
  vim.api.nvim_create_user_command(
    'Npm',
    function(input)
      util.do_run(input.fargs, runMap)
    end,
    {
      desc = 'NPM commands',
      complete = function(A, L, P)
        return util.do_complete(A, L, P, completeMap)
      end,
      nargs = '*',
    })
end

return M
