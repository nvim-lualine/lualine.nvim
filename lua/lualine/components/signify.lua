local function signify()
   local ok, result = pcall(vim.fn['sy#repo#get_stats_decorated'])
   if ok then return result else return '' end
end

return signify
