local M = {
  config = {
    compiler = "gcc",
    ensure_installed = {'c_sharp'},
  }
}

function M:init()
  self:depends_on('arborist').from('arborist-ts/arborist.nvim')

  -- Get ensured languages
  for _, op in ipairs(self.options) do
    local _, e = string.find(op, 'lang:')
    if e then
      local lang = string.sub(op, e + 1)
      self:ensure_installed(lang)
    end
  end
end

function M:setup(deps)
  deps.arborist.setup(self.config)
end

return M
