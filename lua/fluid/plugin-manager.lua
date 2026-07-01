local  gh = function(x) return 'https://github.com/' .. x end

local M = {
  plugins = {
    -- TODO: Make sure we want/need these as defaults always
    { src = gh('nvim-lua/popup.nvim') },
    { src = gh('nvim-lua/plenary.nvim') }
  }
}

function M:add_plugin(plugin)
  -- detect of 'plugin' is a string or a table
  if type(plugin) == 'string' then
    plugin = { src = plugin }
  end

  local prefix = 'https'
  if string.sub(plugin.src, 1, #prefix) ~= prefix then
    plugin.src = gh(plugin.src)
  end

  table.insert(self.plugins, plugin)
end

function M:install_plugins(callback)
  vim.pack.add(self.plugins)
  callback()
end

return M
