local function selectioncount()
  local mode = vim.fn.mode(true)
  local pos_start = vim.fn.getpos('v')
  local pos_end = vim.fn.getpos('.')
  local line_start, col_start = pos_start[2], pos_start[3] + pos_start[4]
  local line_end, col_end = pos_end[2], pos_end[3] + pos_end[4]
  if mode:match('') then
    return string.format('%dx%d', math.abs(line_start - line_end) + 1, math.abs(col_start - col_end) + 1)
  elseif mode:match('V') or line_start ~= line_end then
    return math.abs(line_start - line_end) + 1
  elseif mode:match('v') then
    return math.abs(col_start - col_end) + 1
  else
    return ''
  end
end

return selectioncount
