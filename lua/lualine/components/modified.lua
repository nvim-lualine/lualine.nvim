local function Modified()
   if (vim.bo.modified) then
      return "+"
   else
      return ""
   end
end

return Modified
