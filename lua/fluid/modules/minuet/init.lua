local function get_repo_context()
  local ok_config, vc_config = pcall(require, "vectorcode.config")
  if not ok_config then
    return ""
  end

  local cacher = vc_config.get_cacher_backend()
  if not cacher then
    return ""
  end

  local chunks = cacher.query_from_cache(0) or {}

  local out = {}

  for _, file in ipairs(chunks) do
    if file.path and file.document then
      table.insert(
        out,
        "<|file_sep|>" .. file.path .. "\n" .. file.document
      )
    end
  end

  local text = table.concat(out, "\n")

  -- IMPORTANT:
  -- This is characters, not exact tokens.
  -- 4000 chars is roughly ~1000 tokens-ish depending on code.
  local max_chars = 4000

  if #text > max_chars then
    text = text:sub(1, max_chars)
  end

  if text == "" then
    return ""
  end

  return table.concat({
    "<repo_context>",
    "The following snippets are from other files in the same repository.",
    "Use them only when they are directly relevant.",
    text,
    "</repo_context>",
    "",
  }, "\n")
end

local M = {
  config = {
    provider = 'openai_fim_compatible',
    n_completions = 1, -- recommend for local model for resource saving
    -- I recommend beginning with a small context window size and incrementally
    -- expanding it, depending on your local computing power. A context window
    -- of 512, serves as an good starting point to estimate your computing
    -- power. Once you have a reliable estimate of your local computing power,
    -- you should adjust the context window to a larger value.
    notify = 'warn',
    context_window = 1024,
    request_timeout = 10,
    throttle = 500,
    debounce = 250,
    provider_options = {
        openai_fim_compatible = {
            -- For Windows users, TERM may not be present in environment variables.
            -- Consider using APPDATA instead.
            api_key = function () return 'ollama' end,
            name = 'Ollama',
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:3b',
            -- model = 'qwen3-coder-next:cloud',
            stream = true,
            optional = {
                max_tokens = 48,
                temperature = 0.1,
                top_p = 0.9,
                stop = {
                    "\n\n",
                    "\n```",
                    "<|fim_pad|>",
                    "<|endoftext|>",
                },
            },
        },
    },
    virtualtext = {
      auto_trigger_ft = { '*' },
      keymap = {
        -- accept whole completion
        accept = '<A-A>',
        -- accept one line
        accept_line = '<A-a>',
        -- accept n lines (prompts for number)
        -- e.g. "A-z 2 CR" will accept 2 lines
        accept_n_lines = '<A-z>',
        -- Cycle to prev completion item, or manually invoke completion
        prev = '<A-[>',
        -- Cycle to next completion item, or manually invoke completion
        next = '<A-]>',
        dismiss = '<A-e>',
      },
    },
  }
}

function M:init()
  self
    :use('milanglacier/minuet-ai.nvim').providing('minuet')
    :use('fluid.nvim').as('nvim')
end

function M:setup(deps)
  local smart_config = vim.deepcopy(self.config)
  smart_config.context_window = 4096
  smart_config.throttle = 1000
  smart_config.debounce = 500
  smart_config.provider_options.openai_fim_compatible.name = 'OllamaSmart'
  -- smart_config.provider_options.openai_fim_compatible.model = 'qwen2.5-coder:7b'
  smart_config.provider_options.openai_fim_compatible.optional.max_tokens = 128
  smart_config.provider_options.openai_fim_compatible.optional.temperature = 0.05
  smart_config.provider_options.openai_fim_compatible.optional.stop = {
    "\n\n\n",
    "\n```",
    "<|endoftext|>",
  }
  smart_config.provider_options.openai_fim_compatible.template = {
    prompt = function(context_before_cursor, context_after_cursor, _)
      local repo_context = get_repo_context()

      -- Qwen2.5-Coder FIM tokens.
      -- Change these if you use a different model family.
      return repo_context
        .. "<|fim_prefix|>"
        .. context_before_cursor
        .. "<|fim_suffix|>"
        .. context_after_cursor
        .. "<|fim_middle|>"
    end,

      -- Important for custom FIM prompt construction.
    suffix = false,
  }
  smart_config.virtualtext = {
    auto_trigger_ft = {},
  }

  vim.g.minuet_status = ""
  vim.g.minuet_mode = 'Fast'
  deps.minuet.setup(self.config)

  deps.nvim:map('n', '<leader>mt', function()
    if vim.g.minuet_mode == 'Fast' then
      deps.minuet.setup(smart_config)
      vim.g.minuet_mode = 'Smart'
      vim.cmd.redrawstatus()
      print('Minuet mode set to Smart')
    else
      deps.minuet.setup(self.config)
      vim.g.minuet_mode = 'Fast'
      vim.cmd.redrawstatus()
      print('Minuet mode set to Fast')
    end
  end, { desc = 'Toggle Minuet between Fast and Smart Mode' })

  deps.nvim:autocmd("User", {
    pattern = "MinuetRequestStarted",
    callback = function()
      vim.g.minuet_status = "started"
      --refresh vim statusline
      vim.cmd.redrawstatus()
    end,
  })

  deps.nvim:autocmd("User", {
    pattern = "MinuetRequestFinished",
    callback = function()
      vim.g.minuet_status = ""
      vim.cmd.redrawstatus()
    end,
  })
end

return M
