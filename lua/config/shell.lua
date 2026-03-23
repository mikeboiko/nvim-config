local comments = require('config.comments')
local git = require('config.git')

local M = {}

M.mani_config = vim.fn.expand('~/git/Linux/config/mani.yaml')
M.tables_report_command = 'cd ~/git/Tables; uv run finances balances print_balances'
M.weather_report_url = 'wttr.in/Calgary?m'

function M.run_ex(command)
  vim.cmd(command)
end

function M.jobstart(command, opts)
  return vim.fn.jobstart(command, opts)
end

function M.echo(message)
  vim.api.nvim_echo({ { message } }, true, {})
end

function M.notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

function M.figlet_lines(text)
  return vim.fn.systemlist('figlet ' .. text)
end

function M.feedkeys(keys, mode)
  vim.api.nvim_feedkeys(vim.keycode(keys), mode or 'n', false)
end

function M.get_current_word()
  return vim.fn.expand('<cword>')
end

function M.get_git_root()
  local git_dir = git.get_root()
  if not git_dir then
    M.notify('Not in a git repository', vim.log.levels.ERROR)
    return nil
  end

  return git_dir
end

function M.quote_argument(value)
  return '"' .. value:gsub('"', [[\"]]) .. '"'
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

function M.prefill_commandline(command, cursor_keys)
  M.feedkeys(':' .. command .. (cursor_keys or ''))
end

function M.prefill_grep(args, cursor_keys)
  M.prefill_commandline('Grep ' .. args, cursor_keys)
end

function M.prefill_grep_for_filetype()
  M.prefill_grep('--' .. vim.bo.filetype .. ' ~/git', '<S-Left><Space><Left>')
end

function M.prefill_grep_for_notes()
  M.prefill_grep('--md ~/git', '<S-Left><Space><Left>')
end

function M.prefill_grep_for_git_repo()
  local git_root = M.get_git_root()
  if not git_root then
    return false
  end

  M.prefill_grep(M.quote_argument(git_root), '<Home><S-Right><Space>')
  return true
end

function M.prefill_grep_for_current_file()
  M.prefill_grep('%', '<Home><S-Right><Space>')
end

function M.grep_current_word_in_git_repo()
  local git_root = M.get_git_root()
  if not git_root then
    return false
  end

  M.grep(M.get_current_word() .. ' ' .. M.quote_argument(git_root))
  return true
end

function M.grep_current_word_in_current_file()
  M.grep(M.get_current_word() .. ' %')
end

function M.open_git_diff_in_terminal()
  M.run_ex('terminal git --no-pager diff')
end

function M.open_explorer()
  M.run_ex('silent !explorer.exe .')
  M.run_ex('redraw!')
end

function M.open_tables_report()
  M.run_ex('tabe term://' .. M.tables_report_command)
  M.run_ex('$')
end

function M.open_weather_report()
  M.run_ex('tabe term://curl ' .. M.weather_report_url)
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

function M.mani_git_status()
  M.mani([[run git-status --parallel --tags-expr '$MANI_EXPR']])
end

function M.mani_git_up()
  M.mani([[run git-up --parallel --tags-expr '$MANI_EXPR']])
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
