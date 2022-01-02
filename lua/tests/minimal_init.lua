-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

if os.getenv('TEST_COV') then
  require('luacov')
end
-- load lualine and plenary
vim.cmd([[
  set noswapfile
  set rtp+=.
  set rtp+=../plenary.nvim
  set rtp+=../nvim-web-devicons/
  runtime plugin/plenary.vim
]])
