local M = {}

function M.find(list, fn)
  for _, opt in ipairs(list) do
    if fn(opt) then
      return opt
    end
  end
  return nil
end

M.select_list_async = function(opts)
  if not opts then
    error('Options must be a list or a function that returns a list')
  end

  local select_list = {}
  local err_msg = 'No options found'

  local function resolve(value)
    if type(value) == 'function' then
      return value()
    end

    return value
  end

  if #opts > 0 then
    select_list = opts
  elseif opts.list then
    select_list = opts.list
  elseif opts.cmd then
    local list_result = vim.system(opts.cmd, { cwd = resolve(opts.cwd), text = true }):wait()
    if list_result.code ~= 0 then
      vim.notify(list_result.stderr ~= '' and list_result.stderr or err_msg, vim.log.levels.ERROR)
      return {}
    end

    local stdout = vim.trim(list_result.stdout)
    if stdout == '' then
      select_list = {}
    else
      select_list = vim.split(stdout, '\n', { plain = true })
    end
  elseif opts.get_list then
    select_list = opts.get_list() or {}
  end

  if #select_list == 0 then
    vim.notify(err_msg, vim.log.levels.ERROR)
    return {}
  end

  vim.ui.select(select_list, opts, function(choice)
    if opts.next then
      opts.next(choice)
    end
  end)
  -- vim.fn['fzf#run']({
  --   source = select_list,
  --   sink = function(choice)
  --     if opts.next then
  --       opts.next(choice)
  --     end
  --   end,
  --   window = {
  --     width = 0.8,
  --     height = 0.6
  --   },
  --   exit = function(code)
  --     vim.print('code', code)
  --   end,
  -- })

end

return M
