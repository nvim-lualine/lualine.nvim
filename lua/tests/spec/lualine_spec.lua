-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local eq = assert.are.same

describe('Lualine', function()
  local utils = require 'lualine.utils.utils'
  local lualine_focused = true
  utils.is_focused = function()
    return lualine_focused
  end

  local config = {
    options = {
      icons_enabled = true,
      theme = 'gruvbox',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {},
      always_divide_middle = true,
    },
    sections = {
      lualine_a = { 'mode' },
      -- We can't test branch component inside lualines repo.
      -- As branch name will differ in pr/CI. We could setup a dummy repo
      -- but plenary doesn't yet support setup() & teardown() so replacing
      -- branch with a dummy component.
      lualine_b = {
        {
          function()
            return 'master'
          end,
          icon = '',
        },
        {
          'diagnostics',
          sources = { 'nvim_lsp', 'coc' },
        },
      },
      lualine_c = { 'filename' },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { 'filename' },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = {},
  }
  before_each(function()
    vim.cmd 'bufdo bdelete'
    pcall(vim.cmd, 'tabdo tabclose')
    lualine_focused = true
    require('lualine').setup(config)
  end)

  it('shows active statusline', function()
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v ',
      require('lualine').statusline()
    )
  end)

  it('shows inactive statusline', function()
    lualine_focused = false
    eq(
      '%<%#lualine_c_inactive# [No Name] %#lualine_c_inactive#%=%#lualine_c_inactive# %3l:%-2v ',
      require('lualine').statusline()
    )
  end)

  it('get_config can retrive config', function()
    eq(config, require('lualine').get_config())
  end)

  it('can live update config', function()
    local conf = require('lualine').get_config()
    conf.sections.lualine_a = {}
    require('lualine').setup(conf)
    eq(
      '%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v ',
      require('lualine').statusline()
    )
  end)

  it('Can work without section separators', function()
    local conf = vim.deepcopy(config)
    conf.options.section_separators = ''
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_b_normal#  master %<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_b_normal# %3p%% %#lualine_a_normal# %3l:%-2v ',
      require('lualine').statusline()
    )
  end)

  it('Can work without component_separators', function()
    local conf = vim.deepcopy(config)
    table.insert(conf.sections.lualine_a, function()
      return 'test_comp1'
    end)
    table.insert(conf.sections.lualine_z, function()
      return 'test_comp2'
    end)
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_a_normal# test_comp1 %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v %#lualine_a_normal# test_comp2 ',
      require('lualine').statusline()
    )
    conf.options.component_separators = ''
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_a_normal# test_comp1 %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v %#lualine_a_normal# test_comp2 ',
      require('lualine').statusline()
    )
  end)

  it('mid divider can be disbled on special case', function()
    local conf = vim.deepcopy(config)
    conf.options.always_divide_middle = false
    conf.sections.lualine_x = {}
    conf.sections.lualine_y = {}
    conf.sections.lualine_z = {}
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] ',
      require('lualine').statusline(true)
    )
  end)

  it('works with icons diabled', function()
    local conf = vim.deepcopy(config)
    conf.options.icons_enabled = false
    conf.options.section_separators = ''
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_b_normal# master %<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal# unix %#lualine_b_normal# %3p%% %#lualine_a_normal# %3l:%-2v ',
      require('lualine').statusline(true)
    )
  end)

  it('can be desabled for specific filetypes', function()
    local conf = vim.deepcopy(config)
    conf.options.disabled_filetypes = { 'test_ft' }
    require('lualine').setup(conf)
    local old_ft = vim.bo.ft
    vim.bo.ft = 'test_ft'
    eq('', require('lualine').statusline(true))
    vim.bo.ft = old_ft
  end)

  it('can apply custom extensions', function()
    local conf = vim.deepcopy(config)
    table.insert(conf.extensions, {
      filetypes = { 'test_ft' },
      sections = {
        lualine_a = {
          function()
            return 'custom_extension_component'
          end,
        },
      },
    })
    local old_ft = vim.bo.ft
    vim.bo.ft = 'test_ft'
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# custom_extension_component %#lualine_transitional_lualine_a_normal_to_lualine_c_normal#%#lualine_c_normal#%=',
      require('lualine').statusline(true)
    )
    vim.bo.ft = old_ft
  end)

  it('same extension can be applied to multiple filetypes', function()
    local conf = vim.deepcopy(config)
    table.insert(conf.extensions, {
      filetypes = { 'test_ft1', 'test_ft2' },
      sections = {
        lualine_a = {
          function()
            return 'custom_extension_component'
          end,
        },
      },
    })
    local old_ft = vim.bo.ft
    vim.bo.ft = 'test_ft1'
    require('lualine').setup(conf)
    eq(
      '%#lualine_a_normal# custom_extension_component %#lualine_transitional_lualine_a_normal_to_lualine_c_normal#%#lualine_c_normal#%=',
      require('lualine').statusline()
    )
    vim.bo.ft = old_ft
    eq(
      '%#lualine_a_normal# NORMAL %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v ',
      require('lualine').statusline()
    )
    vim.bo.ft = 'test_ft2'
    eq(
      '%#lualine_a_normal# custom_extension_component %#lualine_transitional_lualine_a_normal_to_lualine_c_normal#%#lualine_c_normal#%=',
      require('lualine').statusline()
    )
    vim.bo.ft = old_ft
  end)

  describe('tabline', function()
    local tab_conf = vim.deepcopy(config)
    tab_conf.tabline = {
      lualine_a = {
        function()
          return 'tabline_component'
        end,
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    }

    it('can use tabline', function()
      local conf = vim.deepcopy(tab_conf)
      conf.tabline.lualine_a = {
        function()
          return 'tabline_component'
        end,
      }
      require('lualine').setup(conf)
      require('lualine').statusline()
      eq(
        '%#lualine_a_normal# tabline_component %#lualine_transitional_lualine_a_normal_to_lualine_c_normal#%#lualine_c_normal#%=',
        require('lualine').tabline()
      )
    end)

    it('can use tabline as statusline', function()
      local conf = vim.deepcopy(config)
      conf.tabline = conf.sections
      conf.sections = {}
      conf.inactive_sections = {}
      require('lualine').setup(conf)
      require('lualine').statusline()
      eq('', vim.go.statusline)
      eq(
        '%#lualine_a_normal# NORMAL %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v ',
        require('lualine').tabline()
      )
    end)
    describe('tabs component', function()
      it('works', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3 } }
        vim.cmd 'tabnew'
        vim.cmd 'tabnew'
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        vim.cmd 'tabprev'
        eq(
          '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_tabs_active_0_no_mode#%#lualine_tabs_active_0_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        vim.cmd 'tabprev'
        eq(
          '%#lualine_tabs_active_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_tabs_active_0_no_mode#%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_tabs_active_0_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)
      it('mode option can change layout', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 0 } }
        vim.cmd('tabe ' .. 'a.txt')
        vim.cmd('tabe ' .. 'b.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 1 } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ [No Name] %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ a.txt %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ b.txt %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 2 } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 [No Name] %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 a.txt %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 b.txt %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)
    end)

    describe('buffers component', function()
      it('works', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, icons_enabled = false } }
        vim.cmd('tabe ' .. 'a.txt')
        vim.cmd('tabe ' .. 'b.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%5@LualineSwitchBuffer@ b.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        vim.cmd 'tabprev'
        eq(
          '%#lualine_buffers_active_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%5@LualineSwitchBuffer@ b.txt %T%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        vim.cmd 'tabprev'
        eq(
          '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_buffers_active_0_no_mode#%5@LualineSwitchBuffer@ b.txt %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)
      it('mode option can change layout', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 0, icons_enabled = false } }
        vim.cmd('tabe ' .. 'a.txt')
        vim.cmd('tabe ' .. 'b.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, mode = 1, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ 4  %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%5@LualineSwitchBuffer@ 5  %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ 6  %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, mode = 2, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ 4 a.txt %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%5@LualineSwitchBuffer@ 5 b.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ 6 [No Name] %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)

      it('can show modified status', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_modified_status = true, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        vim.bo.modified = true
        eq(
          '%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ [No Name] + %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
        vim.bo.modified = false
      end)

      it('can show relative path', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_filename_only = false, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        vim.cmd('e ' .. os.tmpname())
        eq(
          '%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ '
            .. vim.fn.pathshorten(vim.fn.expand '%:p:.')
            .. ' %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)

      it('can show ellipsis when max_width is crossed', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1 } }
        vim.cmd 'tabe a.txt'
        vim.cmd 'tabe b.txt'
        vim.cmd 'tabprev'
        require('lualine').setup(conf)
        require('lualine').statusline()
        eq(
          '%#lualine_buffers_active_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%5@LualineSwitchBuffer@ ... %T%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)

      it('can show filetype icons', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_filename_only = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        vim.cmd('e t.lua')
        eq(
          '%#lualine_buffers_active_no_mode#%7@LualineSwitchBuffer@  t.lua %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
          require('lualine').tabline()
        )
      end)

    end)
  end)
end)
