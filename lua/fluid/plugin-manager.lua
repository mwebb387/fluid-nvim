local manager_path = "/site/pack/paqs/start/paq-nvim"
local manager_url = "https://github.com/savq/paq-nvim.git"

local M = {
  plugins = { "savq/paq-nvim" }
}

function M.bootstrap()
  -- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  local paqpath = vim.fn.stdpath("data") ..manager_path
  --if not vim.loop.fs_stat(lazypath) then
  if not vim.loop.fs_stat(paqpath) then
    print('Downloading plugin manager...')
    -- vim.fn.system({
    --   "git",
    --   "clone",
    --   "--filter=blob:none",
    --   "https://github.com/folke/lazy.nvim.git",
    --   "--branch=stable", -- latest stable release
    --   lazypath,
    -- })
    vim.fn.system({
      "git",
      "clone",
      "--depth=1",
      manager_url,
      paqpath
    })
    vim.cmd.packadd 'paq-nvim'
  end
  -- vim.opt.rtp:prepend(lazypath)
end

function M:add_plugin(plugin)
  table.insert(self.plugins, plugin)
end

function M:install_plugins(callback)
  local paq = require'paq'

  local augrp = vim.api.nvim_create_augroup('FluidSetup', {})
  vim.api.nvim_create_autocmd('User', {
    group = augrp,
    pattern = 'PaqDoneInstall',
    callback = callback
  })

  -- Install plugins
  paq(self.plugins)
  paq.install()
end

return M
