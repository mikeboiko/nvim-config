-- Fold marker string definition
vim.g.fold_marker_string = '{{{'

-- By default, don't close term after <leader>rr
-- This can be toggled
vim.g.term_close = ''

-- Enable/disable prepending jira issue in git commit message
vim.g.vira_commit_text_enable = ''

if vim.fn.has('mac') == 1 then
  vim.g.python3_host_prog = '/usr/bin/python3'
else
  vim.g.python3_host_prog = '/usr/bin/python'
end

-- Global lua vars
USER = os.getenv('USER')
