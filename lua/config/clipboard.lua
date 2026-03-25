local M = {}

function M.clipboard_targets()
  return vim.fn.systemlist('xclip -selection clipboard -t TARGETS -o')
end

function M.has_image_target()
  for _, target in ipairs(M.clipboard_targets()) do
    if target == 'application/x-qt-image' then
      return true
    end
  end

  return false
end

function M.markdown_clipboard_image()
  return vim.fn['mdip#MarkdownClipboardImage']()
end

function M.paste_text()
  local lines = vim.fn.getreg('+', 1, true)

  if #lines == 0 then
    return false
  end

  vim.api.nvim_put(lines, 'l', true, false)
  return true
end

function M.paste_clipboard()
  if M.has_image_target() then
    M.markdown_clipboard_image()
    return 'image'
  end

  M.paste_text()
  return 'text'
end

function M.copy_current_file_path()
  local path = vim.fn.expand('%:p:~')
  vim.fn.setreg('+', path)
  return path
end

function M.copy_current_file_dir()
  local path = vim.fn.expand('%:p:~:h')
  vim.fn.setreg('+', path)
  return path
end

return M
