local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('render-markdown')
      .from('MeanderingProgrammer/render-markdown.nvim')
      .as('markdown')
end

function M:setup(deps)
  deps.markdown.setup({
    anti_conceal = { enabled = false },
    file_types = { 'markdown', 'opencode_output', 'vimwiki' },
  })
end

return M
