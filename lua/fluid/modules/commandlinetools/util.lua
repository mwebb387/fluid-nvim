local M = {}

function M.get_project_root()
  return vim.fs.root(0, { 'package.json', '.git' }) or vim.fn.getcwd()
end

function M.open_floating_terminal(cmd, opts)
  opts = opts or {}

  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = opts.title or 'Terminal',
    title_pos = 'center',
  })

  vim.bo[buf].bufhidden = 'wipe'

  vim.api.nvim_win_call(win, function()
    vim.fn.jobstart(cmd, {
      term = true,
      cwd = opts.cwd,
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_buf_set_keymap(
              buf,
              'n',
              'q',
              '<cmd>close<cr>',
              { noremap = true, silent = true }
            )
          end
        end)
      end,
    })
  end)

  vim.cmd.startinsert()
end

function M.open_terminal_buffer(cmd, opts)
  opts = opts or {}

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)

  vim.fn.jobstart(cmd, {
    term = true,
    cwd = opts.cwd,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_set_keymap(
            bufnr,
            'n',
            'q',
            '<cmd>bd!\r',
            { noremap = true, silent = true }
          )
        end
      end)
    end,
  })

  vim.cmd.startinsert()
end

function M.complete_map(args, map)
  if #args > 0 and type(map) == 'table' and map[args[1]] then
    return M.complete_map(vim.list_slice(args, 2), map[args[1]])
  elseif type(map) == 'function' then
    return map(args)
  elseif type(map) == 'table' then
    return vim.tbl_keys(map) or map
  end
end

function M.do_complete(_, L, _, completeMap)
  local subs = vim.list_slice(vim.fn.split(L, ' ', false), 2)
  return M.complete_map(subs, completeMap)
end

function M.do_run(args, runMap)
  return M.complete_map(args, runMap)
end

return M
