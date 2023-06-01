local M = {}

function M:init()
  self
    :use('skywind3000/asyncrun.vim')
    :depends_on('fluid.nvim').as('nvim')
end

function M:setup(deps)
  -- vim.g.asyncrun_open = true
  deps.nvim:command('Rg', function(input)
    vim.cmd('AsyncRun ' .. vim.o.grepprg .. ' ' .. input.args .. ' .')
    vim.cmd.copen()
  end, {nargs = 1})


  deps.nvim:command('Mk', function(input)
    vim.cmd ("AsyncRun " .. vim.o.makeprg .. ' ' .. input.args .. ' .')
    vim.cmd.copen()
  end, {nargs = "?"})
end

return M
