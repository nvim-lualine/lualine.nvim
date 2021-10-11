-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local helpers = require 'tests.helpers'

local eq = assert.are.same
local neq = assert.are_not.same
local assert_component = helpers.assert_component
local build_component_opts = helpers.build_component_opts
local stub = require 'luassert.stub'

describe('Component:', function()
  it('can select separators', function()
    local opts = build_component_opts()
    local comp = require 'lualine.components.special.function_component'(opts)
    -- correct for lualine_c
    eq('', comp.options.separator)
    local opts2 = build_component_opts { self = { section = 'lualine_y' } }
    local comp2 = require 'lualine.components.special.function_component'(opts2)
    -- correct for lualine_u
    eq('', comp2.options.separator)
  end)

  it('can provide unique identifier', function()
    local opts1 = build_component_opts()
    local comp1 = require 'lualine.components.special.function_component'(opts1)
    local opts2 = build_component_opts()
    local comp2 = require 'lualine.components.special.function_component'(opts2)
    neq(comp1.component_no, comp2.component_no)
  end)

  it('create option highlights', function()
    local color = { fg = '#224532', bg = '#892345' }
    local opts1 = build_component_opts { color = color }
    local hl = require 'lualine.highlight'
    stub(hl, 'create_component_highlight_group')
    hl.create_component_highlight_group.returns 'MyCompHl'
    local comp1 = require 'lualine.components.special.function_component'(opts1)
    eq('MyCompHl', comp1.options.color_highlight)
    -- color highlight wan't in options when create_comp_hl was
    -- called so remove it before assert
    comp1.options.color_highlight = nil
    assert.stub(hl.create_component_highlight_group).was_called_with(color, comp1.options.component_name, comp1.options)
    hl.create_component_highlight_group:revert()
    color = 'MyHl'
    local opts2 = build_component_opts { color = color }
    stub(hl, 'create_component_highlight_group')
    hl.create_component_highlight_group.returns 'MyCompLinkedHl'
    local comp2 = require 'lualine.components.special.function_component'(opts2)
    eq('MyCompLinkedHl', comp2.options.color_highlight)
    -- color highlight wan't in options when create_comp_hl was
    -- called so remove it before assert
    comp2.options.color_highlight = nil
    assert.stub(hl.create_component_highlight_group).was_called_with(color, comp2.options.component_name, comp2.options)
    hl.create_component_highlight_group:revert()
  end)

  it('can draw', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component(nil, opts, 'test')
  end)

  it('can apply separators', function()
    local opts = build_component_opts { padding = 0 }
    assert_component(nil, opts, 'test')
  end)

  it('can apply default highlight', function()
    local opts = build_component_opts { padding = 0, hl = '%#My_highlight#' }
    assert_component(nil, opts, '%#My_highlight#test')
    opts = build_component_opts {
      function()
        return '%#Custom_hl#test'
      end,
      padding = 0,
      hl = '%#My_highlight#',
    }
    assert_component(nil, opts, '%#Custom_hl#test%#My_highlight#')
    opts = build_component_opts {
      function()
        return 'in middle%#Custom_hl#test'
      end,
      padding = 0,
      hl = '%#My_highlight#',
    }
    assert_component(nil, opts, '%#My_highlight#in middle%#Custom_hl#test%#My_highlight#')
  end)

  describe('Global options:', function()
    it('left_padding', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = { left = 5 },
      }
      assert_component(nil, opts, '     test')
    end)

    it('right_padding', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = { right = 5 },
      }
      assert_component(nil, opts, 'test     ')
    end)

    it('padding', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 5,
      }
      assert_component(nil, opts, '     test     ')
    end)

    it('icon', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        icon = '0',
      }
      assert_component(nil, opts, '0 test')
    end)

    it('icons_enabled', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        icons_enabled = true,
        icon = '0',
      }
      assert_component(nil, opts, '0 test')
      local opts2 = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        icons_enabled = false,
        icon = '0',
      }
      assert_component(nil, opts2, 'test')
    end)

    it('separator', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        separator = '|',
      }
      assert_component(nil, opts, 'test|')
    end)

    it('fmt', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        fmt = function(data)
          return data:sub(1, 1):upper() .. data:sub(2, #data)
        end,
      }
      assert_component(nil, opts, 'Test')
    end)

    it('cond', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        cond = function()
          return true
        end,
      }
      assert_component(nil, opts, 'test')
      local opts2 = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        cond = function()
          return false
        end,
      }
      assert_component(nil, opts2, '')
    end)

    it('color', function()
      local opts = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        color = 'MyHl',
      }
      local comp = require 'lualine.components.special.function_component'(opts)
      local custom_link_hl_name = 'lualine_' .. comp.options.component_name .. '_no_mode'
      eq('%#' .. custom_link_hl_name .. '#test', comp:draw(opts.hl))
      local opts2 = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        color = { bg = '#230055', fg = '#223344' },
      }
      local hl = require 'lualine.highlight'
      stub(hl, 'component_format_highlight')
      hl.component_format_highlight.returns '%#MyCompHl#'
      local comp2 = require 'lualine.components.special.function_component'(opts2)
      assert_component(nil, opts2, '%#MyCompHl#test')
      assert.stub(hl.component_format_highlight).was_called_with(comp2.options.color_highlight)
      hl.component_format_highlight:revert()
    end)
  end)
