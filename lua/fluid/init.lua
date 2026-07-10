local plugman = require'fluid.plugin-manager'
local lazyload = require'fluid.lazy'
local util = require'fluid.util'

-- A dep owned by a not-yet-loaded lazy plugin resolves to a proxy: first
-- access requires the real module, which trips the require-loader and loads
-- the plugin. Untouched deps leave the plugin lazy.
local function lazy_dep_proxy(package)
  local real
  local function resolve()
    if real == nil then
      real = require(package)
    end
    return real
  end

  return setmetatable({}, {
    __index = function(_, k) return resolve()[k] end,
    __newindex = function(_, k, v) resolve()[k] = v end,
    __call = function(_, ...) return resolve()(...) end,
  })
end

local function resolve_deps(mod)
  local deps = {}
  for _, dep in ipairs(mod.dependencies) do
    local meta = dep.meta
    if meta and meta.triggers and not meta._lazy_paths and next(mod.lazy_triggers) == nil then
      deps[dep.name] = lazy_dep_proxy(dep.package)
    else
      deps[dep.name] = require(dep.package)
    end
  end
  return deps
end

local function validate_triggers(triggers, where)
  if type(triggers) ~= 'table' then
    error(where .. " expects a table of triggers: { cmd = ..., event = ..., ft = ..., keys = ..., require = ... }", 3)
  end
  for kind in pairs(triggers) do
    if kind ~= 'cmd' and kind ~= 'event' and kind ~= 'ft' and kind ~= 'keys' and kind ~= 'require' then
      error(where .. ": unknown trigger '" .. tostring(kind) .. "' (expected cmd, event, ft, keys, require)", 3)
    end
  end
end

-- Run a plugin's stored config function: fn(module, <provided modules...>)
local function run_plugin_config(mod, meta)
  local fn = mod.configs[meta.key]
  if not fn then
    return
  end

  local provided = {}
  for i, path in ipairs(meta.provides) do
    provided[i] = require(path)
  end

  fn(mod, unpack(provided))
end

