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

function M:installServer(name)
  if name == 'all' then
    for _, value in ipairs(self.servers) do
      vim.system(value.install)
    end
  else
    local server = self:findServer(name)
    if (server ~= nil) then
      vim.system(server.install)
    end
  end
end

function M:updateServer(name)
  if name == 'all' then
    for _, value in ipairs(self.servers) do
      vim.system(value.update)
    end
  else
    local server = self:findServer(name)
    if (server ~= nil) then
      vim.system(server.update)
    end
  end
end

function M:removeServer(name)
  if name == 'all' then
    for _, value in ipairs(self.servers) do
      vim.system(value.remove)
    end
  else
    local server = self:findServer(name)
    if (server ~= nil) then
      vim.system(server.remove)
    end
  end
end

function M:init()
  self:use('neovim/nvim-lspconfig')
  self:depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  if self:has('icons') then
    vim.fn.sign_define('DiagnosticSignError', {text = '', texthl = 'DiagnosticSignError'})
    vim.fn.sign_define('DiagnosticSignHint', {text = '', texthl = 'DiagnosticSignHint'})
    vim.fn.sign_define('DiagnosticSignInfo', {text = '', texthl = 'DiagnosticSignInfo'})
    vim.fn.sign_define('DiagnosticSignWarn', {text = '', texthl = 'DiagnosticSignWarn'})
  end

  local autoCompleteOpts = function()
    local names = self:getServerNames()
    table.insert(names, 1, 'all')
    return names
  end

  deps.nvim
    :command('FluidInstallLanguageServer', function(input)
      self:installServer(input.args or 'all')
    end, {nargs = 1, complete = autoCompleteOpts})

    :command('FluidUpdateLanguageServer', function(input)
      self:updateServer(input.args or 'all')
    end, {nargs = 1, complete = autoCompleteOpts})

    :command('FluidRemoveLanguageServer', function(input)
      self:removeServer(input.args or 'all')
    end, {nargs = 1, complete = autoCompleteOpts})

    :command('FluidListLanguageServers', function()
      vim.print(self:getServerNames())
    end, {nargs = 0})
end

return M
