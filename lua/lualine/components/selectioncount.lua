local function selectioncount()
  local mode = vim.fn.mode()
  local lines = math.abs(vim.fn.line('v') - vim.fn.line('.')) + 1
  if mode == 'v' or mode == 'V' then
    local wc = vim.fn.wordcount()
    local bytecount, linecount = '', ''
    if wc.visual_chars ~= wc.visual_bytes then
      bytecount = string.format('-%d', wc.visual_bytes)
    end
    if lines > 1 then
      linecount = string.format(' / %d', lines)
    end
    return string.format('[%d%s%s]', wc.visual_chars, bytecount, linecount)
  elseif mode == '' then
    local cols = vim.fn.virtcol('.') - vim.fn.virtcol('v')
    local line, col
    if cols >= 0 then
      line = vim.fn.getline('v')
      col = vim.fn.charcol('v') - 1
    else
      line = vim.fn.getline('.')
      col = vim.fn.charcol('.') - 1
      cols = -cols
    end
    local char1width = vim.fn.strwidth(vim.fn.strcharpart(line, col, 1))
    return string.format('[%dx%d]', lines, cols + char1width)
  else
    return ''
  end
end

return selectioncount
