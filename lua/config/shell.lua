local comments = require('config.comments')

local M = {}

M.mani_config = vim.fn.expand('~/git/Linux/config/mani.yaml')

function M.run_ex(command)
  vim.cmd(command)
end

function M.jobstart(command, opts)
  return vim.fn.jobstart(command, opts)
end

function M.echo(message)
  vim.api.nvim_echo({ { message } }, true, {})
end

function M.figlet_lines(text)
  return vim.fn.systemlist('figlet ' .. text)
end

local function put_lines_below_cursor(lines)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end

function M.figlet(text)
  local comment_prefix = comments.get_commentstring():gsub('%%s', '')
  local lines = M.figlet_lines(text)

  for index, line in ipairs(lines) do
    lines[index] = vim.trim(comment_prefix .. line)
  end

  put_lines_below_cursor(lines)
  return lines
end

function M.grep(args)
  M.run_ex('silent grep! --ignore node_modules --follow ' .. args)
  M.run_ex('copen')
end

function M.replace_m_with_blank()
  pcall(M.run_ex, [[%s/\r$//]])
end

function M.replace_m_with_newline()
  pcall(M.run_ex, [[%s/\r/\r/]])
end

function M.mani(args)
  pcall(M.run_ex, 'sp term://mani -c ' .. M.mani_config .. ' ' .. args)
end

function M.start_async_neovim(command)
  return M.jobstart(command, {
    on_exit = function(_, code)
      M.echo('command finished with exit status ' .. code)
    end,
  })
end

function M.register_legacy_functions()
  _G.nvim_config_figlet_legacy = function(text)
    M.figlet(text)
  end

  vim.cmd([[
function! Figlet(...) abort
  call v:lua.nvim_config_figlet_legacy(a:1)
endfunction
]])
end

return M
