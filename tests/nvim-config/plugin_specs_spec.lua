local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h:h')
local plugin_files = vim.fn.glob(root .. '/lua/plugins/*.lua', false, true)

local function load_plugin(module)
  package.loaded[module] = nil

  local ok, spec = pcall(require, module)
  assert.is_true(ok, module)
  assert.is_table(spec)

  return spec
end

describe('nvim-config plugin specs', function()
  it('loads every plugin spec module without errors', function()
    for _, path in ipairs(plugin_files) do
      local module = 'plugins.' .. vim.fn.fnamemodify(path, ':t:r')
      load_plugin(module)
    end
  end)

  it('passes Copilot commit messages to git/gap from the repository root', function()
    local spec = load_plugin('plugins.copilot-chat')
    local original_chat = package.loaded.CopilotChat
    local original_select = package.loaded['CopilotChat.select']
    local original_providers = package.loaded['CopilotChat.config.providers']
    local original_commit_callback = vim.g.CopilotCommitMsg
    local original_quick_chat = vim.g.CopilotQuickChat
    local original_expand = vim.fn.expand
    local original_executable = vim.fn.executable
    local original_termopen = vim.fn.termopen
    local original_notify = vim.notify
    local original_echo = vim.api.nvim_echo
    local original_schedule = vim.schedule
    local original_window = vim.api.nvim_get_current_win()
    local existing_commands = vim.api.nvim_get_commands({})
    local setup_options
    local prompt
    local ask_options
    local launches = {}
    local notifications = {}
    local echoes = {}
    local chat_close_count = 0
    local message = 'feat(test): use session context\n\nCommit the generated message.'

    package.loaded.CopilotChat = {
      setup = function(options)
        setup_options = options
      end,
      close = function()
        chat_close_count = chat_close_count + 1
      end,
      ask = function(chat_prompt, opts)
        prompt = chat_prompt
        ask_options = opts
      end,
    }
    package.loaded['CopilotChat.config.providers'] = {
      copilot = {
        prepare_input = function(inputs, options)
          return {
            model = options.model.id,
            input = inputs,
          }, { ['x-test-header'] = 'preserved' }
        end,
      },
    }
    package.loaded['CopilotChat.select'] = {
      buffer = function() end,
      visual = function() end,
    }
    vim.fn.expand = function(path)
      assert.are.equal('~/git/Linux/git/gap', path)
      return '/mock/Linux/git/gap'
    end
    vim.fn.executable = function(path)
      assert.are.equal('/mock/Linux/git/gap', path)
      return 1
    end
    vim.fn.termopen = function(command, opts)
      table.insert(launches, {
        command = command,
        options = opts,
        buffer = vim.api.nvim_get_current_buf(),
        window = vim.api.nvim_get_current_win(),
      })
      return 42
    end
    vim.notify = function(text, level)
      table.insert(notifications, { text, level })
    end
    vim.api.nvim_echo = function(chunks, history, opts)
      table.insert(echoes, { chunks, history, opts })
    end
    vim.schedule = function(callback)
      callback()
    end

    local ok, err = pcall(function()
      spec.config()
      assert.are.equal('gpt-6-luna', setup_options.model)

      local luna_request, extra_headers = setup_options.providers.copilot.prepare_input({}, {
        model = { id = 'gpt-6-luna', use_responses = true },
      })
      assert.are.same({
        model = 'gpt-6-luna',
        input = {},
        reasoning = { effort = 'max' },
      }, luna_request)
      assert.are.same({ ['x-test-header'] = 'preserved' }, extra_headers)

      local other_model_request = setup_options.providers.copilot.prepare_input({}, {
        model = { id = 'gpt-5-mini', use_responses = true },
      })
      assert.are.same({ model = 'gpt-5-mini', input = {} }, other_model_request)

      local supports_luna_effort, effort_error = pcall(setup_options.providers.copilot.prepare_input, {}, {
        model = { id = 'gpt-6-luna', use_responses = false },
      })
      assert.is_false(supports_luna_effort)
      assert.is_truthy(effort_error:find('requires the Responses API', 1, true))

      vim.g.CopilotCommitMsg('/tmp/repo')

      assert.is_truthy(prompt:find('#gitdiff:staged', 1, true))
      assert.is_truthy(prompt:find('50 characters', 1, true))
      assert.is_truthy(prompt:find('72 characters', 1, true))
      assert.is_truthy(prompt:find('Co-authored-by: Copilot', 1, true))
      assert.is_table(ask_options)

      ask_options.callback({ content = message })

      assert.are.same({
        'env',
        '-u',
        'PYTEST_ADDOPTS',
        '/mock/Linux/git/gap',
        '-m',
        message,
      }, launches[1].command)
      assert.are.equal('/tmp/repo', launches[1].options.cwd)
      assert.are.equal(1, vim.api.nvim_buf_get_var(launches[1].buffer, 'nvim_gap_terminal'))
      assert.are.equal('Waiting for Copilot commit message.', notifications[1][1])
      assert.are.equal('Running git/gap in a terminal split.', notifications[2][1])
      assert.are.equal(0, chat_close_count)

      launches[1].options.on_exit(42, 0)
      assert.is_false(vim.api.nvim_win_is_valid(launches[1].window))
      assert.is_false(vim.api.nvim_buf_is_valid(launches[1].buffer))
      assert.are.equal(1, chat_close_count)

      vim.g.CopilotCommitMsg('/tmp/repo')
      ask_options.callback({ content = message })
      assert.are.equal(1, chat_close_count)
      launches[2].options.on_exit(42, 1)
      assert.is_true(vim.api.nvim_win_is_valid(launches[2].window))
      assert.is_true(vim.api.nvim_buf_is_valid(launches[2].buffer))
      assert.are.equal(2, chat_close_count)
    end)

    for index = #launches, 1, -1 do
      local launch = launches[index]
      if vim.api.nvim_win_is_valid(launch.window) and launch.window ~= original_window then
        vim.api.nvim_win_close(launch.window, true)
      end
      if vim.api.nvim_buf_is_valid(launch.buffer) then
        vim.api.nvim_buf_delete(launch.buffer, { force = true })
      end
    end
    package.loaded.CopilotChat = original_chat
    package.loaded['CopilotChat.select'] = original_select
    package.loaded['CopilotChat.config.providers'] = original_providers
    vim.g.CopilotCommitMsg = original_commit_callback
    vim.g.CopilotQuickChat = original_quick_chat
    vim.fn.expand = original_expand
    vim.fn.executable = original_executable
    vim.fn.termopen = original_termopen
    vim.notify = original_notify
    vim.api.nvim_echo = original_echo
    vim.schedule = original_schedule
    if not existing_commands.CopilotChatBuffer then
      pcall(vim.api.nvim_del_user_command, 'CopilotChatBuffer')
    end
    if not existing_commands.CopilotChatVisual then
      pcall(vim.api.nvim_del_user_command, 'CopilotChatVisual')
    end

    assert.is_true(ok, err)
    assert.are.same({
      { 'Waiting for Copilot commit message.', vim.log.levels.INFO },
      { 'Running git/gap in a terminal split.', vim.log.levels.INFO },
      { 'Gap completed (repo):\nfeat(test): use session context', vim.log.levels.INFO },
      { 'Waiting for Copilot commit message.', vim.log.levels.INFO },
      { 'Running git/gap in a terminal split.', vim.log.levels.INFO },
    }, { notifications[1], notifications[2], notifications[3], notifications[4], notifications[5] })
    assert.is_truthy(notifications[6][1]:find('git/gap failed (exit code 1)', 1, true))
    assert.is_truthy(notifications[6][1]:find('full output remains in the terminal split', 1, true))
    assert.are.equal(vim.log.levels.ERROR, notifications[6][2])
    assert.is_true(echoes[1][2])
    assert.is_truthy(echoes[1][1][1][1]:find('terminal split', 1, true))
  end)

  it('automatically installs the available Roslyn package after refreshing Mason', function()
    local spec = load_plugin('plugins.mason')
    local original_mason = package.loaded.mason
    local original_registry = package.loaded['mason-registry']
    local original_schedule = vim.schedule
    local original_list_uis = vim.api.nvim_list_uis
    local setup_opts
    local install_called = false

    vim.schedule = function(callback)
      callback()
    end
    vim.api.nvim_list_uis = function()
      return { {} }
    end
    package.loaded.mason = {
      setup = function(opts)
        setup_opts = opts
      end,
    }
    package.loaded['mason-registry'] = {
      is_installed = function(name)
        assert.is_true(name == 'roslyn-nightly' or name == 'roslyn')
        return false
      end,
      refresh = function(callback)
        callback(true)
      end,
      has_package = function(name)
        assert.equal('roslyn-nightly', name)
        return true
      end,
      get_package = function(name)
        assert.equal('roslyn-nightly', name)
        return {
          is_installed = function()
            return false
          end,
          is_installing = function()
            return false
          end,
          install = function(_, opts, callback)
            assert.same({}, opts)
            install_called = true
            callback(true)
          end,
        }
      end,
    }
    spec.config()
    vim.schedule = original_schedule
    vim.api.nvim_list_uis = original_list_uis
    package.loaded.mason = original_mason
    package.loaded['mason-registry'] = original_registry

    assert.same({
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    }, setup_opts)
    assert.is_true(install_called)
  end)

  it('schedules Mason failure notifications outside fast callbacks', function()
    local spec = load_plugin('plugins.mason')
    local original_mason = package.loaded.mason
    local original_registry = package.loaded['mason-registry']
    local original_schedule = vim.schedule
    local original_list_uis = vim.api.nvim_list_uis
    local original_notify = vim.notify
    local scheduled = {}
    local notifications = {}

    vim.schedule = function(callback)
      table.insert(scheduled, callback)
    end
    vim.api.nvim_list_uis = function()
      return { {} }
    end
    vim.notify = function(message)
      table.insert(notifications, message)
    end
    package.loaded.mason = {
      setup = function() end,
    }
    package.loaded['mason-registry'] = {
      is_installed = function()
        return false
      end,
      refresh = function(callback)
        callback(true)
      end,
      has_package = function(name)
        return name == 'roslyn-nightly'
      end,
      get_package = function()
        return {
          is_installed = function()
            return false
          end,
          is_installing = function()
            return false
          end,
          install = function(_, _, callback)
            callback(false, 'download failed')
          end,
        }
      end,
    }

    spec.config()
    assert.equal(1, #scheduled)
    scheduled[1]()
    assert.equal(2, #scheduled)
    scheduled[2]()
    assert.equal(3, #scheduled)
    assert.equal(0, #notifications)
    scheduled[3]()

    vim.schedule = original_schedule
    vim.api.nvim_list_uis = original_list_uis
    vim.notify = original_notify
    package.loaded.mason = original_mason
    package.loaded['mason-registry'] = original_registry

    assert.equal(1, #notifications)
    assert.matches('Mason failed to install roslyn%-nightly: download failed', notifications[1])
  end)

  it('points the roslyn LSP command at the Mason binary', function()
    local spec = load_plugin('plugins.roslyn')

    -- The deprecated `extensions` option lived under `opts`; it must be gone.
    assert.is_nil(spec.opts)
    assert.is_function(spec.config)

    local original_roslyn = package.loaded['roslyn']
    local original_executable = vim.fn.executable
    local original_lsp_config = vim.lsp.config
    local setup_called = false
    local configured

    package.loaded['roslyn'] = {
      setup = function()
        setup_called = true
      end,
    }
    vim.fn.executable = function()
      return 1
    end
    vim.lsp.config = function(name, cfg)
      if name == 'roslyn' then
        configured = cfg
      end
    end

    spec.config()

    package.loaded['roslyn'] = original_roslyn
    vim.fn.executable = original_executable
    vim.lsp.config = original_lsp_config

    assert.is_true(setup_called)
    assert.is_table(configured)
    assert.is_table(configured.cmd)
    assert.matches('mason/bin/roslyn$', configured.cmd[1])
    assert.equal('--stdio', configured.cmd[2])
  end)

  it('runs markdown preview in multi-instance mode', function()
    local spec = load_plugin('plugins.markdown-preview')
    local original_markdown_preview = package.loaded['markdown_preview']
    local original_create_autocmd = vim.api.nvim_create_autocmd
    local original_create_augroup = vim.api.nvim_create_augroup
    local setup_opts

    package.loaded['markdown_preview'] = {
      setup = function(opts)
        setup_opts = opts
      end,
    }
    vim.api.nvim_create_autocmd = function() end
    vim.api.nvim_create_augroup = function()
      return 1
    end

    spec.config()

    vim.api.nvim_create_autocmd = original_create_autocmd
    vim.api.nvim_create_augroup = original_create_augroup
    package.loaded['markdown_preview'] = original_markdown_preview

    assert.is_table(setup_opts)
    assert.equal('multi', setup_opts.instance_mode)
    assert.equal('rust', setup_opts.mermaid_renderer)
  end)
end)
