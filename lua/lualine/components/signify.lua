local function signify()
   if vim.fn.exists('*sy#repo#get_stats') == 0 then return '' end
   local added, modified, removed = unpack(vim.fn['sy#repo#get_stats']())
   if added == -1 then added = 0 end
   if modified == -1 then modified = 0 end
   if removed == -1 then removed = 0 end
   return '+' .. added .. ' ~'.. modified .. ' -' .. removed
end

return signify
