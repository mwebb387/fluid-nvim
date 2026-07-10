-- Lazy-loading engine: plugins are installed by vim.pack but kept off the
-- runtimepath until a trigger fires. Stub shapes follow lazy.nvim/packer:
-- stubs delete themselves before loading, then replay the trigger.

-- Plugins are keyed by spec.src — the exact string fluid handed vim.pack,
-- returned verbatim in its load callback — rather than by a re-derived
-- plugin name, so fluid never has to mirror vim.pack's name inference.
local M = {
  pending = {},     -- src -> { path, name } (name = install dir basename)
  loaded = {},      -- src -> true
  require_map = {}, -- lua require path -> module trigger fn
  owners = {},      -- src -> module trigger fn
}

local augroup = vim.api.nvim_create_augroup('FluidLazy', { clear = true })

-- NOTE: brace expansion ('*.{vim,lua}') in vim.fn.glob does not work on
-- Windows, so glob each extension separately
local function glob_scripts(pattern)
  local scripts = vim.fn.glob(pattern .. '.vim', false, true)
  return vim.list_extend(scripts, vim.fn.glob(pattern .. '.lua', false, true))
end

-- require()-triggered loading: a searcher appended to package.loaders, so
-- it only runs when a require would otherwise fail. Requiring any lua
-- module belonging to a pending lazy plugin loads its fluid module.

local function resolve_chunk(modname)
  local rel = 'lua/' .. modname:gsub('%.', '/')
  local file = vim.api.nvim_get_runtime_file(rel .. '.lua', false)[1]
    or vim.api.nvim_get_runtime_file(rel .. '/init.lua', false)[1]
  if not file then
    return
  end

  local chunk, err = loadfile(file)
  if not chunk then
    error(err)
  end

  -- The trigger may already have loaded this module (e.g. a plugin config
  -- requiring its own provided path); never execute the file twice.
  -- NOTE: require() marks in-progress loads with a private sentinel in
  -- package.loaded before calling this loader — only value types a
  -- completed require can produce count as "already loaded".
  return function(...)
    local cached = package.loaded[modname]
    local t = type(cached)
    if t == 'table' or t == 'function' or t == 'string' or t == 'boolean' then
      return cached
    end
    return chunk(...)
  end
end

-- Walk 'a.b.c' -> 'a.b' -> 'a' so requiring a submodule of a provided
-- require path still triggers the owning module
local function map_lookup(modname)
  local name = modname
  while name do
    if M.require_map[name] then
      return M.require_map[name]
    end
    name = name:match('^(.+)%.[^.]+$')
  end
end

local searching = {}

function M.loader(modname)
  if searching[modname] then
    return
  end

  local trigger = map_lookup(modname)

  if not trigger then
    -- Fallback: scan pending plugin dirs for a matching lua module
    local rel = modname:gsub('%.', '/')
    for src, entry in pairs(M.pending) do
      if vim.uv.fs_stat(entry.path .. '/lua/' .. rel .. '.lua')
        or vim.uv.fs_stat(entry.path .. '/lua/' .. rel .. '/init.lua') then
        trigger = M.owners[src] or function() M.load(src) end
        break
      end
    end
  end

  if not trigger then
    return
  end

  searching[modname] = true
  local ok, err = pcall(trigger)
  searching[modname] = nil
  if not ok then
    error(err, 0)
  end

  return resolve_chunk(modname)
end

local loader_installed = false

local function install_loader()
  if not loader_installed then
    loader_installed = true
    table.insert(package.loaders, M.loader)
  end
end

-- Callback for vim.pack.add's `load` option: vim.pack installs the plugin
-- and hands over {spec, path} without touching the runtimepath
function M.register(plug_data)
  install_loader()

  local src = plug_data.spec.src
  if not M.loaded[src] then
    M.pending[src] = {
      path = plug_data.path,
      name = vim.fn.fnamemodify(plug_data.path, ':t'),
    }
  end
end

function M.path_of(src)
  local entry = M.pending[src]
  return entry and entry.path
end

