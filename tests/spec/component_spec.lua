-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local helpers = require('tests.helpers')

local eq = assert.are.same
local neq = assert.are_not.same
local assert_component = helpers.assert_component
local build_component_opts = helpers.build_component_opts
local stub = require('luassert.stub')

describe('Component:', function()
  it('can select separators', function()
    local opts = build_component_opts()
    local comp = require('lualine.components.special.function_component')(opts)
    -- correct for lualine_c
    eq('', comp.options.separator)
    local opts2 = build_component_opts { self = { section = 'y' } }
    local comp2 = require('lualine.components.special.function_component')(opts2)
    -- correct for lualine_u
    eq('', comp2.options.separator)
  end)

  it('can provide unique identifier', function()
    local opts1 = build_component_opts()
    local comp1 = require('lualine.components.special.function_component')(opts1)
    local opts2 = build_component_opts()
    local comp2 = require('lualine.components.special.function_component')(opts2)
    neq(comp1.component_no, comp2.component_no)
  end)

  it('create option highlights', function()
    local color = { fg = '#224532', bg = '#892345' }
    local opts1 = build_component_opts { color = color }
    local hl = require('lualine.highlight')
    stub(hl, 'create_component_highlight_group')
    hl.create_component_highlight_group.returns('MyCompHl')
    local comp1 = require('lualine.components.special.function_component')(opts1)
    eq('MyCompHl', comp1.options.color_highlight)
    -- color highlight wan't in options when create_comp_hl was
    -- called so remove it before assert
    comp1.options.color_highlight = nil
    assert.stub(hl.create_component_highlight_group).was_called_with(
      color,
      comp1.options.component_name,
      comp1.options,
      false
    )
    hl.create_component_highlight_group:revert()
    color = 'MyHl'
    local opts2 = build_component_opts { color = color }
    stub(hl, 'create_component_highlight_group')
    hl.create_component_highlight_group.returns('MyCompLinkedHl')
    local comp2 = require('lualine.components.special.function_component')(opts2)
    eq('MyCompLinkedHl', comp2.options.color_highlight)
    -- color highlight wan't in options when create_comp_hl was
    -- called so remove it before assert
    comp2.options.color_highlight = nil
    assert.stub(hl.create_component_highlight_group).was_called_with(
      color,
      comp2.options.component_name,
      comp2.options,
      false
    )
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
      local comp = require('lualine.components.special.function_component')(opts)
      local custom_link_hl_name = 'lualine_c_' .. comp.options.component_name
      eq('%#' .. custom_link_hl_name .. '#test', comp:draw(opts.hl))
      local opts2 = build_component_opts {
        component_separators = { left = '', right = '' },
        padding = 0,
        color = { bg = '#230055', fg = '#223344' },
      }
      local hl = require('lualine.highlight')
      stub(hl, 'component_format_highlight')
      hl.component_format_highlight.returns('%#MyCompHl#')
      local comp2 = require('lualine.components.special.function_component')(opts2)
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
    local tmp_path = 'tmp.txt'
    local tmp_fp = io.open(tmp_path, 'w')
    tmp_fp:write('test file')
    tmp_fp:close()
    vim.cmd('e ' .. tmp_path)
    assert_component('encoding', opts, 'utf-8')
    vim.cmd('bd!')
    os.remove(tmp_path)
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
    local old_require = _G.require
    function _G.require(...)
      if select(1, ...) == 'nvim-web-devicons' then
        error('Test case not suppose to have web-dev-icon 👀')
      end
      return old_require(...)
    end
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('filetype', opts, 'lua')
    _G.require = old_require
  end)

  it('colors nvim-web-devicons icons', function()
    vim.g.actual_curwin = tostring(vim.api.nvim_get_current_win())
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:t').returns('test.lua')

    local hl = require('lualine.highlight')
    stub(hl, 'create_component_highlight_group')
    hl.create_component_highlight_group.returns { name = 'MyCompHl', no_mode = false, section = 'a' }
    stub(hl, 'format_highlight')
    hl.format_highlight.returns('%#lualine_c_normal#')

    local utils = require('lualine.utils.utils')
    stub(utils, 'extract_highlight_colors')
    utils.extract_highlight_colors.returns('#000')

    local devicons = require('nvim-web-devicons')
    stub(devicons, 'get_icon')
    devicons.get_icon.on_call_with('test.lua').returns('*', 'test_highlight_group')

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      hl = '%#lualine_c_normal#',
      padding = 0,
      colored = true,
      icon_only = false,
    }
    assert_component('filetype', opts, '%#MyCompHl_normal#*%#lualine_c_normal# lua%#lualine_c_normal#')
    assert.stub(devicons.get_icon).was_called_with('test.lua')
    assert.stub(utils.extract_highlight_colors).was_called_with('test_highlight_group', 'fg')
    assert.stub(hl.create_component_highlight_group).was_called_with(
      { fg = '#000' },
      'filetype_test_highlight_group',
      opts,
      false
    )
    assert.stub(vim.fn.expand).was_called_with('%:t')

    devicons.get_icon:revert()
    utils.extract_highlight_colors:revert()
    hl.create_component_highlight_group:revert()
    hl.format_highlight:revert()
    vim.fn.expand:revert()
    vim.g.actual_curwin = nil
  end)

  it("doesn't color when colored is false", function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:t').returns('test.lua')

    local hl = require('lualine.highlight')
    stub(hl, 'create_component_highlight_group')

    local utils = require('lualine.utils.utils')
    stub(utils, 'extract_highlight_colors')

    local devicons = require('nvim-web-devicons')
    stub(devicons, 'get_icon')
    devicons.get_icon.on_call_with('test.lua').returns('*', 'test_highlight_group')

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = false,
    }
    assert_component('filetype', opts, '* lua')
    assert.stub(devicons.get_icon).was_called_with('test.lua')
    assert.stub(utils.extract_highlight_colors).was_not_called()
    assert.stub(hl.create_component_highlight_group).was_not_called()
    assert.stub(vim.fn.expand).was_called_with('%:t')

    devicons.get_icon:revert()
    utils.extract_highlight_colors:revert()
    hl.create_component_highlight_group:revert()
    vim.fn.expand:revert()
  end)

  it('displays only icon when icon_only is true', function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:t').returns('test.lua')

    local hl = require('lualine.highlight')
    stub(hl, 'create_component_highlight_group')

    local utils = require('lualine.utils.utils')
    stub(utils, 'extract_highlight_colors')

    local devicons = require('nvim-web-devicons')
    stub(devicons, 'get_icon')
    devicons.get_icon.on_call_with('test.lua').returns('*', 'test_highlight_group')

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = false,
      icon_only = true,
    }
    assert_component('filetype', opts, '*')
    assert.stub(devicons.get_icon).was_called_with('test.lua')
    assert.stub(utils.extract_highlight_colors).was_not_called()
    assert.stub(hl.create_component_highlight_group).was_not_called()
    assert.stub(vim.fn.expand).was_called_with('%:t')

    devicons.get_icon:revert()
    utils.extract_highlight_colors:revert()
    hl.create_component_highlight_group:revert()
    vim.fn.expand:revert()
  end)

  it('displays right aligned icon when icon.align is "right"', function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:t').returns('test.lua')

    local hl = require('lualine.highlight')
    stub(hl, 'create_component_highlight_group')

    local utils = require('lualine.utils.utils')
    stub(utils, 'extract_highlight_colors')

    local devicons = require('nvim-web-devicons')
    stub(devicons, 'get_icon')
    devicons.get_icon.on_call_with('test.lua').returns('*', 'test_highlight_group')

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = false,
      icon_only = false,
      icon = { align = 'right' }
    }
    assert_component('filetype', opts, 'lua *')
    assert.stub(devicons.get_icon).was_called_with('test.lua')
    assert.stub(utils.extract_highlight_colors).was_not_called()
    assert.stub(hl.create_component_highlight_group).was_not_called()
    assert.stub(vim.fn.expand).was_called_with('%:t')

    devicons.get_icon:revert()
    utils.extract_highlight_colors:revert()
    hl.create_component_highlight_group:revert()
    vim.fn.expand:revert()
  end)

  it('uses filetype lookup when file has no extension', function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:t').returns('test')

    local hl = require('lualine.highlight')
    stub(hl, 'create_component_highlight_group')

    local utils = require('lualine.utils.utils')
    stub(utils, 'extract_highlight_colors')

    local devicons = require('nvim-web-devicons')
    stub(devicons, 'get_icon')
    devicons.get_icon.on_call_with('test').returns(nil)
    stub(devicons, 'get_icon_by_filetype')
    devicons.get_icon_by_filetype.on_call_with('lua').returns('*', 'test_highlight_group')

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      colored = false,
      icon_only = false,
    }
    assert_component('filetype', opts, '* lua')
    assert.stub(devicons.get_icon).was_called_with('test')
    assert.stub(devicons.get_icon_by_filetype).was_called_with('lua')
    assert.stub(utils.extract_highlight_colors).was_not_called()
    assert.stub(hl.create_component_highlight_group).was_not_called()
    assert.stub(vim.fn.expand).was_called_with('%:t')

    devicons.get_icon_by_filetype:revert()
    devicons.get_icon:revert()
    utils.extract_highlight_colors:revert()
    hl.create_component_highlight_group:revert()
    vim.fn.expand:revert()
  end)
