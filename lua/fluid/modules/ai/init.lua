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
      -- inline = {
      --   adapter = "llama.cpp",
      --   model = "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q5_K_M"
      --   -- model = "Qwen2_5_1-Coder-7B-Instruct-Q5_K_M"
      -- },
      chat = {
        adapter = {
          name = "llama.cpp",
          model = "granite-4.1-3b",
        },
        -- adapter = {
        --   name = "ollama",
        --   -- model = "gemma4:e2b",
        --   -- model = "minimax-m3:cloud",
        --   model = "gpt-oss:20b-cloud",
        -- },
      },
      inline = {
        adapter = {
          name = "llama.cpp",
          model = "granite-4.2-3b",
        },

        -- adapter = {
        --   name = "ollama",
        --   model = "qwen2.5-coder:7b",
        -- },
      },
    },
  }
}

local started = false
-- local function start_llama()
--   if started then
--     return
--   end
--   started = true
--   vim.system({
--     "powershell",
--     "-NoProfile",
--     "-Command",
--     [[
-- Start-Process -WindowStyle Hidden -FilePath "llama-server" -ArgumentList @(
-- "-hf", "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q5_K_M",
-- "--host", "127.0.0.1",
-- "--port", "8080",
-- "-ngl", "99",
-- "-c", "2048",
-- "-fa",
-- "-b", "512",
-- "-ub", "256",
-- "-t", "16"
-- )
--     ]],
--   }, { detach = true })
-- end

-- Setup CodeCompanion with the given dependencies.
-- @param deps Table containing dependency functions (e.g., `deps.nvim:map`).
-- @return void
function M:setup_codecompanion(deps)
  --deps.nvim:map('n', '<leader>Lcc', function()
  -- print('Loading CodeCompanion...')

  if self:has('codecompanion:skills') then
    self.config.extensions = self.config.extensions or {}
    self.config.extensions.agentskills = {
      opts = {
        paths = {
          -- Global, agent-agnostic/shared sources
          { "~/.agents/skills", recursive = true },
          { "~/.pi/agent/skills", recursive = true },
          { "~/.claude/skills", recursive = true },
          { "~/.codex/skills", recursive = true },
          { "~/.config/opencode/skills", recursive = true },

          -- Project-scoped sources
          { ".agents/skills", recursive = true },
          { ".pi/skills", recursive = true },
          { ".claude/skills", recursive = true },
          { ".codex/skills", recursive = true },
          { ".opencode/skills", recursive = true },
        },
        make_slash_commands = true,
      }
    }
  end

  deps.lazy.codecompanion.setup(self.config)

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

  -- print('CodeCompanion loaded.')
  --end, { desc = 'Load CodeCompanion' })
end

function M:setup_opencode(deps)
  if vim.fn.executable('opencode') == 0 then
    warn('opencode not found on $PATH — OpenCode ACP will not work')
  else
    deps.nvim:map('n', '<leader>Loc', function()
      print('Loading Opencode...')

      deps.lazy.opencode.setup({})

      print('Opencode loaded.')
    end, { desc = 'Load Opencode' })
  end
end

function M:setup_supermaven(deps)
  deps.supermaven.setup({
    keymaps = {
      accept_suggestion = "<C-l>",
      -- clear_suggestion = "<C-]>",
      -- accept_word = "<C-j>",
    },
  })
end

function M:init()
  if self:has('codecompanion') then
    self:use('olimorris/codecompanion.nvim')
      --.opt()
      .providing('codecompanion')
  end

  if self:has('codecompanion:skills') then
    self:use('cairijun/codecompanion-agentskills.nvim')
  end

  if self:has('opencode') then
    self:use('sudo-tee/opencode.nvim').opt().providing('opencode')
  end

  -- Supermaven
  if self:has('supermaven') then
    self:use('supermaven-inc/supermaven-nvim')
        .providing('supermaven-nvim')
        .as('supermaven')
  end

  self:use('fluid.nvim').as('nvim')
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