-- Fully load a pending plugin: packadd, then run 'after/plugin' scripts,
-- which :packadd does not source after startup (see vim.pack's pack_add)
function M.load(src)
  local entry = M.pending[src]
  if not entry then
    return false
  end

  M.pending[src] = nil
  M.loaded[src] = true

  vim.cmd.packadd({ vim.fn.escape(entry.name, ' '), magic = { file = false } })

  if vim.v.vim_did_enter == 1 then
    for _, p in ipairs(glob_scripts(entry.path .. '/after/plugin/**/*')) do
      vim.cmd.source({ p, magic = { file = false } })
    end
  end

  return true
end

-- Source an unloaded plugin's ftdetect scripts so its filetypes are
-- detectable before the plugin itself is loaded
function M.ftdetect(path)
  vim.cmd('augroup filetypedetect')
  for _, p in ipairs(glob_scripts(path .. '/ftdetect/*')) do
    vim.cmd.source({ p, magic = { file = false } })
  end
  vim.cmd('augroup END')
end

local function as_list(v)
  if type(v) == 'table' and (v.event or v.mode) == nil then
    return v
  end
  return { v }
end

-- Every stub_* function creates trigger stubs and returns an idempotent
-- deleter. `on_trigger()` must load the plugins and run deferred config,
-- returning the list of loaded plugin paths; replay is the stub's job.

function M.stub_cmd(cmds, on_trigger)
  local names = as_list(cmds)
  local deleted = {}

  local function del(cmd)
    if not deleted[cmd] then
      deleted[cmd] = true
      pcall(vim.api.nvim_del_user_command, cmd)
    end
  end

  for _, cmd in ipairs(names) do
    vim.api.nvim_create_user_command(cmd, function(ev)
      del(cmd)
      on_trigger()

      local info = vim.api.nvim_get_commands({})[cmd]
        or vim.api.nvim_buf_get_commands(0, {})[cmd]
      if not info then
        vim.notify("fluid: loading did not define command '" .. cmd .. "'", vim.log.levels.ERROR)
        return
      end

      -- Re-execute with the captured context (table form keeps bang/range/mods)
      local command = { cmd = cmd, bang = ev.bang, mods = ev.smods }
      if #ev.fargs > 0 then
        command.args = ev.fargs
      end
      if info.nargs and info.nargs:find('[1?]') and ev.args ~= '' then
        command.args = { ev.args }
      end
      if ev.range == 1 then
        command.range = { ev.line1 }
      elseif ev.range == 2 then
        command.range = { ev.line1, ev.line2 }
      end

      vim.cmd(command)
    end, {
      nargs = '*',
      range = true,
      bang = true,
      complete = function(_, line)
        -- Completing the command is also a trigger; delegate to the real
        -- command's completion once loaded
        del(cmd)
        on_trigger()
        return vim.fn.getcompletion(line, 'cmdline')
      end,
    })
  end

  return function()
    for _, cmd in ipairs(names) do
      del(cmd)
    end
  end
end

-- Snapshot which augroups already handle `event`, so after loading we can
-- re-fire it only for autocmds the freshly loaded plugins registered
local function event_groups(event)
  local groups = {}
  for _, au in ipairs(vim.api.nvim_get_autocmds({ event = event })) do
    groups[au.group or 0] = true
  end
  return groups
end

local function replay_event(event, before, ev)
  local done = {}
  for _, au in ipairs(vim.api.nvim_get_autocmds({ event = event })) do
    local group = au.group or 0
    if not before[group] and not done[group] then
      done[group] = true
      pcall(vim.api.nvim_exec_autocmds, event, {
        group = au.group,
        pattern = ev.match ~= '' and ev.match or nil,
        modeline = false,
        data = ev.data,
      })
    end
  end
end

function M.stub_event(events, on_trigger, post_fire)
  local ids = {}
  local fired = false

  for _, e in ipairs(as_list(events)) do
    local event, pattern
    if type(e) == 'table' then
      event, pattern = e.event, e.pattern
    else
      local sp = e:find(' ', 1, true)
      if sp then
        event, pattern = e:sub(1, sp - 1), e:sub(sp + 1)
      else
        event = e
      end
    end

    ids[#ids + 1] = vim.api.nvim_create_autocmd(event, {
      group = augroup,
      pattern = pattern,
      once = true,
      callback = function(ev)
        if fired then
          return
        end
        fired = true

        local before = event_groups(ev.event)
        local paths = on_trigger()
        replay_event(ev.event, before, ev)

        if post_fire then
          post_fire(ev, paths or {})
        end
      end,
    })
  end

  return function()
    for _, id in ipairs(ids) do
      pcall(vim.api.nvim_del_autocmd, id)
    end
  end
end

function M.stub_ft(fts, on_trigger)
  local events = {}
  for _, ft in ipairs(as_list(fts)) do
    events[#events + 1] = { event = 'FileType', pattern = ft }
  end

  -- The FileType event already ran for the triggering buffer before the
  -- plugin was on the runtimepath, so source its filetype support directly
  return M.stub_event(events, on_trigger, function(ev, paths)
    for _, path in ipairs(paths) do
      for _, dir in ipairs({ 'ftplugin', 'after/ftplugin', 'indent', 'after/indent', 'syntax', 'after/syntax' }) do
        for _, p in ipairs(glob_scripts(path .. '/' .. dir .. '/' .. ev.match)) do
          vim.cmd.source({ p, magic = { file = false } })
        end
      end
    end
  end)
end

function M.stub_keys(keys, on_trigger)
  local deleters = {}

  for _, k in ipairs(as_list(keys)) do
    local mode, lhs
    if type(k) == 'table' then
      mode, lhs = k.mode or k[1], k.lhs or k[2]
    else
      mode, lhs = 'n', k
    end

    local deleted = false
    local function del()
      if not deleted then
        deleted = true
        pcall(vim.keymap.del, mode, lhs)
      end
    end

    -- Delete the stub before loading (recursion guard), then feed the keys
    -- back ahead of pending typeahead so the real mapping handles them.
    -- expr = true is needed for operator-pending mappings to work.
    vim.keymap.set(mode, lhs, function()
      del()
      on_trigger()
      local feed = vim.api.nvim_replace_termcodes('<Ignore>' .. lhs, true, true, true)
      vim.api.nvim_feedkeys(feed, 'i', false)
    end, { expr = true, silent = true, desc = 'fluid: lazy-load trigger' })

    deleters[#deleters + 1] = del
  end

  return function()
    for _, d in ipairs(deleters) do
      d()
    end
  end
end

return M
