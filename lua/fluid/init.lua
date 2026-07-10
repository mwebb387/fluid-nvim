local plugman = require'fluid.plugin-manager'
local lazyload = require'fluid.lazy'
local util = require'fluid.util'

-- deps.lazy — a module-bound auto-loader. Indexing it loads the module's
-- opt() plugins once (native :packadd via fluid.lazy), runs the module's
-- optional lazy_setup(deps), then requires and returns the named module:
--   deps.lazy.telescope        -> require('telescope')
--   deps.lazy.actions          -> require('telescope.actions')  (via providing().as())
-- Calling it just ensures everything is loaded: deps.lazy(), or wraps a
-- callback: deps.lazy(fn) -> function that loads first, then runs fn.
local function make_lazy(mod, deps)
  local function ensure()
    if not mod._opt_loaded then
      mod._opt_loaded = true

      for _, meta in ipairs(mod.plugins) do
        if meta.opt then
          lazyload.load(meta.plugin.src)
        end
      end

      if mod.lazy_setup then
        mod:lazy_setup(deps)
      end
    end
  end

  return setmetatable({}, {
    __index = function(_, key)
      ensure()
      return require(mod.lazy_provides[key] or key)
    end,

    __call = function(_, fn)
      if fn ~= nil then
        return function(...)
          ensure()
          return fn(...)
        end
      end
      ensure()
    end,
  })
end

local function resolve_deps(mod)
  local deps = {}
  for _, dep in ipairs(mod.dependencies) do
    deps[dep.name] = require(dep.package)
  end
  deps.lazy = make_lazy(mod, deps)
  return deps
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

  -- use('owner/repo' | 'url' | {src=..., version=...}) registers a plugin;
  -- use('lua.require.path') declares a dependency exposed in setup(deps);
  -- use({ spec, spec, ... }) registers a batch of plugins (not refinable).
  -- Chain refinements: .at(version), .opt(), .providing(path), .as(alias)
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
      sealed.opt = no_refine('opt')

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

    -- Install this plugin at startup but do not load it; the module loads
    -- it on demand via deps.lazy in setup(). providing() paths of an opt
    -- plugin become deps.lazy keys instead of eager setup(deps) entries.
    function chain.opt()
      if not plugin then
        error("opt() only applies to plugin specs", 2)
      end
      meta.opt = true
      return chain
    end

    function chain.providing(path)
      if not plugin then
        error("providing() only applies to plugin specs; chain .as(...) to alias the dependency instead", 2)
      end
      -- meta links the dep to its plugin: provides of opt() plugins are
      -- relocated to deps.lazy at setup time
      dep = { package = path, name = path, provided = true, meta = meta }
      table.insert(self.dependencies, dep)
      table.insert(meta.provides, path)
      return chain
    end

    -- Rename the most recent dependency; directly after a plugin spec,
    -- set the plugin's install dir name (vim.pack's `name` field), which
    -- doubles as its deps.lazy key when it matches the require path
    function chain.as(alias)
      if dep then
        dep.name = alias
      elseif plugin then
        plugin.name = alias
      else
        error("as() requires a dependency or plugin spec", 2)
      end
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

  if not m.lazy_provides then
    m.lazy_provides = {}
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

    -- A plugin is lazy only when every module claiming it marked it opt();
    -- one eager claim keeps it eager. Provides of opt plugins move out of
    -- the eager dependencies into the module's deps.lazy registry.
    local lazy_claims, eager_claims = {}, {}
    for _, mod in ipairs(self.config.modules) do
      for _, meta in ipairs(mod.plugins) do
        if meta.opt then
          lazy_claims[meta.plugin] = true
        else
          eager_claims[meta.plugin] = true
        end
      end

      local i = 1
      while i <= #mod.dependencies do
        local dep = mod.dependencies[i]
        if dep.meta and dep.meta.opt then
          mod.lazy_provides[dep.name] = dep.package
          table.remove(mod.dependencies, i)
        else
          i = i + 1
        end
      end
    end
    for plugin in pairs(lazy_claims) do
      if not eager_claims[plugin] then
        plugin.data = plugin.data or {}
        plugin.data.fluid_lazy = true
      end
    end

    -- Install plugins (opt() plugins install but stay unloaded)
    plugman:install_plugins(function()
      -- Run module setup methods
      for _, mod in ipairs(self.config.modules) do
        if mod.setup then
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
