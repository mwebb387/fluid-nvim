local M = {
  config = {
    compiler = "gcc",
    ensure_installed = {'c_sharp'},
  }
}

function M:ensure_installed(lang)
  table.insert(self.config.ensure_installed, lang)
  return self
end

function M:init()
  self:use('arborist-ts/arborist.nvim').opt().providing('arborist')
  self:use('fluid.nvim').as('nvim')

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
  deps.nvim:autocmd('VimEnter', {
    callback = function()
      deps.lazy.arborist.setup(self.config)
    end
  })
end

return M
