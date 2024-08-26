local function selectioncount()
  local mode = vim.fn.mode(true)
  local line_start = vim.fn.line('v')
  local line_end = vim.fn.line('.')
  local line_num = tostring(math.abs(line_start - line_end) + 1)
  local chars_num = tostring(vim.fn.wordcount()['visual_chars'])
  if mode:match('[vV]') then
    return line_num .. 'x' .. chars_num
  else
    return ''
  end
end

return selectioncount
