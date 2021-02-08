local function location(args)
  -- set when user wants to set a custom icon
  local icons_enabled = args.icons_enabled

  local icon_line_no = '' -- e0a1
  local icon_col_no  = ''  -- e0a3
  -- set when user wants to set a custom icon
  if args.icon then
    if type(args.icon) == 'string' then
      icon_line_no = args.icon
      icon_col_no  = ':'
    elseif type(args.icon) == 'table' then
      icon_line_no = args.icon[1]
      icon_col_no  = args.icon[2]
    end
  end

  return function()
    local line_no,col_no = [[%l]], [[%c]]
    local data
    if icons_enabled then
      data = string.format("%s %s %s %s",icon_line_no, line_no, icon_col_no, col_no)
    else
      data = line_no..':'..col_no
    end
    return data
  end
end

return {init = function(args) return location(args) end,}
