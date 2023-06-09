local plugman = require'fluid.plugin-manager'

local function find(list, fn)
  for _, opt in ipairs(list) do
    if fn(opt) then
      return opt
    end
  end
  return nil
end

local module_meta = {
  has = function(self, option)
    return find(
      self.options,
      function(opt)
        return opt == option
      end
    ) ~= nil
  end,

  depends_on = function(self, dep)
    local dependency = {
      package = dep,
      name = dep,
    }

    table.insert(self.dependencies, dependency)

    -- TODO: Are there other dep types?
    local depends_api = {}
    function depends_api.from(plugin_spec)
      plugman:add_plugin(plugin_spec)
      return depends_api
    end
    function depends_api.as(name)
      dependency.name = name
      return depends_api
    end

    setmetatable(depends_api, { __index = self })

    return depends_api
  end,

  use = function(self, ...)
    for _, plugin in ipairs({...}) do
      plugman:add_plugin(plugin)
    end

    return self
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
    for _, mod in ipairs(self.config) do
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
    -- Bootstrap the plugin manager
    plugman.bootstrap()

    -- Handle custom config (if supplied)
    if config and type(config) == 'function' then
      config(self)
    elseif config and type(config) == 'table' and config.init and type(config.init) == 'function' then
      config.init(self)
    end

    -- Setup base config
    local nvim = require('fluid.nvim')
    require('fluid.config-default').setup(nvim)

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
    return function()
      return self:module(mod)
    end
  end,

  __add = function(self, mod)
    return self:module(mod)
  end,

  __sub = function(self, opt)
    return self:option(opt)
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
