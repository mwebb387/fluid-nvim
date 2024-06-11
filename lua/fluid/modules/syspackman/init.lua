local M = {
  config = {}
}

function M:install(args, manager_name)
  local man = self.config.sys

  if manager_name then
    man = self.config[manager_name]
  end

  vim.system(man.cmd .. ' ' .. man.install .. ' ' .. args)
end

function M:update(args, manager_name)
  local man = self.config.sys

  if manager_name then
    man = self.config[manager_name]
  end

  vim.system(man.cmd .. ' ' .. man.update .. ' ' .. args)
end

function M:uninstall(args, manager_name)
  local man = self.config.sys

  if manager_name then
    man = self.config[manager_name]
  end

  vim.system(man.cmd .. ' ' .. man.uninstall .. ' ' .. args)
end

function M:init()
  if vim.has('win32') then
    self.config.sys = {
      cmd = 'winget',
      install = 'install',
      update = 'upgrade',
      remove = 'uninstall'
    }

    if self:has('scoop') then
      self.config.sys.cmd = 'scoop'
      self.config.sys.update = 'update'
    end
  end

  if self:has('node') then
    self.config.node = {
      cmd = 'npm',
      install = 'install -g',
      update = 'upgrade - g',
      remove = 'uninstall -g'
    }
  end

  -- TODO: PIP?
  -- TODO: Lua Rocks?
end

function M:setup() -- deps) -- ?
  -- TODO: Add methods and data for installing system packages...
end

return M
