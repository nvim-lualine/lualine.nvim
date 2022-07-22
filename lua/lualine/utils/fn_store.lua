local M = {}
local fns = {}

---Store fn with id in fns so it can be later called
---@param id integer component id (for now we are only doing one fn per component)
---@param fn function the actual function to store.
---@return number same id that was provided.
function M.register_fn(id, fn)
  vim.validate {
    id = { id, 'n' },
    fn = { fn, 'f' },
  }
  fns[id] = fn
  return id
end

---Get the function with id
---@param id number id of the fn to retrive
---@return function
function M.get_fn(id)
  vim.validate { id = { id, 'n' } }
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
