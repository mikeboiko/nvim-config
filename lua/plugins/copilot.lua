return {
  { -- blink-cmp-copilot {{{1
    'giuxtaposition/blink-cmp-copilot',
  },
  { -- copilot.lua {{{1
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
  }, -- }}}
  { -- CopilotChat.nvim {{{1
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
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
        model = 'claude-sonnet-4',
        chat_autocomplete = false,
        auto_follow_cursor = false,
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
          "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Don't include any text except for the commit message in your output, because this text will be used for automated git commit messages. Don't wrap in ```",
          {
            sticky = { '#gitdiff:unstaged' },
            -- model = 'gpt-4.1',
            callback = function(response)
              -- Save response to a file
              local file_path = '/tmp/copilot_commit_msg'
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

              -- io.popen("echo vim - " .. dir .. " >> /tmp/gitdir.txt 2>&1")
              io.popen(
                "bash -c 'git -C "
                  .. dir
                  .. ' add -A; git -C '
                  .. dir
                  .. ' commit -F '
                  .. file_path
                  .. '; git -C '
                  .. dir
                  .. " push > /dev/null 2>&1'"
                -- .. " >> /tmp/gitdir.txt 2>&1"
              )
              -- vim.cmd("silent Git -C " .. dir .. "push")
            end,
          }
        )
        -- chat.close()
      end
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
