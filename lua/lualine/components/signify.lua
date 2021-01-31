local function signify()
   if vim.fn.exists('*sy#repo#get_stats') == 0 then return '' end
   local added, modified, removed = unpack(vim.fn['sy#repo#get_stats']())
   if added == -1 then return '' end
   local symbols = {
     '+',
     '-',
     '~',
   }
   local result = {}
   local data = {
    added,
    removed,
    modified,
   }
   for range=1,3 do
     if data[range] ~= nil and data[range] > 0
       then table.insert(result,symbols[range]..' '..data[range]..' ')
     end
   end

   if result[1] ~= nil then
       return table.concat(result, '')
   else
       return ''
   end
end


return signify
