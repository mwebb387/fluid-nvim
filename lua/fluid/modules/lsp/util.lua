local function on_attach(client, bufnr)
  local buf_keymap = function(...)
    return vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local buf_option = function(...)
    return vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  local opts = {noremap = true, silent = true}
  buf_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_keymap("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_keymap("n", "<leader>ls", "<cmd>lua vim.lsp.buf.workspace_sumbol()<CR>", opts)
  buf_keymap("n", "<leader>lwa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_keymap("n", "<leader>lwr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_keymap("n", "<leader>lwl", "<cmd>lua vim.pretty_print(vim.lsp.buf.list_workspace_folders())<CR>", opts)
  buf_keymap("n", "<leader>lD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_keymap("n", "<leader>le", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_keymap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_keymap("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_keymap("n", "<leader>.", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_keymap("n", "<leader>ld", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  buf_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  buf_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  buf_keymap("n", "<leader>ll", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  buf_keymap("n", "<leader>lq", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)

  if client.server_capabilities.goto_definition then
    buf_option("tagfunc", "v:lua.vim.lsp.tagfunc")
  end

  if client.server_capabilities.document_formatting then
    buf_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    buf_option("formatexpr", "v:lua.vim.lsp.formatexpr()")
  end

  if client.server_capabilities.document_range_formatting then
    buf_keymap("v", "<leader>lf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  if client.server_capabilities.document_highlight then
    vim.cmd("highlight LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow")
    vim.cmd("highlight LspReferenceText cterm=bold ctermbg=red guibg=LightYellow")
    vim.cmd("highlight LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow")

    vim.cmd("augroup lsp_document_highlight")
    vim.cmd("autocmd!")
    vim.cmd("autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()")
    vim.cmd("autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()")
    vim.cmd("augroup END")
  end

  if client.name == 'omnisharp' then
    print('loading omnisharp stuff from on_attach')

    client.server_capabilities.semanticTokensProvider.full = vim.empty_dict()
    client.server_capabilities.semanticTokensProvider.range = true

    local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
    for i, v in ipairs(tokenModifiers) do
      local tmp = string.gsub(v, ' ', '_')
      tokenModifiers[i] = string.gsub(tmp, '-_', '')
    end
    local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
    for i, v in ipairs(tokenTypes) do
      local tmp = string.gsub(v, ' ', '_')
      tokenTypes[i] = string.gsub(tmp, '-_', '')
    end
  end
end

return {on_attach = on_attach}
