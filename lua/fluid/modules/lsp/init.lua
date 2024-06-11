local util = require'fluid.util'

local M = {
  servers = {}
}

-- cfg should be in the following format {
--  name = "server name",
--  version = "serverCmd --version",
--  install = "npm install -g server-name",
--  update = "npm upgrade -g server-name",
--  remove = "npm uninstall -g server-name",
-- }

-- cfg should be in the following format {
--  name = "server name",
--  package = "package name"
--  manager = nil|'node'
-- }
function M:addServerConfig(cfg)
  table.insert(self.servers, cfg)
end

function M:findServer(name)
  return util.find(self.servers, function(svr) return svr.name == name end)
end

function M:getServerNames()
  local names = {}
  for _, value in ipairs(self.servers) do
    if (value.name) then table.insert(names, value.name) end
  end
  return names
end

function M:installServer(name, syspackman)
  if name == 'all' then
    for _, value in ipairs(self.servers) do
      syspackman:install(value.package, value.manager)
    end
  else
    local server = self:findServer(name)
    if (server ~= nil) then
      syspackman:install(server.package, server.manager)
    end
  end
end

function M:updateServer(name, syspackman)
  if name == 'all' then
    for _, value in ipairs(self.servers) do
      syspackman:update(value.package, value.manager)
    end
  else
    local server = self:findServer(name)
    if (server ~= nil) then
      syspackman:update(server.package, server.manager)
    end
  end
end

function M:removeServer(name, syspackman)
  if name == 'all' then
    for _, value in ipairs(self.servers) do
      syspackman:remove(value.package, value.manager)
    end
  else
    local server = self:findServer(name)
    if (server ~= nil) then
      syspackman:remove(server.package, server.manager)
    end
  end
end

function M:init(fluid)
  self:use('neovim/nvim-lspconfig')
  self:depends_on('fluid.nvim').as('nvim')

  if self:has('server_management') then
    fluid:syspackman() -- make sure system package manager is loaded
    self:depends_on('fluid.modules.syspackman').as('syspackman')
  end
end

function M:setup(deps)
  if self:has('icons') then
    vim.fn.sign_define('DiagnosticSignError', {text = '', texthl = 'DiagnosticSignError'})
    vim.fn.sign_define('DiagnosticSignHint', {text = '', texthl = 'DiagnosticSignHint'})
    vim.fn.sign_define('DiagnosticSignInfo', {text = '', texthl = 'DiagnosticSignInfo'})
    vim.fn.sign_define('DiagnosticSignWarn', {text = '', texthl = 'DiagnosticSignWarn'})
  end

  if self:has('server_management') then
    local autoCompleteOpts = function()
      local names = self:getServerNames()
      table.insert(names, 1, 'all')
      return names
    end

    deps.nvim
      :command('FluidInstallLanguageServer', function(input)
        self:installServer(input.args or 'all', deps.syspackman)
      end, {nargs = 1, complete = autoCompleteOpts})

      :command('FluidUpdateLanguageServer', function(input)
        self:updateServer(input.args or 'all', deps.syspackman)
      end, {nargs = 1, complete = autoCompleteOpts})

      :command('FluidRemoveLanguageServer', function(input)
        self:removeServer(input.args or 'all', deps.syspackman)
      end, {nargs = 1, complete = autoCompleteOpts})

      :command('FluidListLanguageServers', function()
        vim.print(self:getServerNames())
      end, {nargs = 0})
  end
end

return M
