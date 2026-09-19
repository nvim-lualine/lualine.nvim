-- MIT license, see LICENSE for more details.

require('tests.helpers')
local eq = assert.are.same
local stub = require('luassert.stub')
local utils = require('lualine.utils.utils')

describe('Timer callbacks', function()
  local scheduled, timer

  before_each(function()
    scheduled = {}
    timer = vim.loop.new_timer()
    stub(vim, 'schedule', function(fn)
      scheduled[#scheduled + 1] = fn
    end)
  end)

  after_each(function()
    vim.schedule:revert()
    timer:stop()
    timer:close()
    vim.cmd('augroup lualine_timer_test | autocmd! | augroup END')
  end)

  it('queues only one callback until it runs, then accepts the next tick', function()
    local calls = {}
    local callback = utils.timer_call(timer, nil, function(...)
      calls[#calls + 1] = { n = select('#', ...), ... }
    end)

    callback('first', nil, 'last')
    for _ = 1, 100 do
      callback('skipped')
    end
    eq(1, #scheduled)
    eq({}, calls)

    table.remove(scheduled, 1)()
    eq({ { n = 3, 'first', nil, 'last' } }, calls)

    callback('next')
    eq(1, #scheduled)
    table.remove(scheduled, 1)()
    eq({ { n = 3, 'first', nil, 'last' }, { n = 1, 'next' } }, calls)
  end)

  it('keeps separate callbacks independent', function()
    local calls = { 0, 0 }
    local first = utils.timer_call(timer, nil, function()
      calls[1] = calls[1] + 1
    end)
    local second = utils.timer_call(timer, nil, function()
      calls[2] = calls[2] + 1
    end)
    first()
    second()
    first()
    second()
    eq(2, #scheduled)
    table.remove(scheduled, 1)()
    table.remove(scheduled, 1)()
    eq({ 1, 1 }, calls)
  end)

  it('retries after errors and resets the error count after success', function()
    local calls = 0
    local callback = utils.timer_call(timer, nil, function()
      calls = calls + 1
      if calls == 1 or calls == 3 then
        error('temporary failure')
      end
    end, 1, 'refresh failed')
    for _ = 1, 4 do
      callback()
      eq(1, #scheduled)
      table.remove(scheduled, 1)()
    end
    eq(4, calls)
  end)

  it('preserves the default retry limit and stops the timer and autocmds', function()
    local calls = 0
    timer:start(60000, 60000, function() end)
    vim.cmd(
      'augroup lualine_timer_test | autocmd! | autocmd User LualineTimerTest let g:lualine_timer_test = 1 | augroup END'
    )
    local callback = utils.timer_call(timer, 'lualine_timer_test', function()
      calls = calls + 1
      error('refresh failure')
    end, nil, 'lualine test')

    for _ = 1, 4 do
      for _ = 1, 100 do
        callback()
      end
      eq(1, #scheduled)
      table.remove(scheduled, 1)()
    end
    eq(4, calls)
    assert.is_true(timer:is_active())

    callback()
    eq(1, #scheduled)
    local ok, err = pcall(table.remove(scheduled, 1))
    assert.is_false(ok)
    assert.is_truthy(err:find('lualine test:', 1, true))
    assert.is_truthy(err:find('refresh failure', 1, true))
    assert.is_false(timer:is_active())
    eq(0, vim.fn.exists('#lualine_timer_test#User#LualineTimerTest'))
    eq(4, calls)
  end)
end)
