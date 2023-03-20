local M = {
  map = function(self, mode, lhs, rhs, opts)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    return self
  end,

  command = function(self, name, command, opts)
    vim.api.nvim_create_user_command(name, command, opts)
    return self
  end,

  augroup = function(self, name, opts)
    vim.api.nvim_create_augroup(name, opts)
    return self
  end,

  autocmd = function(self, event, opts)
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
  end
}

local nvim_meta = {
  __add = function(self, opt_key)
    return self:on(opt_key)
  end,

  __sub = function(self, opt_key)
    return self:off(opt_key)
  end,

}

setmetatable(M, nvim_meta)

return M
