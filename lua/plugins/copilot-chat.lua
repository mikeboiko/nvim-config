local function quick_chat(mode)
  return function()
    require('config.keymaps').call_global('CopilotQuickChat', mode)
  end
end

return {
  -- CopilotChat.nvim
  'CopilotC-Nvim/CopilotChat.nvim',
  lazy = false,
  dependencies = {
    { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
  },
  build = 'make tiktoken', -- Only on MacOS or Linux
  keys = {
    { '<leader>ac', ':CopilotChatToggle<CR>', mode = 'n', silent = true, desc = 'Toggle Copilot chat' },
    { '<leader>af', ':CopilotChatFixDiagnostic<CR>', mode = 'n', silent = true, desc = 'Fix diagnostics with Copilot' },
    { '<leader>aq', quick_chat('Buffer'), mode = 'n', silent = true, desc = 'Ask Copilot about the current buffer' },
    { '<leader>at', ':CopilotChatTests<CR>', mode = 'n', silent = true, desc = 'Generate tests with Copilot' },
    { '<leader>ac', ':<C-u>CopilotChatToggle<CR>', mode = 'v', silent = true, desc = 'Toggle Copilot chat' },
    { '<leader>ad', ':CopilotChatDocs<CR>', mode = 'v', silent = true, desc = 'Document selection with Copilot' },
    { '<leader>ae', ':CopilotChatExplainBrief<CR>', mode = 'v', silent = true, desc = 'Explain selection briefly' },
    { '<leader>af', ':CopilotChatFix<CR>', mode = 'v', silent = true, desc = 'Fix selection with Copilot' },
    { '<leader>ao', ':CopilotChatOptimize<CR>', mode = 'v', silent = true, desc = 'Optimize selection with Copilot' },
    { '<leader>aq', quick_chat('Visual'), mode = 'v', silent = true, desc = 'Ask Copilot about the selection' },
    { '<leader>ar', ':CopilotChatReview<CR>', mode = 'v', silent = true, desc = 'Review selection with Copilot' },
  },
  opts = {
    -- See Configuration section for options
  },
  -- See Commands section for default commands if you want to lazy load on them
  config = function()
    local chat = require('CopilotChat')
    local select = require('CopilotChat.select')
    local luna_model = 'gpt-6-luna'
    -- CopilotChat.nvim does not expose reasoning effort in its setup options.
    local providers = vim.deepcopy(require('CopilotChat.config.providers'))
    local prepare_copilot_input = providers.copilot.prepare_input
    providers.copilot.prepare_input = function(inputs, options)
      local request, extra_headers = prepare_copilot_input(inputs, options)

      if options.model.id == luna_model then
        if not options.model.use_responses then
          error('GPT-6 Luna max reasoning requires the Responses API')
        end

        request.reasoning = vim.tbl_extend('force', request.reasoning or {}, { effort = 'max' })
      end

      return request, extra_headers
    end

    require('CopilotChat').setup({
      debug = false,
      -- https://docs.github.com/en/copilot/reference/ai-models/supported-models#supported-ai-models-per-copilot-plan
      model = luna_model,
      providers = providers,
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

    local function report_gap_failure(message)
      vim.notify(message, vim.log.levels.ERROR, { title = 'git/gap' })
    end

    -- Generate a commit message in this Copilot session, then run the shared gap workflow.
    vim.g.CopilotCommitMsg = function(dir)
      local gap_script = vim.fn.expand('~/git/Linux/git/gap')
      local terminal = require('config.terminal')
      if vim.fn.executable(gap_script) ~= 1 then
        report_gap_failure('git/gap is not executable: ' .. gap_script)
        return
      end

      chat.ask(
        '#gitdiff:staged Write a Conventional Commit message for the staged changes. Keep the title to at most 50 characters and wrap body lines at 72 characters. Output only the commit message, without code fences or a Co-authored-by: Copilot trailer.',
        {
          callback = function(response)
            local commit_message = type(response) == 'table' and response.content or nil
            if type(commit_message) ~= 'string' or vim.trim(commit_message) == '' then
              report_gap_failure('Copilot returned an empty commit message')
              return
            end

            local opened, terminal_buf, terminal_win = pcall(function()
              vim.cmd('botright new')
              local buf = vim.api.nvim_get_current_buf()
              local win = vim.api.nvim_get_current_win()
              vim.api.nvim_buf_set_var(buf, 'nvim_gap_terminal', 1)
              return buf, win
            end)
            if not opened then
              local message = 'Could not open a terminal split for git/gap: ' .. tostring(terminal_buf)
              report_gap_failure(message)
              return
            end

            local command = { 'env', '-u', 'PYTEST_ADDOPTS', gap_script, '-m', commit_message }
            local ok, job_id = pcall(vim.fn.termopen, command, {
              cwd = dir,
              on_exit = function(_, code)
                vim.schedule(function()
                  if code == 0 then
                    local repo = vim.fn.fnamemodify(dir, ':t')
                    local title
                    for line in commit_message:gmatch('[^\r\n]+') do
                      if line:match('%S') and not line:match('^```') then
                        title = line
                        break
                      end
                    end

                    local output = ''
                    if vim.api.nvim_buf_is_valid(terminal_buf) then
                      output = table.concat(vim.api.nvim_buf_get_lines(terminal_buf, 0, -1, false), '\n')
                    end

                    terminal.close_gap_terminal(terminal_buf, terminal_win)

                    if output:find('No changes to commit.', 1, true) then
                      vim.notify(
                        string.format('Gap completed (%s); no changes to commit.', repo),
                        vim.log.levels.INFO,
                        { title = 'git/gap' }
                      )
                    else
                      vim.notify(
                        string.format('Gap completed (%s):\n%s', repo, title or '(no commit title)'),
                        vim.log.levels.INFO,
                        { title = 'git/gap' }
                      )
                    end
                  else
                    local summary = 'git/gap failed (exit code '
                      .. code
                      .. '); full output remains in the terminal split.'
                    report_gap_failure(summary)
                  end

                  chat.close()
                end)
              end,
            })

            if not ok then
              local message = 'Failed to start git/gap: ' .. tostring(job_id)
              report_gap_failure(message)
            elseif job_id <= 0 then
              local message = 'Failed to start git/gap (job ID ' .. job_id .. ').'
              report_gap_failure(message)
            end
          end,
        }
      )
    end
  end,
}
