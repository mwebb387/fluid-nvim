local M = {
  config = {
    cmd = 'powershell'
  }
}

function M:init()
  self
    :use('numToStr/FTerm.nvim')
    :depends('FTerm')
    :depends('fluid.nvim', 'nvim')
end

function M:setup(deps)
  deps.nvim
    :command(
      'FTermToggle',
      function()
        deps.FTerm.toggle()
      end
    )
    :map('n', '<M-`>', ':FTermToggle<CR>')
    :map('t', '<M-`>', ':<c-\\><c-n>:FTermToggle<CR>')

  deps.FTerm.setup(self.config)
end

return M