local function wire_triggers(triggers, on_trigger, deleters, ft_paths)
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
    for _, path in ipairs(ft_paths()) do
      lazyload.ftdetect(path)
    end
    deleters[#deleters + 1] = lazyload.stub_ft(triggers.ft, on_trigger)
  end
  -- 'require' needs no stub: the package.loaders hook is always active
end

-- Create trigger stubs for a lazy module; the first trigger to fire loads
-- the module's plugins, tears down the other stubs, runs plugin configs,
-- and then setup()
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
    for _, meta in ipairs(mod.plugins) do
      local path = lazyload.path_of(meta.plugin.src)
      if lazyload.load(meta.plugin.src) then
        paths[#paths + 1] = path
      end
    end
    mod._lazy_paths = paths

    for _, meta in ipairs(mod.plugins) do
      run_plugin_config(mod, meta)
    end

    if mod.setup then
      mod:setup(resolve_deps(mod))
    end

    return paths
  end

  -- Requiring any lua module this module provides (or any lua module found
  -- inside its pending plugins) also triggers the full load
  for _, dep in ipairs(mod.dependencies) do
    if dep.provided then
      lazyload.require_map[dep.package] = on_trigger
    end
  end
  for _, meta in ipairs(mod.plugins) do
    lazyload.owners[meta.plugin.src] = on_trigger
  end

  wire_triggers(mod.lazy_triggers, on_trigger, deleters, function()
    local paths = {}
    for _, meta in ipairs(mod.plugins) do
      paths[#paths + 1] = lazyload.path_of(meta.plugin.src)
    end
    return paths
  end)
end

-- Create trigger stubs for a single lazy plugin inside an eager module;
-- the trigger loads just that plugin and runs its stored config
local function wire_lazy_plugin(mod, meta)
  local deleters = {}

  local function on_trigger()
    if meta._lazy_paths then
      return meta._lazy_paths
    end

    for _, del in ipairs(deleters) do
      del()
    end

    local path = lazyload.path_of(meta.plugin.src)
    meta._lazy_paths = lazyload.load(meta.plugin.src) and { path } or {}

    run_plugin_config(mod, meta)

    return meta._lazy_paths
  end

  for _, path in ipairs(meta.provides) do
    lazyload.require_map[path] = on_trigger
  end
  lazyload.owners[meta.plugin.src] = on_trigger

  wire_triggers(meta.triggers, on_trigger, deleters, function()
    return { lazyload.path_of(meta.plugin.src) }
  end)
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
    validate_triggers(triggers, 'lazy()')

    for kind, value in pairs(triggers) do
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
        table.insert(self.plugins, {
          plugin = plugman:add_plugin(plugin),
          key = type(plugin) == 'string' and plugin or plugin.src,
          provides = {},
        })
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
      sealed.on = no_refine('on')
      sealed.configure = no_refine('configure')

      setmetatable(sealed, { __index = self })

      return sealed
    end

    local plugin = nil
    local dep = nil
    local meta = nil

    if type(spec) == 'string' and not spec:find('/', 1, true) then
      -- No slash: a require path, not a plugin source
      dep = { package = spec, name = spec }
      table.insert(self.dependencies, dep)
    else
      plugin = plugman:add_plugin(spec)
      meta = {
        plugin = plugin,
        key = type(spec) == 'string' and spec or spec.src,
        provides = {},
      }
      table.insert(self.plugins, meta)
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
      -- provided marks the require path as owned by this module's plugin,
      -- which feeds require-triggered lazy loading; meta links the dep to
      -- its plugin so deps resolution can defer it while the plugin is lazy
      dep = { package = path, name = path, provided = true, meta = meta }
      table.insert(self.dependencies, dep)
      table.insert(meta.provides, path)
      return chain
    end

    -- Defer loading this one plugin until a trigger fires; same trigger
    -- table as lazy(). Ignored when the whole module is lazy.
    function chain.on(triggers)
      if not plugin then
        error("on() only applies to plugin specs", 2)
      end
      validate_triggers(triggers, 'on()')
      meta.triggers = triggers
      return chain
    end

    -- Store a config function for this plugin on the module's table
    -- (self.configs, keyed by the spec as written). Runs after the plugin
    -- loads: fn(module, <providing() modules in order>).
    -- Named configure (not config) so chained module methods still see the
    -- module's config table through the chain.
    function chain.configure(fn)
      if not plugin then
        error("configure() only applies to plugin specs", 2)
      end
      if type(fn) ~= 'function' then
        error("configure() expects a function", 2)
      end
      self.configs[meta.key] = fn
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

  if not m.configs then
    m.configs = {}
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

    -- A plugin is lazy when every module claiming it wants it lazy — via a
    -- lazy module (lazy()) or a per-plugin trigger (on()); one eager claim
    -- keeps it eager
    local lazy_claims, eager_claims = {}, {}
    for _, mod in ipairs(self.config.modules) do
      local mod_lazy = next(mod.lazy_triggers) ~= nil
      for _, meta in ipairs(mod.plugins) do
        if mod_lazy or meta.triggers then
          lazy_claims[meta.plugin] = true
        else
          eager_claims[meta.plugin] = true
        end
      end
    end
    for plugin in pairs(lazy_claims) do
      if not eager_claims[plugin] then
        plugin.data = plugin.data or {}
        plugin.data.fluid_lazy = true
      end
    end

    -- Install plugins
    plugman:install_plugins(function()
      -- Wire lazy modules to their triggers; set up eager modules now.
      -- Inside an eager module, on()-marked plugins get their own triggers
      -- (wired before setup so requires during setup resolve), and eager
      -- plugin configs run before the module's setup.
      for _, mod in ipairs(self.config.modules) do
        if next(mod.lazy_triggers) ~= nil then
          wire_lazy_module(mod)
        else
          for _, meta in ipairs(mod.plugins) do
            if meta.triggers then
              wire_lazy_plugin(mod, meta)
            end
          end

          for _, meta in ipairs(mod.plugins) do
            if not meta.triggers then
              run_plugin_config(mod, meta)
            end
          end

          if mod.setup then
            mod:setup(resolve_deps(mod))
          end
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