end)

describe('Hostname component', function()
  it('works', function()
    stub(vim.loop, 'os_gethostname')
    vim.loop.os_gethostname.returns('localhost')
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
    assert_component('location', opts, '  1:1 ')
    vim.cmd('normal! 9o')
    assert_component('location', opts, ' 10:1 ')
    vim.api.nvim_win_set_cursor(0, {5, 0})
    assert_component('location', opts, '  5:1 ')
    -- test column number
    vim.cmd('normal! oTest')
    assert_component('location', opts, '  6:4 ')
    -- test column number in line containing cyrillic symbols
    vim.cmd('normal! oТест')
    assert_component('location', opts, '  7:4 ')
    vim.cmd('bdelete!')
  end)
end)

describe('Progress component', function()
  it('works', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    assert_component('progress', opts, 'Top')
    vim.cmd('normal! 9o')
    assert_component('progress', opts, 'Bot')
    vim.api.nvim_win_set_cursor(0, {5, 0})
    assert_component('progress', opts, '50%%')
    vim.cmd('bdelete!')
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

describe('FileSize component', function()
  it('works', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    local fname = 'test-file.txt'
    local f = io.open(fname, 'w')
    f:write(string.rep('........................................\n', 200))
    f:close()
    vim.cmd(':edit ' .. fname)
    assert_component('filesize', opts, '8.0k')
    vim.cmd(':bdelete!')
    os.remove(fname)
  end)
end)

describe('Filename component', function()
  it('works', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = false,
      path = 0,
    }
    vim.cmd(':e test-file.txt')
    assert_component('filename', opts, 'test-file.txt')
    vim.cmd(':bdelete!')
  end)

  it('can show file_status', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = true,
      path = 0,
    }
    vim.cmd(':e test-file.txt')
    vim.bo.modified = false
    assert_component('filename', opts, 'test-file.txt')
    vim.bo.modified = true
    assert_component('filename', opts, 'test-file.txt [+]')
    vim.bo.ro = true
    assert_component('filename', opts, 'test-file.txt [+][-]')
    vim.bo.modified = false
    assert_component('filename', opts, 'test-file.txt [-]')
    vim.cmd(':bdelete!')
  end)

  it('can show new_file_status', function ()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      newfile_status = true,
      path = 0,
    }
    vim.cmd(':e new-file.txt')
    assert_component('filename', opts, 'new-file.txt [New]')
    vim.bo.modified = true
    assert_component('filename', opts, 'new-file.txt [+][New]')
    vim.cmd(':bdelete!')
  end)

  it('can show relative path', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = false,
      path = 1,
    }
    vim.cmd(':e test-file.txt')
    assert_component('filename', opts, vim.fn.expand('%:~:.'))
    vim.cmd(':bdelete!')
  end)

  it('can show full path', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = false,
      path = 2,
      shorting_target = 0,
    }
    vim.cmd(':e test-file.txt')
    assert_component('filename', opts, vim.fn.expand('%:p'))
    vim.cmd(':bdelete!')
  end)

  it('shortens path', function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:p').returns('/home/foobar/test/test.lua')
    stub(vim.fn, 'winwidth')
    vim.fn.winwidth.on_call_with(0).returns(100)

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = false,
      path = 2,
      shorting_target = 90,
    }
    vim.cmd(':e test-file.txt')
    assert_component('filename', opts, '/h/f/t/test.lua')

    vim.cmd(':bdelete!')
    vim.fn.winwidth:revert()
    vim.fn.expand:revert()
  end)

  it('shortens path with tilde', function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:p:~').returns('~/test/test.lua')
    stub(vim.fn, 'winwidth')
    vim.fn.winwidth.on_call_with(0).returns(100)

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = false,
      path = 3,
      shorting_target = 90,
    }
    vim.cmd(':e test-file.txt')
    assert_component('filename', opts, '~/t/test.lua')

    vim.cmd(':bdelete!')
    vim.fn.winwidth:revert()
    vim.fn.expand:revert()
  end)

  it('shortens path with hidden directory', function()
    stub(vim.fn, 'expand')
    vim.fn.expand.on_call_with('%:p').returns('/home/foobar/.test/test.lua')
    stub(vim.fn, 'winwidth')
    vim.fn.winwidth.on_call_with(0).returns(100)

    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
      file_status = false,
      path = 2,
      shorting_target = 90,
    }
    vim.cmd(':e test-file.txt')
    assert_component('filename', opts, '/h/f/.t/test.lua')

    vim.cmd(':bdelete!')
    vim.fn.winwidth:revert()
    vim.fn.expand:revert()
  end)
