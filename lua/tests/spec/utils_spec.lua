-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local helpers = require('tests.helpers')

local eq = assert.are.same
local build_component_opts = helpers.build_component_opts

describe('Utils', function()
  local utils = require('lualine.utils.utils')

  it('can retrive highlight groups', function()
    local hl2 = { fg = '#aabbcc', bg = '#889977', reverse = true }
    -- handles non existing hl groups
    eq(utils.extract_highlight_colors('hl2'), nil)
    -- create highlight
    vim.cmd(string.format('hi hl2 guifg=%s guibg=%s gui=reverse', hl2.fg, hl2.bg))
    -- Can retrive entire highlight table
    eq(utils.extract_highlight_colors('hl2'), hl2)
    -- Can retrive specific parts of highlight
    eq(utils.extract_highlight_colors('hl2', 'fg'), hl2.fg)
    -- clear hl2
    vim.cmd('hi clear hl2')
  end)

  it('can shrink list with holes', function()
    local list_with_holes = {
      '2',
      '4',
      '6',
      nil,
      '43',
      nil,
      '2',
      '',
      'a',
      '',
      'b',
      ' ',
    }
    local list_without_holes = { '2', '4', '6', '43', '2', 'a', 'b', ' ' }
    eq(utils.list_shrink(list_with_holes), list_without_holes)
  end)
end)

describe('Cterm genarator', function()
  local cterm = require('lualine.utils.color_utils')

  it('can convert rgb to cterm', function()
    local colors = { ['#112233'] = 235, ['#7928ae'] = 97, ['#017bdc'] = 68 }
    for rgb, ct in pairs(colors) do
      eq(cterm.rgb2cterm(rgb), tostring(ct))
    end
  end)
end)

describe('Section genarator', function()
  local sec = require('lualine.utils.section')
  it('can draw', function()
    local opts = build_component_opts { section_separators = { left = '', right = '' } }
    local section = {
      require('lualine.components.special.function_component')(opts),
      require('lualine.components.special.function_component')(opts),
    }
    eq('%#lualine_MySection_normal# test %#lualine_MySection_normal# test ', sec.draw_section(section, 'MySection'))
  end)

  it('can remove separators from component with custom colors', function()
    vim.g.actual_curwin = tostring(vim.api.nvim_get_current_win())
    local opts = build_component_opts { section_separators = { left = '', right = '' } }
    local opts_colored = build_component_opts { color = 'MyColor' }
    local opts_colored2 = build_component_opts {
      color = { bg = '#223344' },
      section_separators = { left = '', right = '' },
    }
    local opts_colored3 = build_component_opts {
      color = { fg = '#223344' },
      section_separators = { left = '', right = '' },
    }
    require('lualine.highlight').create_highlight_groups(require('lualine.themes.gruvbox'))
    local section = {
      require('lualine.components.special.function_component')(opts),
      require('lualine.components.special.function_component')(opts_colored),
      require('lualine.components.special.function_component')(opts),
    }
    local highlight_name2 = 'lualine_' .. section[2].options.component_name .. '_no_mode'
    -- Removes separator on string color
    eq(
      '%#lualine_MySection_normal# test %#' .. highlight_name2 .. '#' .. ' test %#lualine_MySection_normal# test ',
      sec.draw_section(section, 'MySection')
    )
    section[2] = require('lua.lualine.components.special.function_component')(opts_colored2)
    local highlight_name = '%#lualine_c_' .. section[2].options.component_name .. '_normal#'
    -- Removes separator on color with bg
    eq(
      '%#lualine_MySection_normal# test ' .. highlight_name .. ' test %#lualine_MySection_normal# test ',
      sec.draw_section(section, 'MySection')
    )
    section[2] = require('lua.lualine.components.special.function_component')(opts_colored3)
    highlight_name2 = '%#lualine_c_' .. section[2].options.component_name .. '_normal#'
    -- Doesn't remove separator on color without bg
    eq(
      '%#lualine_MySection_normal# test '
        .. highlight_name2
        .. ' test %#lualine_MySection_normal#%#lualine_MySection_normal# test ',
      sec.draw_section(section, 'MySection')
    )
    vim.g.actual_curwin = nil
  end)
end)
