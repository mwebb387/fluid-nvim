-- Helper methods for highlights
local function get_hi_attr(hi, attr)
  return vim.fn.synIDattr(vim.fn.hlID(hi), attr)
end

local function def_hi_rev(hi)
  local hi_rev = (hi .. "_Reverse")
  local fg = get_hi_attr(hi, "fg")
  local bg = "black"
  vim.api.nvim_set_hl(0, hi_rev, {fg = bg, bg = fg})
  return hi_rev
end

local function def_hi(hi) -- TODO: must be table; assert?
  if (hi.reverse) then
    return def_hi_rev(hi.name)
  end
  return hi.name
end

local function def_hi_fg_bg(hi_fg, hi_bg) -- TODO: must be tables; assert?
  local hi_fg_name = def_hi(hi_fg)
  local hi_bg_name = def_hi(hi_bg)
  local hi_fg_bg_name = (hi_fg_name .. "_" .. hi_bg_name)
  local fg = get_hi_attr(hi_fg.name, "fg")
  local bg = get_hi_attr(hi_bg.name, "bg")
  vim.api.nvim_set_hl(0, hi_fg_bg_name, {fg = fg, bg = bg})
  return hi_fg_bg_name
end

local M = {
  __tostring = function(self)
    return self.value
  end,

  new = function (self, o)
    o = o or { value = "" }
    setmetatable(o, self)
    self.__index = self
    return o
  end,

  append = function(self, str)
    self.value = self.value .. str
    return self
  end,

  highlight = function (self, hl)
    --[[
    -- hl =
    --  string
    --  | {
    --      name - string,
    --      reverse - bool
    --    }
    --  | {
    --      { name - string, reverse - bool },
    --      { name - string, reverse - bool }
    --    }
    --]]

    local hl_name
    if type(hl) == 'string' then
      hl_name = hl
    elseif type(hl) == 'table' and hl.name then
      hl_name = def_hi(hl)
    elseif type(hl) == 'table' and #hl == 2 then
      hl_name = def_hi_fg_bg(hl[1], hl[2])
    end
    return self:append("%#" .. hl_name .. "#")
  end,

  buffer_number = function(self)
    return self:append "%n"
  end,

  buffer_lines = function(self)
    return self:append "%L"
  end,

  filename_relative = function(self)
    return self:append "%f"
  end,

  filename_full = function(self)
    return self:append "%F"
  end,

  filename_tail = function(self)
    return self:append "%t"
  end,

  filetype = function(self)
    return self:append "%Y"
  end,

  eval = function(self, str)
    return self:append("%{" .. str .. "}")
  end,

  eval_lua = function(self, str)
    return self:append("%{v:lua." .. str .. "()}")
  end,

  format = function(self, str)
    return self:append("%{%" .. str .. "%}")
  end,

  format_lua = function(self, str)
    return self:append("%{%v:lua." .. str .. "()%}")
  end,

  flag_preview = function(self)
    return self:append "%w"
  end,

  flag_modified = function(self)
    return self:append "%M"
  end,

  flag_quickfix = function(self)
    return self:append "%q"
  end,

  flag_readonly = function(self)
    return self:append "%R"
  end,

  current_column = function(self)
    return self:append "%c"
  end,

  current_line = function(self)
    return self:append "%l"
  end,

  current_percent = function(self)
    return self:append "%p"
  end,

  visible_percent = function(self)
    return self:append "%P"
  end,

  separator = function(self)
    return self:append "%="
  end,

  truncate = function(self)
    return self:append "%<"
  end,

  highlight_group = function(self, hl, ...)
    local grp = ""
    for _, v in ipairs({...}) do
      grp = grp .. v
    end

    return self:highlight(hl) .. "%(" .. grp .. "%)"
  end
}

return M
