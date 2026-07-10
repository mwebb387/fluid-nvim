local plugman = require'fluid.plugin-manager'
local lazyload = require'fluid.lazy'
local util = require'fluid.util'

local function resolve_deps(mod)
  local deps = {}
  for _, dep in ipairs(mod.dependencies) do
    deps[dep.name] = require(dep.package)
  end
  return deps
end

local function plugin_name(plugin)
  return plugin.name or plugin.src:match('([^/]+)$'):gsub('%.git$', '')
end

-- Create trigger stubs for a lazy module; the first trigger to fire loads
-- the module's plugins, tears down the other stubs, and runs setup()
local function wire_lazy_module(mod)
  local deleters = {}

  local function on_trigger()
    if mod._lazy_paths then
      return mod._lazy_paths
    end

    for _, del in ipairs(deleters) do
      del()
    end

    local paths = {}
    for _, plugin in ipairs(mod.plugins) do
      local name = plugin_name(plugin)
      local path = lazyload.path_of(name)
      if lazyload.load(name) then
        paths[#paths + 1] = path
      end
    end
    mod._lazy_paths = paths

    if mod.setup then
      mod:setup(resolve_deps(mod))
    end

    return paths
  end

  local triggers = mod.lazy_triggers
  if triggers.cmd then
    deleters[#deleters + 1] = lazyload.stub_cmd(triggers.cmd, on_trigger)
  end
  if triggers.event then
    deleters[#deleters + 1] = lazyload.stub_event(triggers.event, on_trigger)
  end
  if triggers.keys then
    deleters[#deleters + 1] = lazyload.stub_keys(triggers.keys, on_trigger)
  end
  if triggers.ft then
    -- Filetypes of unloaded plugins must be detectable for the stub to fire
    for _, plugin in ipairs(mod.plugins) do
      local path = lazyload.path_of(plugin_name(plugin))
      if path then
        lazyload.ftdetect(path)
      end
    end
    deleters[#deleters + 1] = lazyload.stub_ft(triggers.ft, on_trigger)
  end
end

local module_meta = {
  has = function(self, option)
    return util.find(
      self.options,
      function(opt)
        return opt == option
      end
    ) ~= nil
  end,

  -- Defer this module's plugins and setup() until a trigger fires:
  -- lazy{ cmd = 'Telescope', event = 'InsertEnter', ft = 'cs', keys = '<leader>x' }
  -- Each trigger accepts a single value or a list; keys entries may be
  -- {mode, lhs} tables (mode defaults to 'n').
  lazy = function(self, triggers)
    if type(triggers) ~= 'table' then
      error("lazy() expects a table of triggers: { cmd = ..., event = ..., ft = ..., keys = ... }", 2)
    end

    for kind, value in pairs(triggers) do
      if kind ~= 'cmd' and kind ~= 'event' and kind ~= 'ft' and kind ~= 'keys' then
        error("lazy(): unknown trigger '" .. tostring(kind) .. "' (expected cmd, event, ft, keys)", 2)
      end
      self.lazy_triggers[kind] = value
    end

    return self
  end,

  -- use('owner/repo' | 'url' | {src=..., version=...}) registers a plugin;
  -- use('lua.require.path') declares a dependency exposed in setup(deps);
  -- use({ spec, spec, ... }) registers a batch of plugins (not refinable).
  -- Chain refinements: .at(version), .providing(path), .as(alias)
  use = function(self, spec, extra)
    if extra ~= nil then
      error("use() takes a single spec; pass a list table to register multiple plugins", 2)
    end

    -- Batch list of plain plugin specs
    if type(spec) == 'table' and spec.src == nil then
      if spec[1] == nil or spec.version ~= nil or spec.branch ~= nil or spec.name ~= nil then
        error("fluid: invalid plugin spec — a table must be { src = ..., version = ... } or a list of specs", 2)
      end

      for _, plugin in ipairs(spec) do
        table.insert(self.plugins, plugman:add_plugin(plugin))
      end

      local sealed = {}
      local function no_refine(name)
        return function()
          error(name .. "() cannot refine a multi-plugin use(); call use() once per plugin to chain", 2)
        end
      end
      sealed.at = no_refine('at')
      sealed.providing = no_refine('providing')
      sealed.as = no_refine('as')

      setmetatable(sealed, { __index = self })

      return sealed
    end

    local plugin = nil
    local dep = nil

    if type(spec) == 'string' and not spec:find('/', 1, true) then
      -- No slash: a require path, not a plugin source
      dep = { package = spec, name = spec }
      table.insert(self.dependencies, dep)
    else
      plugin = plugman:add_plugin(spec)
      table.insert(self.plugins, plugin)
    end

    local chain = {}

    function chain.at(version)
      if not plugin then
        error("at() only applies to plugin specs; '" .. tostring(spec) .. "' is a dependency", 2)
      end
      plugin.version = version
      return chain
    end

    function chain.providing(path)
      if not plugin then
        error("providing() only applies to plugin specs; chain .as(...) to alias the dependency instead", 2)
      end
      dep = { package = path, name = path }
      table.insert(self.dependencies, dep)
      return chain
    end

    function chain.as(alias)
      if not dep then
        error("as() requires a dependency; call providing() first", 2)
      end
      dep.name = alias
      return chain
    end

    setmetatable(chain, { __index = self })

    return chain
  end,
}

local function create_fluid_module(m, name)
  -- print('Loading module ' .. name)
  if not m.name then
    m.name = name
  end

  if not m.options then
    -- print('Adding empty options list...')
    m.options = {}
  end

  if not m.dependencies then
    -- print('Adding empty dependencies list...')
    m.dependencies = {}
  end

  if not m.plugins then
    m.plugins = {}
  end

  if not m.lazy_triggers then
    m.lazy_triggers = {}
  end

  -- print('Metatable: ')
  -- vim.pretty_print(getmetatable(m))

  if not getmetatable(m) then
    -- print('Setting metatable...')
    setmetatable(m, {__index = module_meta})
  end

  return m
end

local M = {
  config = {
    modules = {},
  },
  current_module = {},

  module = function(self, name)
    for _, mod in ipairs(self.config.modules) do
      if mod.name == name then
        self.current_module = mod
        return self
      end
    end

    self.current_module = create_fluid_module(require('fluid.modules.' .. name), name)
    table.insert(self.config.modules, self.current_module)
    return self
  end,

  option = function(self, optName)
    table.insert(self.current_module.options, optName)
    return self
  end,

  options = function(self, ...)
    for _, opt in ipairs({...}) do
      self:option(opt)
    end

    return self
  end,

  -- Make the current module lazy from user config: f:telescope():lazy{ cmd = 'Telescope' }
  lazy = function(self, triggers)
    if not self.current_module.lazy_triggers then
      error("lazy() requires a module; register one first (e.g. f:telescope():lazy{...})", 2)
    end

    module_meta.lazy(self.current_module, triggers)
    return self
  end,

  -- For debugging
  reset = function(self)
    self.config = {
      modules = {},
    }
    self.current_module = {}

    return self
  end,

  setup = function(self, config)
    local nvim = require('fluid.nvim')

    -- Handle custom config (if supplied)
    if config and type(config) == 'function' then
      config(self, nvim)
    elseif config and type(config) == 'table' and config.init and type(config.init) == 'function' then
      config.init(self, nvim)
    end

    -- Run module init methods
    for _, mod in ipairs(self.config.modules) do
      if mod.init then
        mod:init(self)
      end
    end

    -- Mark plugins belonging to lazy modules; a plugin shared with an
    -- eager module must stay eager
    for _, mod in ipairs(self.config.modules) do
      if next(mod.lazy_triggers) ~= nil then
        for _, plugin in ipairs(mod.plugins) do
          plugin.data = plugin.data or {}
          plugin.data.fluid_lazy = true
        end
      end
    end
    for _, mod in ipairs(self.config.modules) do
      if next(mod.lazy_triggers) == nil then
        for _, plugin in ipairs(mod.plugins) do
          if plugin.data then
            plugin.data.fluid_lazy = nil
          end
        end
      end
    end

    -- Install plugins
    plugman:install_plugins(function()
      -- Wire lazy modules to their triggers; set up eager modules now
      for _, mod in ipairs(self.config.modules) do
        if next(mod.lazy_triggers) ~= nil then
          wire_lazy_module(mod)
        elseif mod.setup then
          mod:setup(resolve_deps(mod))
        end
      end
    end)

  end
}

-- Type checking
local fluid_meta = {
  __index = function(self, mod)
    return function(first, ...)
      self:module(mod)

      local args = { ... }
      -- Support both colon and dot call syntax
      if first ~= nil and first ~= self then
        table.insert(args, 1, first)
      end

      for _, arg in ipairs(args) do
        if type(arg) == 'table' then
          self.current_module.config =
            vim.tbl_deep_extend('force', self.current_module.config or {}, arg)
        else
          self:option(arg)
        end
      end

      return self
    end
  end,

  __add = function(self, mod)
    return self:option(mod)
  end,

  __mod = function(self, mod)
    return self:module(mod)
  end,

  __div = function(self, mod)
    return self:module(mod)
  end,

  __mul = function(self, opt)
    return self:option(opt)
  end,

  __tostring = function(self)
    return vim.inspect(self.config)
  end
}

setmetatable(M, fluid_meta)

return M