end)

describe('vim option & variable component', function()
  local opts = build_component_opts {
    component_separators = { left = '', right = '' },
    padding = 0,
  }

  local function assert_vim_var_component(name, options, result)
    options[1] = name
    assert_component('special.vim_var_component', options, result)
    opts[1] = nil
  end
  it('works with variable', function()
    assert_vim_var_component('g:gvar', opts, '')
    vim.g.gvar = 'var1'
    assert_vim_var_component('g:gvar', opts, 'var1')
    vim.g.gvar = 'var2'
    assert_vim_var_component('g:gvar', opts, 'var2')
    vim.b.gvar = 'bvar1'
    assert_vim_var_component('b:gvar', opts, 'bvar1')
    vim.w.gvar = 'wvar1'
    assert_vim_var_component('w:gvar', opts, 'wvar1')
  end)
  it('can index dictionaries', function()
    vim.g.gvar = { a = { b = 'var-value' } }
    assert_vim_var_component('g:gvar.a.b', opts, 'var-value')
  end)
  it('works with options', function()
    local old_number = vim.wo.number
    vim.wo.number = false
    assert_vim_var_component('wo:number', opts, 'false')
    vim.wo.number = old_number
    local old_tw = vim.go.tw
    vim.go.tw = 80
    assert_vim_var_component('go:tw', opts, '80')
    vim.go.tw = old_tw
  end)
end)

