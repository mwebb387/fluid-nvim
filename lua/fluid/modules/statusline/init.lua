--[[
-- {
-- name = 'name',
-- config = {},
-- options = function(...) end
--
-- option = function(name, function() end)
-- }
--]]

local M = {}

function M:init()
  -- print('init for statusline')

  self:depends_on('fluidline')
end

function M:setup(deps)
  -- local opt = h.option

  -- opt:set('laststatus', 3)
  vim.opt.laststatus = 3

  _G.SLSpell = function()
    local fl = deps.fluidline:new()

    if vim.o.spell then
      return tostring(fl
          :highlight 'Error'
          :append ' 暈 ')
    end

    return tostring(fl
        :highlight 'NonText'
        :append ' 暈 ')
  end

  _G.SLGitBranch = function()
    local fl = deps.fluidline:new()

    if vim.b.gitsigns_head and vim.b.gitsigns_head ~= '' then
      return tostring(fl
        :highlight 'Keyword'
        :append('  ' .. vim.b.gitsigns_head .. ' '))
    end

    return tostring(fl
      :highlight 'NonText'
      :append '  ')
  end

  _G.SLLSPServer = function()
    local fl = deps.fluidline:new()

    local clients = vim.lsp.buf_get_clients()

    if clients and #clients > 0 then
      local clientNames = {}
      for _, c in ipairs(clients) do
        table.insert(clientNames, c.name)
      end

      return tostring(fl
        :highlight 'Type'
        :append('   ' .. table.concat(clientNames, ', ')))
    end

    return tostring(fl
      :highlight 'NonText'
      :append '   ')
  end

  vim.o.statusline = tostring(deps.fluidline
    :new()
    :highlight 'String'
    :append '  '
    :filetype()
    :flag_preview()
    :flag_quickfix()
    :flag_modified()
    :flag_readonly()

    :highlight 'Constant'
    :append '  buffer '
    :buffer_number()

    :separator()
    :format_lua 'SLSpell'
    :format_lua 'SLLSPServer'
    :format_lua 'SLGitBranch'

    :separator()
    :highlight 'Type'
    :append '  '
    :current_line()
    :append ':'
    :current_column()
    :append ' | '
    :visible_percent()
    :append '  '
  )
end

return M
