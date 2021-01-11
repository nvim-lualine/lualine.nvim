local function signify()
   if vim.fn.exists('*sy#repo#get_stats') == 0 then return '' end
   local added, modified, removed = unpack(vim.fn['sy#repo#get_stats']())
   if added == -1 then return '' end
   local data = {
    '+'..added,
    '-'..removed,
    '~'..modified,
   }
  return table.concat(data, ' ')
end

return signify
