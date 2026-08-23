local M = {}
local fns = {}

-- Nvim 0.11 added a positional signature to vim.validate and deprecated the
-- table one. lualine still supports Nvim 0.7, where only the table form
-- exists, so use whichever the running version provides.
local has_positional_validate = vim.fn.has('nvim-0.11') == 1

---Check a value against an expected type, erroring when it doesn't match.
---@param name string name of the value, used in the error message.
---@param value any the value to check.
---@param expected_type string lua type name, e.g. 'number' or 'function'.
local function validate(name, value, expected_type)
  if has_positional_validate then
    vim.validate(name, value, expected_type)
  else
    vim.validate { [name] = { value, expected_type } }
  end
end

---Store fn with id in fns so it can be later called
---@param id integer component id (for now we are only doing one fn per component)
---@param fn function the actual function to store.
---@return number same id that was provided.
function M.register_fn(id, fn)
  validate('id', id, 'number')
  validate('fn', fn, 'function')
  fns[id] = fn
  return id
end

---Get the function with id
---@param id number id of the fn to retrieve
---@return function
function M.get_fn(id)
  validate('id', id, 'number')
  return fns[id] or function() end
end

---Call the function of id with args
---@param id number
---@param ... any
---@return any
function M.call_fn(id, ...)
  return M.get_fn(id)(...)
end

---Clear the fns table
function M.clear_fns()
  fns = {}
end

return M
