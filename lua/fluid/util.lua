local M = {}

function M.find(list, fn)
  for _, opt in ipairs(list) do
    if fn(opt) then
      return opt
    end
  end
  return nil
end

return M
