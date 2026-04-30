local M = {
  config = {
    adapters = {
      http = {
        ["llama.cpp"] = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://127.0.0.1:8080",
              api_key = "TERM",
              chat_url = "/v1/chat/completions",
            },
          })
        end,
      },
    },
    interactions = {
      -- chat = {
      --   adapter = "llama.cpp",
      --   model = "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q5_K_M"
      --   -- model = "Qwen2_5_1-Coder-7B-Instruct-Q5_K_M"
      -- },
      inline = {
        adapter = "llama.cpp",
        model = "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q5_K_M"
        -- model = "Qwen2_5_1-Coder-7B-Instruct-Q5_K_M"
      },
      chat = {
        adapter = {
          name = "ollama",
          model = "gemma4:e2b",
        },
      },
      -- inline = {
      --   adapter = {
      --     name = "ollama",
      --     model = "qwen2.5-coder:7b",
      --   },
      -- },
    },
  }
}

local started = false
local function start_llama()
  if started then
    return
  end
  started = true
  vim.system({
    "powershell",
    "-NoProfile",
    "-Command",
    [[
Start-Process -WindowStyle Hidden -FilePath "llama-server" -ArgumentList @(
"-hf", "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q5_K_M",
"--host", "127.0.0.1",
"--port", "8080",
"-ngl", "99",
"-c", "2048",
"-fa",
"-b", "512",
"-ub", "256",
"-t", "16"
)
    ]],
  }, { detach = true })
end

function M:setup_codecompanion(deps)
  start_llama()
  deps.codecompanion.setup(self.config)

  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequest*",
    callback = function(args)
      if args.match == "CodeCompanionRequestStarted" then
        vim.g.codecompanion_status = 'started'
      elseif args.match == "CodeCompanionRequestFinished" then
        vim.g.codecompanion_status = ''
      end
      vim.cmd("redrawstatus")
    end,
  })
end

function M:setup_opencode(deps)
  if vim.fn.executable('opencode') == 0 then
    warn('opencode not found on $PATH — OpenCode ACP will not work')
  else
    deps.opencode.setup({})
  end
end

function M:setup_supermaven(deps)
  deps.supermaven.setup({})
end

function M:init()
  if self:has('codecompanion') then
    self:depends_on('codecompanion').from('olimorris/codecompanion.nvim')
  end

  if self:has('opencode') then
    self:depends_on('opencode').from('sudo-tee/opencode.nvim')
  end

  -- Supermaven
  if self:has('supermaven') then
    self:depends_on('supermaven-nvim')
        .from('supermaven-inc/supermaven-nvim')
        .as('supermaven')
  end
end

function M:setup(deps)
  if self:has('codecompanion') then
    self:setup_codecompanion(deps)
  end

  if self:has('opencode') then
    self:setup_opencode(deps)
  end

  if self:has('supermaven') then
    self:setup_supermaven(deps)
  end
end

return M
