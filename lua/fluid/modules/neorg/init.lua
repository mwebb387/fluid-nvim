local M = {
  config = {
    load = {
      ['core.defaults'] = {},
      ['core.norg.dirman'] = {
        config = {
          workspaces = { work = '~/.norg/work' }
        }
      },
      ['core.norg.completion'] = {
        config = {
          engine = 'nvim-cmp'
        }
      },
      ['core.norg.concealer'] = {},
      ['core.norg.qol.toc'] = {}
    }
  }
}

function M:init()
  self:use('nvim-neorg/neorg')
      :depends('neorg')

  -- TODO: options for neorg...
end

function M:setup(deps)
  deps.neorg.setup(self.config)
end

return M