end)

describe('Encoding component', function()
  it('works', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('encoding', opts, '%{strlen(&fenc)?&fenc:&enc}')
  end)
end)

describe('Fileformat component', function()
  it('works with icons', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    local fmt = vim.bo.fileformat
    vim.bo.fileformat = 'unix'
    assert_component('fileformat', opts, '')
    vim.bo.fileformat = 'dos'
    assert_component('fileformat', opts, '')
    vim.bo.fileformat = 'mac'
    assert_component('fileformat', opts, '')
    vim.bo.fileformat = fmt
  end)
  it('works without icons', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      icons_enabled = false,
    }
    assert_component('fileformat', opts, vim.bo.fileformat)
  end)
end)

describe('Filetype component', function()
  local filetype

  before_each(function()
    filetype = vim.bo.filetype
    vim.bo.filetype = 'lua'
  end)

  after_each(function()
    vim.bo.filetype = filetype
  end)

  it('does not add icon when library unavailable', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('filetype', opts, 'lua')
  end)

  it('colors nvim-web-devicons icons', function()
    package.loaded['nvim-web-devicons'] = {
      get_icon = function()
        return '*', 'test_highlight_group'
      end,
    }

    local hl = require 'lualine.highlight'
    local utils = require 'lualine.utils.utils'
    stub(hl, 'create_component_highlight_group')
    stub(utils, 'extract_highlight_colors')
    hl.create_component_highlight_group.returns 'MyCompHl'
    utils.extract_highlight_colors.returns '#000'

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = true,
      icon_only = false,
    }
    assert_component('filetype', opts, '%#MyCompHl_normal#*%#lualine_c_normal# lua')
    assert.stub(utils.extract_highlight_colors).was_called_with('test_highlight_group', 'fg')
    assert.stub(hl.create_component_highlight_group).was_called_with({ fg = '#000' }, 'test_highlight_group', opts)
    hl.create_component_highlight_group:revert()
    utils.extract_highlight_colors:revert()
    package.loaded['nvim-web-devicons'] = nil
  end)

  it("Doesn't color when colored is false", function()
    package.loaded['nvim-web-devicons'] = {
      get_icon = function()
        return '*', 'test_highlight_group'
      end,
    }
    local hl = require 'lualine.highlight'
    local utils = require 'lualine.utils.utils'
    stub(hl, 'create_component_highlight_group')
    stub(utils, 'extract_highlight_colors')
    hl.create_component_highlight_group.returns 'MyCompHl'
    utils.extract_highlight_colors.returns '#000'
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = false,
    }
    assert_component('filetype', opts, '* lua')
    hl.create_component_highlight_group:revert()
    utils.extract_highlight_colors:revert()
    package.loaded['nvim-web-devicons'] = nil
  end)

  it('displays only icon when icon_only is true', function()
    package.loaded['nvim-web-devicons'] = {
      get_icon = function()
        return '*', 'test_highlight_group'
      end,
    }

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = false,
      icon_only = true,
    }
    assert_component('filetype', opts, '*')
    package.loaded['nvim-web-devicons'] = nil
  end)
end)

describe('Hostname component', function()
  it('works', function()
    stub(vim.loop, 'os_gethostname')
    vim.loop.os_gethostname.returns 'localhost'
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('hostname', opts, 'localhost')
    vim.loop.os_gethostname:revert()
  end)
end)

describe('Location component', function()
  it('works', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('location', opts, '%3l:%-2c')
  end)
end)

describe('Progress component', function()
  it('works', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('progress', opts, '%3P')
  end)
end)

describe('Mode component', function()
  it('works', function()
    stub(vim.api, 'nvim_get_mode')
    vim.api.nvim_get_mode.returns { mode = 'n', blocking = false }
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('mode', opts, 'NORMAL')
    vim.api.nvim_get_mode:revert()
  end)
end)
