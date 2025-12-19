local M = {}

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

function M.run()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == '' then
    return
  end

  local script = vim.fn.stdpath('config') .. '/scripts/flow_resolve.py'

  local function on_done(obj)
    local stderr = (obj.stderr or ''):gsub('%s+$', '')

    if obj.code ~= 0 then
      if stderr:find('No `%.flow%.yml` found', 1, false) then
        notify(stderr, vim.log.levels.INFO)
      else
        notify(stderr ~= '' and stderr or ('FlowRunAsync failed (exit %d)'):format(obj.code), vim.log.levels.ERROR)
      end
      return
    end

    local script_path = (obj.stdout or ''):match('^%s*(.-)%s*$')
    if script_path == '' then
      notify('FlowRunAsync failed: no script produced', vim.log.levels.ERROR)
      return
    end

    vim.schedule(function()
      vim.cmd('15split term://' .. vim.fn.fnameescape(script_path))
      vim.cmd('$')
      vim.cmd('wincmd j')
    end)
  end

  local python = vim.g.python3_host_prog
  if type(python) ~= 'string' or python == '' then
    python = 'python3'
  end

  if vim.system then
    vim.system({ python, script, filepath }, { text = true }, on_done)
  else
    local stdout, stderr = {}, {}
    vim.fn.jobstart({ python, script, filepath }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.list_extend(stdout, data)
        end
      end,
      on_stderr = function(_, data)
        if data then
          vim.list_extend(stderr, data)
        end
      end,
      on_exit = function(_, code)
        on_done({ code = code, stdout = table.concat(stdout, '\n'), stderr = table.concat(stderr, '\n') })
      end,
    })
  end
end

return M
