local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('render-markdown')
      .from('MeanderingProgrammer/render-markdown.nvim')
      .as('markdown')
    :depends_on('fluid.nvim')
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
