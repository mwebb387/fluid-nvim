local M = {}

function M:init()
  self:use('TheLazyCat00/termfile-nvim').providing('termfile')
end

function M:setup(deps)
  deps.termfile.setup({
    shell = 'nu.exe',
    restore = true,
    autosave = true,
    pattern = '*.term',
  })
end

return M
