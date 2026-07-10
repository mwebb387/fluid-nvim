local M = {
  config = {}
}

-- Named managers, always available explicitly via e.g. install('pkg', 'winget')
local default_managers = {
  winget = {
    cmd = 'winget',
    install = 'install',
    update = 'upgrade',
    remove = 'uninstall'
  },
  scoop = {
    cmd = 'scoop',
    install = 'install',
    update = 'update',
    remove = 'uninstall'
  },
  homebrew = {
    cmd = 'brew',
    install = 'install',
    update = 'upgrade',
    remove = 'uninstall'
  },
  apt = {
    cmd = 'sudo apt',
    install = 'install',
    update = 'upgrade',
    remove = 'remove'
  },
  pacman = {
    cmd = 'pacman',
    install = '-S',
    update = '-Syu',
    remove = '-R'
  },
  node = {
    cmd = 'npm',
    install = 'install -g',
    update = 'upgrade -g',
    remove = 'uninstall -g'
  },
  dotnet = {
    cmd = 'dotnet tool',
    install = 'install --global',
    update = 'update --global',
    remove = 'uninstall --global'
  },
}

local function run_cmd(cmd)
  -- vim.print('Running ' .. cmd)
  local handle = io.popen(cmd)

  if handle == nil then
    return
  end

  local result = handle:read('*a')
  handle:close()
  print(result)
end

function M:manager(manager_name)
  if manager_name and #manager_name > 0 then
    return self.config[manager_name]
  end

  return self.config.sys
end

function M:install(args, manager_name)
  local man = self:manager(manager_name)

  if not man then
    vim.notify('syspackman: unknown package manager "' .. (manager_name or 'sys') .. '"', vim.log.levels.ERROR)
    return
  end

  run_cmd(man.cmd .. ' ' .. man.install .. ' ' .. args)
end

function M:update(args, manager_name)
  local man = self:manager(manager_name)

  if not man then
    vim.notify('syspackman: unknown package manager "' .. (manager_name or 'sys') .. '"', vim.log.levels.ERROR)
    return
  end

  run_cmd(man.cmd .. ' ' .. man.update .. ' ' .. args)
end

function M:uninstall(args, manager_name)
  local man = self:manager(manager_name)

  if not man then
    vim.notify('syspackman: unknown package manager "' .. (manager_name or 'sys') .. '"', vim.log.levels.ERROR)
    return
  end

  run_cmd(man.cmd .. ' ' .. man.remove .. ' ' .. args)
end

function M:init()
  for name, man in pairs(default_managers) do
    if not self.config[name] then
      self.config[name] = man
    end
  end

  -- Respect a system manager supplied via config, e.g. f:syspackman({ sys = {...} })
  if not self.config.sys then
    if vim.fn.has('win32') == 1 then
      if self:has('scoop') and not self:has('winget') then
        self.config.sys = self.config.scoop
      else
        self.config.sys = self.config.winget
      end
    elseif vim.fn.has('mac') == 1 then
      self.config.sys = self.config.homebrew
    elseif vim.fn.has('linux') == 1 then
      if self:has('pacman') then
        self.config.sys = self.config.pacman
      elseif self:has('homebrew') then
        self.config.sys = self.config.homebrew
      else
        self.config.sys = self.config.apt
      end
    end
  end

  -- TODO: PIP?
  -- TODO: Lua Rocks?
end

function M:setup() -- deps) -- ?
  -- TODO: Add methods and data for installing system packages...
end

return M
