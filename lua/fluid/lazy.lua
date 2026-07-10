-- Lazy plugin loading: install and load are separate. Plugins marked
-- opt() are installed by vim.pack at startup but kept off the runtimepath;
-- fluid loads them on demand (via deps.lazy in module setup) with a native
-- :packadd. No stubs, no trigger machinery — modules own their own entry
-- points (keymaps, autocmds, commands) and load happens on the way in.

-- Plugins are keyed by spec.src — the exact string fluid handed vim.pack,
-- returned verbatim in its load callback — so fluid never re-derives
-- plugin names; the :packadd name comes from the recorded install path.
local M = {
  pending = {}, -- src -> { path, name }
  loaded = {},  -- src -> true
}

-- NOTE: brace expansion ('*.{vim,lua}') in vim.fn.glob does not work on
-- Windows, so glob each extension separately
local function glob_scripts(pattern)
  local scripts = vim.fn.glob(pattern .. '.vim', false, true)
  return vim.list_extend(scripts, vim.fn.glob(pattern .. '.lua', false, true))
end

-- Callback for vim.pack.add's `load` option: vim.pack installs the plugin
-- and hands over {spec, path} without touching the runtimepath
function M.register(plug_data)
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

-- Source a pending plugin's ftdetect scripts so its filetypes are
-- detectable before the plugin is loaded (for FileType-driven modules)
function M.ftdetect(src)
  local entry = M.pending[src]
  if not entry then
    return
  end

  vim.cmd('augroup filetypedetect')
  for _, p in ipairs(glob_scripts(entry.path .. '/ftdetect/*')) do
    vim.cmd.source({ p, magic = { file = false } })
  end
  vim.cmd('augroup END')
end

-- Self-deleting command for plugins whose entry point is their own user
-- command: first invocation loads (call `load`, e.g. deps.lazy) and
-- re-executes against the real command
function M.cmd(name, load)
  vim.api.nvim_create_user_command(name, function(o)
    vim.api.nvim_del_user_command(name)
    load()
    vim.cmd({
      cmd = name,
      args = #o.fargs > 0 and o.fargs or nil,
      bang = o.bang,
      mods = o.smods,
    })
  end, { nargs = '*', bang = true })
end

return M
