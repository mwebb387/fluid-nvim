local M = {}

function M:init()
  self
    -- Plugins
    :use('MeanderingProgrammer/render-markdown.nvim')
      .providing('render-markdown')
      .as('markdown')
    :use('fluid.nvim')
      .as('nvim')
end

function M:setup(deps)
  local filetypes = { 'markdown', 'vimwiki', 'opencode_output' }
  deps.markdown.setup({
    anti_conceal = { enabled = false },
    file_types = filetypes,
  })

  deps.nvim:autocmd('FileType', {
    pattern = filetypes,
    callback = function()
      vim.o.wrap = false
    end
  })
end

return M
