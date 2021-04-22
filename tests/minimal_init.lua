-- load lualine and plenary
vim.api.nvim_exec([[
  set rtp+=.
  set rtp+=../plenary.nvim
]], false)

-- Adding tests to path so require can work
package.path = package.path .. ';./tests/?.lua' .. ';./tests/?/init.lua'
