local utils = require('lualine.utils.utils')
describe('utils', function()
  it('can save highlights', function()
    local highlight = {name='hl1', foreground='#122233', background='#445566', gui='italic'}
    utils.save_highlight(highlight.name, highlight)
    -- highlight loaded in loaded_highlights table
    assert.are.same(utils.loaded_highlights[highlight.name], highlight)
    -- highlight exists works properly
    assert.are.same(utils.highlight_exists('hl1'), true)
    assert.are.same(utils.highlight_exists('hl2'), false)
    -- highlights can be cleared
    utils.clear_highlights()
    assert.are.same(utils.highlight_exists('hl1'), false)
  end)
end)
