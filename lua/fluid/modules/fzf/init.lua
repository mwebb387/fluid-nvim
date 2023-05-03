local M = {}

function M:init()
  self
    :use('junegunn/fzf')
    :depends_on('fzf-opts').as('fzf_o')
    :depends_on('fluid.nvim').as('nvim')
end

-- function M:setup(deps)
--   deps.nvim:map('n', '<C-p>', function()
--     local opts = {
--       sink = 'e',
--       options = deps.fzf_o.create_opts()
--     }
--     vim.fn['fzf#run'](vim.fn['fzf#wrap'](opts))
--   end)
-- end

return M
