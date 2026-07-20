local M = {
  loaded = false
}

function M:init()
  self
    -- Plugins
    :use('MeanderingProgrammer/render-markdown.nvim')
      .opt()
      .providing('render-markdown')
      .as('markdown')
    :use('fluid.nvim')
      .as('nvim')
end

function M:setup(deps)
  local filetypes = { 'markdown', 'vimwiki', 'opencode_output' }

  deps.nvim:autocmd('FileType', {
    pattern = filetypes,
    callback = function()
      if not self.loaded then
        deps.lazy.markdown.setup({
          anti_conceal = { enabled = false },
          file_types = filetypes,
        })
        self.loaded = true
      end

      vim.o.wrap = false
    end
  })
end

return M
