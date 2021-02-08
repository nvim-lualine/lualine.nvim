local function filename(args)
  -- setting defaults
  local modified, full_name, relative = true, false, true
  if args.modified ~= nil then modified = args.modified end
  if args.full_name ~= nil then full_name = args.full_name end
  if args.relative ~= nil then relative = args.relative end

  return function()
    local data
    if not full_name then
      data = vim.fn.expand('%:t')
    elseif relative then
      data = vim.fn.expand('%')
    else
      data = vim.fn.expand('%:p')
    end
    if data == '' then
      data = '[No Name]'
    elseif vim.fn.winwidth(0) <= 84 or #data > 40 then
      data = vim.fn.pathshorten(data)
    end

    if modified then
      if vim.bo.modified then data = data .. "[+]"
      elseif vim.bo.modifiable == false then data = data .. "[-]" end
    end
    return data
  end
end

return { init = function(args) return filename(args) end, }
