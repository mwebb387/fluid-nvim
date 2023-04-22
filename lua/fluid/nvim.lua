local M = {
  map = function(self, mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts or {})
    return self
  end,

  command = function(self, name, command, opts)
    vim.api.nvim_create_user_command(name, command, opts or {})
    return self
  end,

  -- TODO: Better group management and handline...
  -- augroup = function(self, name, opts)
  --   vim.api.nvim_create_augroup(name, opts)
  --   return self
  -- end,

  autocmd = function(self, event, opts, group)
    if group and type(group) == 'string' and #group > 0 then
      local grp = vim.api.nvim_create_augroup(group, {})
      opts.group = grp
    end

    vim.api.nvim_create_autocmd(event, opts)
    return self
  end,

  -- TODO: actual opt methods...
  set = function(self, key, val)
    vim.opt[key] = val
    return self
  end,
  on = function(self, key)
    vim.opt[key] = true
    return self
  end,
  off = function(self, key)
    vim.opt[key] = false
    return self
  end,
  append = function (self, key, val)
    vim.opt[key]:append(val)
    return self
  end,
  prepend = function (self, key, val)
    vim.opt[key]:prepend(val)
    return self
  end,
  remove = function (self, key, val)
    vim.opt[key]:remove(val)
    return self
  end
}

local nvim_meta = {
  __add = function(self, opt_key)
    return self:on(opt_key)
  end,

  __sub = function(self, opt_key)
    return self:off(opt_key)
  end,

  __call = function(self, ...)
    for _, opt in ipairs({...}) do
      if type(opt) == 'string' then
        if string.sub(opt, 1, 2) == 'no' then
          self:off(string.sub(opt, 3))
        else
          self:on(opt)
        end
      end
    end

    return self
  end,
}

setmetatable(M, nvim_meta)

return M
