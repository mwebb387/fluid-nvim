local gh = function(x) return 'https://github.com/' .. x end

-- Sources that must not be rewritten to a GitHub URL: full URLs of any
-- protocol, scp-style git addresses, and local paths
local function is_explicit_source(src)
  return src:find('://', 1, true) ~= nil
    or src:match('^git@') ~= nil
    or src:match('^[~/]') ~= nil
    or src:match('^%a:[/\\]') ~= nil
end

local M = {
  plugins = {
    -- TODO: Make sure we want/need these as defaults always
    { src = gh('nvim-lua/popup.nvim') },
    { src = gh('nvim-lua/plenary.nvim') }
  }
}

function M:add_plugin(plugin)
  if type(plugin) == 'string' then
    plugin = { src = plugin }
  end

  if type(plugin) ~= 'table' or type(plugin.src) ~= 'string' then
    error("fluid: invalid plugin spec — expected an 'owner/repo' string, a URL, or a table with a src field", 2)
  end

  if not is_explicit_source(plugin.src) then
    plugin.src = gh(plugin.src)
  end

  -- Modules may register the same plugin; keep one spec per src so vim.pack
  -- does not reject the list, and merge refinements into the first spec
  for _, existing in ipairs(self.plugins) do
    if existing.src == plugin.src then
      existing.version = existing.version or plugin.version
      existing.name = existing.name or plugin.name
      return existing
    end
  end

  table.insert(self.plugins, plugin)
  return plugin
end

function M:install_plugins(callback)
  vim.pack.add(self.plugins)
  callback()
end

return M
