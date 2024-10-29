local M = {}

function M:init()
  self
    -- Plugins
    :use('kevinhwang91/nvim-bqf')
end

function M:setup()
  -- Quick Fix List toggle
  vim.keymap.set('n', '<leader>q', function()
    local qf_open = false
    for winnr = 1, vim.fn.winnr('$') do
      if vim.fn.getwinvar(winnr, '&syntax') == 'qf' then
        qf_open = true
      end
    end

    if qf_open then
      vim.cmd.cclose()
    else
      vim.cmd.copen()
    end
  end)

end

return M
