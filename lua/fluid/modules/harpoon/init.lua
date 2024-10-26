local M = {}

function M:init()
  self
    -- Plugins
    :depends_on('harpoon').from('ThePrimeagen/harpoon')
    :depends_on('fluid.nvim').as('nvim')
end
  -- :nullls()

function M:setup(deps)
  deps.harpoon.setup()
  deps.nvim:map('n', '<leader>ha', function()
    require("harpoon.mark").add_file()
  end)
  deps.nvim:map('n', '<leader>ha', function()
    require("harpoon.ui").toggle_quick_menu()
  end)
  deps.nvim:map('n', '<leader>hn', function()
    require("harpoon.ui").nav_next()
  end)
  deps.nvim:map('n', '<leader>hp', function()
    require("harpoon.ui").nav_prev()
  end)
end

return M
