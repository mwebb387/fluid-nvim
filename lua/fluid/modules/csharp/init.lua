local M = {}

-- @param fluid any
-- @return nil
-- Initializes the module with the provided fluid configuration and registers necessary components.
function M:init(fluid)
  self
    -- Plugins
    :use('jlcrochet/vim-razor')
    :use('fluid.nvim').as('nvim')

  if self:has('treesitter') then -- also check module registration
    fluid:treesitter():option('lang:c_sharp')
  end

  if self:has('lsp') then -- also check module registration
    self
      :use('Hoffs/omnisharp-extended-lsp.nvim').providing('omnisharp_extended')
      :use('fluid.modules.lsp').as('lsp')
      :use('fluid.modules.lsp.util').as('lsp_util')
      :use('cmp_nvim_lsp').as('cmp')
  end
end

--@param deps table Dependencies table containing necessary components.
--@return nil
function M:setup(deps)
  deps.nvim:autocmd('FileType', {
    pattern = 'cs',
    callback = function()
      vim.cmd.compiler('dotnet')
    end
  })

  if self:has('lsp') then
    deps.nvim:autocmd('FileType', {
      pattern = 'cs',
      callback = function()
        local lsp = {
          capabilities = deps.cmp.default_capabilities(),
          enable_roslyn_analyzers = true,
        }

        deps.lsp:addServerConfig({
          name = 'omnisharp',
          package = 'omnisharp',
          manager = 'scoop'
        })

        vim.lsp.config('omnisharp', lsp)
        vim.lsp.enable('omnisharp')
      end
    })
  end

  if self:has('fold') then
    deps.nvim:autocmd('FileType', {
      pattern = 'cs',
      callback = function()
        vim.opt.foldmethod = 'marker'
        vim.opt.foldmarker = '{,}'
        vim.opt.foldlevel = 99
      end
    })
  end
end

return M
