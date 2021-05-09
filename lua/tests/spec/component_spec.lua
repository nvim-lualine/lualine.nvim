local helpers = require 'tests.helpers'

local eq = assert.are.same
local neq = assert.are_not.same
local assert_component = helpers.assert_component
local build_component_opts = helpers.build_component_opts
local stub = require 'luassert.stub'

describe('Component:', function()
  it('can select separators', function()
    local opts = build_component_opts()
    local comp = require('lualine.components.special.function_component'):new(
                     opts)
    -- correct for lualine_c
    eq('', comp.options.separator)
    local opts2 = build_component_opts({self = {section = 'lualine_y'}})
    local comp2 = require('lualine.components.special.function_component'):new(
                      opts2)
    -- correct for lualine_u
    eq('', comp2.options.separator)
  end)

  it('can provide unique identifier', function()
    local opts1 = build_component_opts()
    local comp1 = require('lualine.components.special.function_component'):new(
                      opts1)
    local opts2 = build_component_opts()
    local comp2 = require('lualine.components.special.function_component'):new(
                      opts2)
    neq(comp1.component_no, comp2.component_no)
  end)

  it('create option highlights', function()
    local color = {fg = '#224532', bg = '#892345'}
    local opts1 = build_component_opts({color = color})
    local hl = require 'lualine.highlight'
    stub(hl, 'create_component_highlight_group')
    hl.create_component_highlight_group.returns('MyCompHl')
    local comp1 = require('lualine.components.special.function_component'):new(
                      opts1)
    eq('MyCompHl', comp1.options.color_highlight)
    -- color highlight wan't in options when create_comp_hl was
    -- called so remove it before assert
    comp1.options.color_highlight = nil
    assert.stub(hl.create_component_highlight_group).was_called_with(color,
                                                                     comp1.options
                                                                         .component_name,
                                                                     comp1.options)
    hl.create_component_highlight_group:revert()
    local opts2 = build_component_opts({color = 'MyHl'})
    local comp2 = require('lualine.components.special.function_component'):new(
                      opts2)
    eq('MyHl', comp2.options.color_highlight_link)
  end)

  it('can draw', function()
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
    assert_component(nil, opts, 'test')
  end)

  it('can apply separators', function()
    local opts = build_component_opts({padding = 0})
    assert_component(nil, opts, 'test')
  end)

  it('can apply default highlight', function()
    local opts = build_component_opts({padding = 0, hl = '%#My_highlight#'})
    assert_component(nil, opts, 'test%#My_highlight#')
  end)

  describe('Global options:', function()
    it('upper', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        upper = true
      })
      assert_component(nil, opts, 'TEST')
    end)

    it('lower', function()
      local opts = build_component_opts({
        function() return 'TeSt' end,
        component_separators = {'', ''},
        padding = 0,
        lower = true
      })
      assert_component(nil, opts, 'test')
    end)

    it('left_padding', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        left_padding = 5
      })
      assert_component(nil, opts, '     test')
    end)

    it('right_padding', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        right_padding = 5
      })
      assert_component(nil, opts, 'test     ')
    end)

    it('padding', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 5
      })
      assert_component(nil, opts, '     test     ')
    end)

    it('icon', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        icon = '0'
      })
      assert_component(nil, opts, '0 test')
    end)

    it('icons_enabled', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        icons_enabled = true,
        icon = '0'
      })
      assert_component(nil, opts, '0 test')
      local opts2 = build_component_opts(
                        {
            component_separators = {'', ''},
            padding = 0,
            icons_enabled = false,
            icon = '0'
          })
      assert_component(nil, opts2, 'test')
    end)

    it('separator', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        separator = '|'
      })
      assert_component(nil, opts, 'test|')
    end)

    it('format', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        format = function(data)
          return data:sub(1, 1):upper() .. data:sub(2, #data)
        end
      })
      assert_component(nil, opts, 'Test')
    end)

    it('condition', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        condition = function() return true end
      })
      assert_component(nil, opts, 'test')
      local opts2 = build_component_opts(
                        {
            component_separators = {'', ''},
            padding = 0,
            condition = function() return false end
          })
      assert_component(nil, opts2, '')
    end)

    it('color', function()
      local opts = build_component_opts({
        component_separators = {'', ''},
        padding = 0,
        color = 'MyHl'
      })
      assert_component(nil, opts, '%#MyHl#test')
      local opts2 = build_component_opts(
                        {
            component_separators = {'', ''},
            padding = 0,
            color = {bg = '#230055', fg = '#223344'}
          })
      local hl = require 'lualine.highlight'
      stub(hl, 'component_format_highlight')
      hl.component_format_highlight.returns('%#MyCompHl#')
      local comp2 =
          require('lualine.components.special.function_component'):new(opts2)
      assert_component(nil, opts2, '%#MyCompHl#test')
      assert.stub(hl.component_format_highlight).was_called_with(
          comp2.options.color_highlight)
      hl.component_format_highlight:revert()
    end)
  end)
end)

describe('Encoding component', function()
  it('works', function()
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
    assert_component('encoding', opts, '%{strlen(&fenc)?&fenc:&enc}')
  end)
end)

describe('Fileformat component', function()
  it('works with icons', function()
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
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
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0,
      icons_enabled = false
    })
    assert_component('fileformat', opts, vim.bo.fileformat)
  end)
end)

describe('Hostname component', function()
  it('works', function()
    stub(vim.loop, 'os_gethostname')
    vim.loop.os_gethostname.returns('localhost')
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
    assert_component('hostname', opts, 'localhost')
    vim.loop.os_gethostname:revert()
  end)
end)

describe('Location component', function()
  it('works', function()
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
    assert_component('location', opts, '%3l:%-2c')
  end)
end)

describe('Progress component', function()
  it('works', function()
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
    assert_component('progress', opts, '%3P')
  end)
end)

describe('Mode component', function()
  it('works', function()
    stub(vim.api, 'nvim_get_mode')
    vim.api.nvim_get_mode.returns({mode = 'n', blocking = false})
    local opts = build_component_opts({
      component_separators = {'', ''},
      padding = 0
    })
    assert_component('mode', opts, 'NORMAL')
    vim.api.nvim_get_mode:revert()
  end)
end)
