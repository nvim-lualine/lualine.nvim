-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local eq = assert.are.same
local statusline = require('tests.statusline').new(120, 'active')
local inactive_statusline = statusline.new(120, 'inactive')
local tabline = statusline.new(120, 'tabline')

describe('Lualine', function()
  local config
  before_each(function()
    config = {
      options = {
        icons_enabled = true,
        theme = 'gruvbox',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
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
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    }

    vim.opt.swapfile = false
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
    highlights = {
        1: StatusLine = { bold = true, reverse = true }
    }
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
      tabline:expect([===[
      highlights = {
          1: lualine_a_normal = { bg = "#a89984", bold = true, fg = "#282828" }
          2: lualine_transitional_lualine_a_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
          3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
      }
      |{1: tabline_component }
      {2:}
      {3:                                                                                                    }|
      ]===])
    end)

    it('can use tabline as statusline', function()
      local conf = vim.deepcopy(config)
      conf.tabline = conf.sections
      conf.sections = {}
      conf.inactive_sections = {}
      require('lualine').setup(conf)
      require('lualine').statusline()
      eq('%#Normal#', vim.go.statusline)

      tabline:expect([===[
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
    describe('tabs component', function()
      it('works', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3 } }
        vim.cmd('tabnew')
        vim.cmd('tabnew')
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 }
        {1: 2 }
        {2:}
        {3: 3 }
        {4:}
        {5:                                                                                                            }|
        ]===])

        vim.cmd('tabprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_a_tabs_inactive = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 }
        {2:}
        {3: 2 }
        {4:}
        {1: 3 }
        {5:                                                                                                             }|
        ]===])

        vim.cmd('tabprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_tabs_active_to_lualine_a_tabs_inactive = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            4: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 }
        {2:}
        {3: 2 }
        {3: 3 }
        {4:                                                                                                             }|
        ]===])
      end)

      it('mode option can change layout', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 0 } }
        vim.cmd('tabe ' .. 'a.txt')
        vim.cmd('tabe ' .. 'b.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 }
        {1: 2 }
        {2:}
        {3: 3 }
        {4:}
        {5:                                                                                                            }|
        ]===])

        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 }
        {1: 2 }
        {2:}
        {3: 3 }
        {4:}
        {5:                                                                                                            }|
        ]===])

        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 1 } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: [No Name] }
        {1: a.txt }
        {2:}
        {3: b.txt }
        {4:}
        {5:                                                                                            }|
        ]===])

        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 2 } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 [No Name] }
        {1: 2 a.txt }
        {2:}
        {3: 3 b.txt }
        {4:}
        {5:                                                                                      }|
        ]===])
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
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_a_buffers_inactive = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: #a.txt }
        {2:}
        {3: b.txt }
        {4:}
        {1: [No Name] }
        {MATCH:{5:%s+}|}
        ]===])

        vim.cmd('tabprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_a_buffers_inactive = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            4: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: a.txt }
        {2:}
        {3: b.txt }
        {3: #[No Name] }
        {MATCH:{4:%s+}|}
        ]===])

        vim.cmd('tabprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: a.txt }
        {1: #b.txt }
        {2:}
        {3: [No Name] }
        {4:}
        {MATCH:{5:%s+}|}
        ]===])
      end)

      it('mode option can change layout', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'tabs', max_length = 1e3, mode = 0, icons_enabled = false } }
        vim.cmd('tabe ' .. 'a.txt')
        vim.cmd('tabe ' .. 'b.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        {MATCH:|{1: %d+ }}
        {MATCH:{1: %d+ }}
        {2:}
        {MATCH:{3: %d+ }}
        {4:}
        {MATCH:{5:%s+}|}
        ]===])

        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, mode = 1, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_a_buffers_inactive = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        {MATCH:|{1: #%d+  }}
        {2:}
        {MATCH:{3: %d+  }}
        {4:}
        {MATCH:{1: %d+  }}
        {MATCH:{5:%s+}|}
        ]===])

        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, mode = 2, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_a_buffers_inactive = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        {MATCH:|{1: #%d+ a.txt }}
        {2:}
        {MATCH:{3: %d+ b.txt }}
        {4:}
        {MATCH:{1: %d+ %[No Name%] }}
        {MATCH:{5:%s+}|}
        ]===])
      end)

      it('can show modified status', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_modified_status = true, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: [No Name] }
        {2:}
        {3:                                                                                                            }|
        ]===])

        vim.bo.modified = true
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: [No Name] ● }
        {2:}
        {3:                                                                                                          }|
        ]===])
        vim.bo.modified = false
      end)

      it('can show relative path', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_filename_only = false, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        local path = 'aaaaaa/bbbbb/cccccc/ddddd/eeeee/ffff/gggg'
        vim.fn.mkdir(path, 'p')
        vim.cmd('e ' .. path .. '/asdf.txt')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: a/b/c/d/e/f/g/asdf.txt }
        {2:}
        {3:                                                                                               }|
        ]===])
        vim.fn.delete(path:match('(%w+)/.*'), 'rf')
      end)

      it('can show ellipsis when max_width is crossed', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1 } }
        vim.cmd('tabe a.txt')
        vim.cmd('tabe b.txt')
        vim.cmd('tabprev')
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_a_buffers_inactive = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            4: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1:  a.txt }
        {2:}
        {3: ... }
        {4:                                                                                                         }|
        ]===])
      end)

      it('can show filetype icons', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', max_length = 1e3, show_filename_only = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        vim.cmd('e t.lua')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1:  t.lua }
        {2:}
        {3:                                                                                                              }|
        ]===])
      end)

      it('can show buffer numbers instead of indices (without file names)', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', mode = 3, max_length = 1e3, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        vim.cmd('e a.txt')
        vim.cmd('silent! bd #') -- NeoVim 0.5 does not create an unnamed buffer. This ensures consistent results between NeoVim versions.
        vim.cmd('e b.txt')
        local bufnr_a = vim.fn.bufnr('a.txt')
        local bufnr_b = vim.fn.bufnr('b.txt')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: #]===] .. bufnr_a .. [===[  }
        {2:}
        {3: ]===] .. bufnr_b .. [===[  }
        {4:}
        {MATCH:{5:%s+}|}
        ]===])
      end)

      it('can show buffer numbers instead of indices (with file names)', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', mode = 4, max_length = 1e3, icons_enabled = false } }
        vim.cmd('e a.txt')
        vim.cmd('silent! bd #') -- NeoVim 0.5 does not create an unnamed buffer. This ensures consistent results between NeoVim versions.
        vim.cmd('e b.txt')
        local bufnr_a = vim.fn.bufnr('a.txt')
        local bufnr_b = vim.fn.bufnr('b.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: #]===] .. bufnr_a .. [===[ a.txt }
        {2:}
        {3: ]===] .. bufnr_b .. [===[ b.txt }
        {4:}
        {MATCH:{5:%s+}|}
        ]===])
      end)

      it('displays alternate buffer correctly when switching buffers', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'buffers', mode = 3, max_length = 1e3, icons_enabled = false } }
        require('lualine').setup(conf)
        require('lualine').statusline()
        vim.cmd('e a.txt')
        vim.cmd('silent! bd #') -- NeoVim 0.5 does not create an unnamed buffer. This ensures consistent results between NeoVim versions.
        vim.cmd('e b.txt')
        local bufnr_a = vim.fn.bufnr('a.txt')
        local bufnr_b = vim.fn.bufnr('b.txt')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: #]===] .. bufnr_a .. [===[  }
        {2:}
        {3: ]===] .. bufnr_b .. [===[  }
        {4:}
        {MATCH:{5:%s+}|}
        ]===])
        vim.cmd('e a.txt')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_buffers_active_to_lualine_a_buffers_inactive = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            4: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: ]===] .. bufnr_a .. [===[  }
        {2:}
        {3: #]===] .. bufnr_b .. [===[  }
        {MATCH:{4:%s+}|}
        ]===])
        vim.cmd('bprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_buffers_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            2: lualine_transitional_lualine_a_buffers_inactive_to_lualine_a_buffers_active = { bg = "#a89984", fg = "#3c3836" }
            3: lualine_a_buffers_active = { bg = "#a89984", bold = true, fg = "#282828" }
            4: lualine_transitional_lualine_a_buffers_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: #]===] .. bufnr_a .. [===[  }
        {2:}
        {3: ]===] .. bufnr_b .. [===[  }
        {4:}
        {MATCH:{5:%s+}|}
        ]===])
      end)
    end)

    describe('windows component', function()
      it('works', function()
        local conf = vim.deepcopy(tab_conf)
        conf.tabline.lualine_a = { { 'windows', max_length = 1e3, mode = 2, icons_enabled = false } }
        vim.cmd('e ' .. 'a.txt')
        vim.cmd('tabe ' .. 'b.txt')
        vim.cmd('vsplit ' .. 'c.txt')
        vim.cmd('tabe ' .. 'd.txt')
        require('lualine').setup(conf)
        require('lualine').statusline()
        tabline:expect([===[
        highlights = {
            1: lualine_a_windows_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_windows_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 d.txt }
        {2:}
        {3:                                                                                                              }|
        ]===])

        vim.cmd('tabprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_windows_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_windows_active_to_lualine_a_windows_inactive = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_a_windows_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
            4: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 c.txt }
        {2:}
        {3: 2 b.txt }
        {4:                                                                                                     }|
        ]===])

        vim.cmd('tabprev')
        tabline:expect([===[
        highlights = {
            1: lualine_a_windows_active = { bg = "#a89984", bold = true, fg = "#282828" }
            2: lualine_transitional_lualine_a_windows_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
            3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
        }
        |{1: 1 a.txt }
        {2:}
        {3:                                                                                                              }|
        ]===])
      end)
    end)
  end)

  describe('diagnostics', function()
    local diagnostics_conf = vim.deepcopy(config)
    diagnostics_conf.sections = {
      lualine_a = {
        {
          'diagnostics',
          symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
          diagnostics_color = {
            error = { bg = '#a89984', fg = '#ff0000' },
            warn = { bg = '#a89984', fg = '#ffa500' },
            info = { bg = '#a89984', fg = '#add8e6' },
            hint = { bg = '#a89984', fg = '#d3d3d3' },
          },
          sources = {
            function()
              return {}
            end,
          },
        },
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    }

    it('does not show without diagnostics', function()
      local conf = vim.deepcopy(diagnostics_conf)
      require('lualine').setup(conf)
      statusline:expect([===[
      highlights = {
          1: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
      }
      |{1:                                                                                                                        }|
      ]===])
    end)

    it('shows only positive diagnostics', function()
      local conf = vim.deepcopy(diagnostics_conf)
      conf.sections.lualine_a[1].sources[1] = function()
        return { error = 0, warn = 0, info = 1, hint = 0 }
      end
      require('lualine').setup(conf)
      statusline:expect([===[
      highlights = {
          1: lualine_a_diagnostics_info = { bg = "#a89984", fg = "#add8e6" }
          2: lualine_transitional_lualine_a_diagnostics_info_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
          3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
      }
      |{1: I:1 }
      {2:}
      {3:                                                                                                                  }|
      ]===])
    end)

    it('shows all diagnostics with same background', function()
      local conf = vim.deepcopy(diagnostics_conf)
      conf.sections.lualine_a[1].sources[1] = function()
        return { error = 1, warn = 2, info = 3, hint = 4 }
      end
      require('lualine').setup(conf)
      statusline:expect([===[
      highlights = {
          1: lualine_a_diagnostics_error = { bg = "#a89984", fg = "#ff0000" }
          2: lualine_a_diagnostics_warn = { bg = "#a89984", fg = "#ffa500" }
          3: lualine_a_diagnostics_info = { bg = "#a89984", fg = "#add8e6" }
          4: lualine_a_diagnostics_hint = { bg = "#a89984", fg = "#d3d3d3" }
          5: lualine_transitional_lualine_a_diagnostics_hint_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
          6: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
      }
      |{1: E:1 }
      {2:W:2 }
      {3:I:3 }
      {4:H:4 }
      {5:}
      {6:                                                                                                      }|
      ]===])
    end)

    it('shows all diagnostics with padding when background changes', function()
      local conf = vim.deepcopy(diagnostics_conf)
      conf.sections.lualine_a[1].sources[1] = function()
        return { error = 1, warn = 2, info = 3, hint = 4 }
      end
      conf.sections.lualine_a[1].diagnostics_color = {
        error = { bg = '#ff0000', fg = '#a89984' },
        warn = { bg = '#ffa500', fg = '#a89984' },
        info = { bg = '#add8e6', fg = '#a89984' },
        hint = { bg = '#add8e6', fg = '#a89984' },
      }
      require('lualine').setup(conf)
      statusline:expect([===[
      highlights = {
          1: lualine_a_diagnostics_error = { bg = "#ff0000", fg = "#a89984" }
          2: lualine_a_diagnostics_warn = { bg = "#ffa500", fg = "#a89984" }
          3: lualine_a_diagnostics_info = { bg = "#add8e6", fg = "#a89984" }
          4: lualine_a_diagnostics_hint = { bg = "#add8e6", fg = "#a89984" }
          5: lualine_transitional_lualine_a_diagnostics_hint_to_lualine_c_normal = { bg = "#3c3836", fg = "#add8e6" }
          6: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
      }
      |{1: E:1 }
      {2: W:2 }
      {3: I:3 }
      {4:H:4 }
      {5:}
      {6:                                                                                                    }|
      ]===])
    end)
  end)
end)