describe('Vim option & variable component', function()
  local opts = build_component_opts {
    component_separators = { left = '', right = '' },
    padding = 0,
  }

  local function assert_vim_var_component(name, options, result)
    options[1] = name
    assert_component('special.eval_func_component', options, result)
    opts[1] = nil
  end

  it('works with vim function', function()
    vim.cmd([[
      func! TestFunction() abort
        return "TestVimFunction"
      endf
    ]])
    assert_vim_var_component('TestFunction', opts, 'TestVimFunction')
    vim.cmd('delfunction TestFunction')
  end)

  it('works with lua expression', function()
    _G.TestFunction = function()
      return 'TestLuaFunction'
    end
    assert_vim_var_component('TestFunction()', opts, 'TestLuaFunction')
    _G.TestFunction = nil
  end)
end)

describe('Branch component', function()
  -- these tests are broken in wsl will look at them later
  if vim.fn.has('wsl') == 1 then
    return
  end
  local tmpdir
  local file
  local git = function(...)
    return vim.fn.system(
      "git -c user.name='asdf' -c user.email='asdf@jlk.org' -C " .. tmpdir .. ' ' .. string.format(...)
    )
  end
  local assert_comp_ins = helpers.assert_component_instence

  before_each(function()
    tmpdir = os.tmpname()
    os.remove(tmpdir)
    file = tmpdir .. '/test.txt'
    vim.fn.mkdir(tmpdir, 'p')
    git('init -b test_branch')
    vim.cmd([[aug lualine
    au!
    aug END
  ]])
  end)

  after_each(function()
    os.remove(tmpdir)
  end)

  it('works with regular branches', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      padding = 0,
    }
    local branch_comp = helpers.init_component('branch', opts)
    vim.cmd('e ' .. file)
    assert_comp_ins(branch_comp, ' test_branch')
    git('checkout -b test_branch2')
    vim.cmd('e k')
    vim.cmd('bd')
    vim.cmd('e ' .. file)
    opts.icons_enabled = false
    assert_comp_ins(branch_comp, 'test_branch2')
  end)

  it('works in detached head mode', function()
    local opts = build_component_opts {
      component_separators = { left = '', right = '' },
      icons_enabled = false,
      padding = 0,
    }
    git('checkout -b test_branch2')
    git('commit --allow-empty -m "test commit1"')
    git('commit --allow-empty -m "test commit2"')
    git('commit --allow-empty -m "test commit3"')
    git('checkout HEAD~1')
    vim.cmd('e ' .. file)
    local rev = git('rev-parse --short=6 HEAD'):sub(1, 6)
    assert_component('branch', opts, rev)
  end)
end)
