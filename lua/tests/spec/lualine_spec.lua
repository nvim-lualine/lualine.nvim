-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local eq = assert.are.same
local statusline = require('tests.statusline').new(120, 'active')

describe('Lualine', function()
  local config
  before_each(function()
    config = {
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
          'diagnostics',
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

    vim.cmd('bufdo bdelete')
    pcall(vim.cmd, 'tabdo tabclose')
    require('lualine').setup(config)
  end)

  it('shows active statusline', function()
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_b_normal = { bg = "#504945", fg = "#a89984" }
        3: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        4: lualine_transitional_lualine_b_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#504945" }
        5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {2:}
    {3:  master }
    {4:}
    {5: [No Name] }
    {5:                                                                      }
    {5:  }
    {4:}
    {3: 100% }
    {2:}
    {1:   0:1  }|
    ]===])
  end)

  it('shows inactive statusline', function()
    local inactive_statusline = statusline.new(120, 'inactive')
    inactive_statusline:expect([===[
    highlights = {
        1: lualine_c_inactive = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: [No Name] }
    {1:                                                                                                     }
    {1:   0:1  }|
    ]===])
  end)

  it('get_config can retrive config', function()
    eq(config, require('lualine').get_config())
  end)

  it('can live update config', function()
    local conf = require('lualine').get_config()
    conf.sections.lualine_a = {}
    require('lualine').setup(conf)
    statusline:expect([===[
    highlights = {
        1: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        2: lualine_transitional_lualine_b_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#504945" }
        3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        4: lualine_transitional_lualine_a_normal_to_lualine_b_normal = { bg = "#504945", fg = "#a89984" }
        5: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
    }
    |{1:  master }
    {2:}
    {3: [No Name] }
    {3:                                                                               }
    {3:  }
    {2:}
    {1: 100% }
    {4:}
    {5:   0:1  }|
    ]===])
  end)

  it('Can work without section separators', function()
    config.options.section_separators = ''
    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {2:  master }
    {3: [No Name] }
    {3:                                                                          }
    {3:  }
    {2: 100% }
    {1:   0:1  }|
    ]===])
  end)

  it('Can work without component_separators', function()
    table.insert(config.sections.lualine_a, function()
      return 'test_comp1'
    end)
    table.insert(config.sections.lualine_z, function()
      return 'test_comp2'
    end)

    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_b_normal = { bg = "#504945", fg = "#a89984" }
        3: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        4: lualine_transitional_lualine_b_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#504945" }
        5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {1: test_comp1 }
    {2:}
    {3:  master }
    {4:}
    {5: [No Name] }
    {5:                                            }
    {5:  }
    {4:}
    {3: 100% }
    {2:}
    {1:   0:1  }
    {1: test_comp2 }|
    ]===])

    config.options.component_separators = ''
    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_b_normal = { bg = "#504945", fg = "#a89984" }
        3: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        4: lualine_transitional_lualine_b_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#504945" }
        5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {1: test_comp1 }
    {2:}
    {3:  master }
    {4:}
    {5: [No Name] }
    {5:                                              }
    {5:  }
    {4:}
    {3: 100% }
    {2:}
    {1:   0:1  }
    {1: test_comp2 }|
    ]===])
  end)

  it('mid divider can be disbled on special case', function()
    config.options.always_divide_middle = false
    config.sections.lualine_x = {}
    config.sections.lualine_y = {}
    config.sections.lualine_z = {}
    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_b_normal = { bg = "#504945", fg = "#a89984" }
        3: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        4: lualine_transitional_lualine_b_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#504945" }
        5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {2:}
    {3:  master }
    {4:}
    {5: [No Name] }|
    ]===])
  end)

  it('works with icons disabled', function()
    config.options.icons_enabled = false
    config.options.section_separators = ''
    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {2: master }
    {3: [No Name] }
    {3:                                                                         }
    {3: unix }
    {2: 100% }
    {1:   0:1  }|
    ]===])
  end)

  it('can be desabled for specific filetypes', function()
    config.options.disabled_filetypes = { 'test_ft' }
    require('lualine').setup(config)
    local old_ft = vim.bo.ft
    vim.bo.ft = 'test_ft'
    statusline:expect([===[
    highlights = {}
    ||
    ]===])
    vim.bo.ft = old_ft
  end)

  it('can apply custom extensions', function()
    table.insert(config.extensions, {
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
    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: custom_extension_component }
    {2:}
    {3:                                                                                           }|
    ]===])
    vim.bo.ft = old_ft
  end)

  it('same extension can be applied to multiple filetypes', function()
    table.insert(config.extensions, {
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
    require('lualine').setup(config)
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: custom_extension_component }
    {2:}
    {3:                                                                                           }|
    ]===])
    vim.bo.ft = old_ft
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_b_normal = { bg = "#504945", fg = "#a89984" }
        3: lualine_b_normal = { bg = "#504945", fg = "#ebdbb2" }
        4: lualine_transitional_lualine_b_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#504945" }
        5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: NORMAL }
    {2:}
    {3:  master }
    {4:}
    {5: [No Name] }
    {5:                                                                      }
    {5:  }
    {4:}
    {3: 100% }
    {2:}
    {1:   0:1  }|
    ]===])

    vim.bo.ft = 'test_ft2'
    statusline:expect([===[
    highlights = {
        1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
        2: lualine_transitional_lualine_a_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    }
    |{1: custom_extension_component }
    {2:}
    {3:                                                                                           }|
    ]===])
    vim.bo.ft = old_ft
  end)

  -- TODO: figure put why some of the tablines tests fail in CI
  -- describe('tabline', function()
  --   local tab_conf = vim.deepcopy(config)
  --   tab_conf.tabline = {
  --     lualine_a = {
  --       function()
  --         return 'tabline_component'
  --       end,
  --     },
  --     lualine_b = {},
  --     lualine_c = {},
  --     lualine_x = {},
  --     lualine_y = {},
  --     lualine_z = {},
  --   }
  --
  --   it('can use tabline', function()
  --     local conf = vim.deepcopy(tab_conf)
  --     conf.tabline.lualine_a = {
  --       function()
  --         return 'tabline_component'
  --       end,
  --     }
  --     require('lualine').setup(conf)
  --     require('lualine').statusline()
  --     eq(
  --       '%#lualine_a_normal# tabline_component %#lualine_transitional_lualine_a_normal_to_lualine_c_normal#%#lualine_c_normal#%=',
  --       require('lualine').tabline()
  --     )
  --   end)
  --
  --   it('can use tabline as statusline', function()
  --     local conf = vim.deepcopy(config)
  --     conf.tabline = conf.sections
  --     conf.sections = {}
  --     conf.inactive_sections = {}
  --     require('lualine').setup(conf)
  --     require('lualine').statusline()
  --     eq('', vim.go.statusline)
  --     eq(
  --       '%#lualine_a_normal# NORMAL %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal# [No Name] %#lualine_c_normal#%=%#lualine_c_normal#  %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# %3p%% %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3l:%-2v ',
  --       require('lualine').tabline()
  --     )
  --   end)
  --   describe('tabs component', function()
  --     it('works', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'tabs', max_length = 1e3 } }
  --       vim.cmd 'tabnew'
  --       vim.cmd 'tabnew'
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       vim.cmd 'tabprev'
  --       eq(
  --         '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_tabs_active_0_no_mode#%#lualine_tabs_active_0_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       vim.cmd 'tabprev'
  --       eq(
  --         '%#lualine_tabs_active_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_tabs_active_0_no_mode#%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_tabs_active_0_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --     it('mode option can change layout', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 0 } }
  --       vim.cmd('tabe ' .. 'a.txt')
  --       vim.cmd('tabe ' .. 'b.txt')
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 1 } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ [No Name] %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ a.txt %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ b.txt %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 2 } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 [No Name] %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 a.txt %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 b.txt %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --   end)
  --
  --   describe('buffers component', function()
  --     it('works', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, icons_enabled = false } }
  --       vim.cmd('tabe ' .. 'a.txt')
  --       vim.cmd('tabe ' .. 'b.txt')
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%5@LualineSwitchBuffer@ b.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       vim.cmd 'tabprev'
  --       eq(
  --         '%#lualine_buffers_active_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%5@LualineSwitchBuffer@ b.txt %T%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       vim.cmd 'tabprev'
  --       eq(
  --         '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_buffers_active_0_no_mode#%5@LualineSwitchBuffer@ b.txt %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --     it('mode option can change layout', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 0, icons_enabled = false } }
  --       vim.cmd('tabe ' .. 'a.txt')
  --       vim.cmd('tabe ' .. 'b.txt')
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_tabs_active_0_no_mode#%1@LualineSwitchTab@ 1 %T%#lualine_tabs_active_0_no_mode#%2@LualineSwitchTab@ 2 %T%#lualine_transitional_lualine_tabs_active_0_no_mode_to_lualine_tabs_active_no_mode#%#lualine_tabs_active_no_mode#%3@LualineSwitchTab@ 3 %T%#lualine_transitional_lualine_tabs_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, mode = 1, icons_enabled = false } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ 4  %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%5@LualineSwitchBuffer@ 5  %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ 6  %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, mode = 2, icons_enabled = false } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_buffers_active_0_no_mode#%4@LualineSwitchBuffer@ 4 a.txt %T%#lualine_transitional_lualine_buffers_active_0_no_mode_to_lualine_buffers_active_no_mode#%#lualine_buffers_active_no_mode#%5@LualineSwitchBuffer@ 5 b.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%6@LualineSwitchBuffer@ 6 [No Name] %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --
  --     it('can show modified status', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_modified_status = true, icons_enabled = false } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ [No Name] %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       vim.bo.modified = true
  --       eq(
  --         '%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ [No Name] + %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --       vim.bo.modified = false
  --     end)
  --
  --     it('can show relative path', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_filename_only = false, icons_enabled = false } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       vim.cmd('e ' .. os.tmpname())
  --       eq(
  --         '%#lualine_buffers_active_no_mode#%6@LualineSwitchBuffer@ '
  --           .. vim.fn.pathshorten(vim.fn.expand '%:p:.')
  --           .. ' %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --
  --     it('can show ellipsis when max_width is crossed', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1 } }
  --       vim.cmd 'tabe a.txt'
  --       vim.cmd 'tabe b.txt'
  --       vim.cmd 'tabprev'
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       eq(
  --         '%#lualine_buffers_active_no_mode#%4@LualineSwitchBuffer@ a.txt %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_buffers_active_0_no_mode#%#lualine_buffers_active_0_no_mode#%5@LualineSwitchBuffer@ ... %T%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --
  --     it('can show filetype icons', function()
  --       local conf = vim.deepcopy(tab_conf)
  --       conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_filename_only = false } }
  --       require('lualine').setup(conf)
  --       require('lualine').statusline()
  --       vim.cmd('e t.lua')
  --       eq(
  --         '%#lualine_buffers_active_no_mode#%7@LualineSwitchBuffer@  t.lua %T%#lualine_transitional_lualine_buffers_active_no_mode_to_lualine_c_normal#%#lualine_c_normal#%=',
  --         require('lualine').tabline()
  --       )
  --     end)
  --
  --   end)
  -- end)
end)
