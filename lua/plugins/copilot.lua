return {
  { -- blink-cmp-copilot
    'giuxtaposition/blink-cmp-copilot',
  },
  { -- copilot.lua
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          yaml = true,
          gitcommit = true,
        },
      })
    end,
  },
  { -- CopilotChat.nvim
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
    config = function()
      local chat = require('CopilotChat')
      local select = require('CopilotChat.select')
      require('CopilotChat').setup({
        debug = false,
        -- https://docs.github.com/en/copilot/reference/ai-models/supported-models#supported-ai-models-per-copilot-plan
        model = 'oswe-vscode-prime',
        chat_autocomplete = false,
        auto_follow_cursor = false,
        -- auto_insert_mode = true,
        prompts = {
          ExplainBuffer = {
            prompt = '/COPILOT_EXPLAIN\n\nWrite an explanation for the selection as paragraphs of text.',
            selection = select.buffer,
          },
          ExplainBrief = {
            prompt = '/COPILOT_EXPLAIN\n\nWrite a brief explanation for the selection as paragraphs of text.',
          },
          Tests = {
            prompt = '/COPILOT_GENERATE\n\nPlease generate tests for my code using pytest.',
          },
        },
        mappings = {
          close = {
            normal = 'qq',
            insert = '<C-c>',
          },
          reset = {
            normal = '<C-r>',
            insert = '<C-r>',
          },
        },
      })

      vim.api.nvim_create_user_command('CopilotChatBuffer', function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = '*', range = true })

      vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = '*', range = true })

      vim.g.CopilotQuickChat = function(mode)
        local prompt = 'Ask ChatGPT (' .. mode .. ' selection): '
        local command = 'CopilotChat' .. mode .. ' '
        vim.ui.input({ prompt = prompt }, function(query)
          if query == nil then
            return
          end
          vim.cmd(command .. query)
        end)
      end

      -- Automated git commit messages
      vim.g.CopilotCommitMsg = function(dir)
        chat.ask(
          "#gitdiff:staged Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Don't include any text except for the commit message in your output, because this text will be used for automated git commit messages. Don't wrap in ```",
          {
            -- sticky = { '#gitdiff:unstaged' },
            -- model = 'gpt-4.1',
            callback = function(response)
              -- Save response to a file
              local file_path = '/tmp/COMMIT_EDITMSG'
              local file = io.open(file_path, 'w')
              if file then
                if file:write(response.content) then
                  file:close()
                else
                  vim.notify('Failed to write to file', vim.log.levels.ERROR)
                end
              else
                vim.notify('Failed to open file', vim.log.levels.ERROR)
              end

              local stdout = {}
              local stderr = {}
              vim.fn.jobstart({
                'bash',
                '-c',
                'unset PYTEST_ADDOPTS; git -C '
                  .. vim.fn.shellescape(dir)
                  .. ' -C '
                  .. vim.fn.shellescape(dir)
                  .. ' commit -F '
                  .. file_path
                  .. ' && git -C '
                  .. vim.fn.shellescape(dir)
                  .. ' push',
              }, {
                on_stdout = function(_, data)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= '' then
                        table.insert(stdout, line)
                      end
                    end
                  end
                end,
                on_stderr = function(_, data)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= '' then
                        table.insert(stderr, line)
                      end
                    end
                  end
                end,
                on_exit = function(_, code)
                  if code == 0 then
                    local repo = vim.fn.fnamemodify(dir, ':t')
                    local title
                    for line in (response.content or ''):gmatch('[^\r\n]+') do
                      if line:match('%S') and not line:match('^```') then
                        title = line
                        break
                      end
                    end
                    vim.notify(
                      string.format('Copilot commit (%s): %s', repo, title or '(no commit title)'),
                      vim.log.levels.INFO
                    )
                  else
                    local err_msg = table.concat(stderr, '\n')
                    if err_msg == '' then
                      err_msg = table.concat(stdout, '\n')
                    end
                    if err_msg == '' then
                      err_msg = 'Unknown error (exit code ' .. code .. ')'
                    end
                    vim.notify('Copilot commit failed:\n' .. err_msg, vim.log.levels.ERROR)
                  end
                end,
              })
              -- vim.cmd("silent Git -C " .. dir .. "push")
            end,
          }
        )
        -- chat.close()
      end
    end,
  },
}
