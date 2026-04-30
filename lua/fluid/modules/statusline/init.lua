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

function M:init(fluid)
  -- print('init for statusline')

  fluid:fluidline()
  self:depends_on('fluid.modules.fluidline').as('fluidline')
end

function M:setup(deps)
  -- local opt = h.option

  vim.opt.laststatus = 3

  _G.SLCodecompanion = function()
    if vim.g.codecompanion_status == nil then
        return ''
    end

    local fl = deps.fluidline:new()
    fl:highlight 'DiagnosticInfo'
        :append ' 󰒆 '

    if vim.g.codecompanion_status == 'started' then
      fl:append ' '
    else
      fl:append '  '
    end

    return tostring(fl)
  end

  _G.SLMinuet = function()
    if vim.g.minuet_mode == nil then
        return ''
    end

    local fl = deps.fluidline:new()
    if vim.g.minuet_mode == 'Fast' then
      fl:highlight 'DiagnosticInfo'
        :append ' 󰒆 '
    else -- Smart
      fl:highlight 'DiagnosticHint'
        :append ' 󰧑 '
    end

    if vim.g.minuet_status == 'started' then
      fl:append ' '
    else
      fl:append '  '
    end

    return tostring(fl)
  end


  _G.SLSpell = function()
    local fl = deps.fluidline:new()

    if vim.o.spell then
      return tostring(fl
          :highlight 'Error'
          :append ' 󰓆 ')
    end

    return tostring(fl
        :highlight 'NonText'
        :append ' 󰓆 ')
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

    local clients = vim.lsp.get_clients({bufnr = 0})

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
    -- :format_lua 'SLMinuet'
    :format_lua 'SLCodecompanion'

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
