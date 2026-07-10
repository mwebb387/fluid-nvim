local M = {}

function M:init()
  self
    -- Plugins
    :use('ThePrimeagen/harpoon').at('harpoon2').providing('harpoon')
    :use('fluid.nvim').as('nvim')
end
  -- :nullls()

function M:setup(deps)
  local harpoon = deps.harpoon

  harpoon.setup()

  deps.nvim
    :map("n", "<leader>ha", function() harpoon:list():add() end)
    :map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    :map("n", "ghf", function() harpoon:list():select(1) end)
    :map("n", "ghd", function() harpoon:list():select(2) end)
    :map("n", "ghs", function() harpoon:list():select(3) end)
    :map("n", "gha", function() harpoon:list():select(4) end)
    :map("n", "ghj", function() harpoon:list():select(5) end)
    :map("n", "ghk", function() harpoon:list():select(6) end)
    :map("n", "ghl", function() harpoon:list():select(7) end)
    :map("n", "gh;", function() harpoon:list():select(8) end)

    -- Toggle previous & next buffers stored within Harpoon list
    :map("n", "<leader>hn", function() harpoon:list():prev() end)
    :map("n", "<leader>hp", function() harpoon:list():next() end)
end

return M
