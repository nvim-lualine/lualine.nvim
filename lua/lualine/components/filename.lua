local function filename(options)
  -- setting defaults
  local file_status, full_path, relative = true, false, true
  if options.file_status  ~= nil then file_status = options.file_status end
  if options.full_path ~= nil then full_path = options.full_path end
  if options.relative  ~= nil then relative = options.relative end

  return function()
    local data
    if not full_path then
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

    if file_status then
      if vim.bo.modified then data = data .. "[+]"
      elseif vim.bo.modifiable == false then data = data .. "[-]" end
    end
    return data
  end
end

return { init = function(options) return filename(options) end, }
