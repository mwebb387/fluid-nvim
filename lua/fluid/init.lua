local plugman = require'fluid.plugin-manager'
local util = require'fluid.util'

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
        plugman:add_plugin(plugin)
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

    -- Install plugins
    plugman:install_plugins(function()
      -- Run module setup methods
      for _, mod in ipairs(self.config.modules) do
        if mod.setup then
          local deps = {}
          for _, dep in ipairs(mod.dependencies) do
            -- TODO: what if this is a plugin
            deps[dep.name] = require(dep.package)
          end

          mod:setup(deps)
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
