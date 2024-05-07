local M = require('lualine.component'):extend()

local default_format = {
  single_line_no_multibyte = '[%c]',
  single_line_multibyte = '[%c-%b]',
  multi_line_no_multibyte = '[%c / %l]',
  multi_line_multibyte = '[%c-%b / %l]',
  visual_block_mode = '[%cx%l]',
}

function M:init(options)
  M.super.init(self, options)
  self.format = vim.tbl_extend('keep', self.options.format or {}, default_format)
end

function M:update_status()
  local mode = vim.fn.mode()
  local lines = math.abs(vim.fn.line('v') - vim.fn.line('.')) + 1
  if mode == 'v' or mode == 'V' then
    local wc = vim.fn.wordcount()
    local is_multibyte = wc.visual_chars ~= wc.visual_bytes
    local is_multiline = lines > 1
    local chars = wc.visual_chars
    if is_multiline then
      if is_multibyte then
        local bytes = wc.visual_bytes
        return self.format.multi_line_multibyte
          :gsub("^%%b", bytes):gsub("([^%%])%%b", "%1"..bytes)
          :gsub("^%%c", chars):gsub("([^%%])%%c", "%1"..chars)
          :gsub("^%%l", lines):gsub("([^%%])%%l", "%1"..lines)
      else
        return self.format.multi_line_no_multibyte
          :gsub("^%%c", chars):gsub("([^%%])%%c", "%1"..chars)
          :gsub("^%%l", lines):gsub("([^%%])%%l", "%1"..lines)
      end
    else
      if is_multibyte then
        local bytes = wc.visual_bytes
        return self.format.single_line_multibyte
          :gsub("^%%b", bytes):gsub("([^%%])%%b", "%1"..bytes)
          :gsub("^%%c", chars):gsub("([^%%])%%c", "%1"..chars)
      else
        return self.format.single_line_no_multibyte
          :gsub("^%%c", chars):gsub("([^%%])%%c", "%1"..chars)
      end
    end
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
    local chars = cols+char1width
    return self.format.visual_block_mode
      :gsub("^%%c", chars):gsub("([^%%])%%c", "%1"..chars)
      :gsub("^%%l", lines):gsub("([^%%])%%l", "%1"..lines)
  else
    return ''
  end
end

return M
