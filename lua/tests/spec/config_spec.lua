local luassert = require 'luassert'
local config_module = require 'lualine.config'

local eq = luassert.are.same

describe('config', function()
  describe('separators', function()
    it('defaults', function()
      local config = {options = {}}
      config_module.apply_configuration(config)
      eq(config_module.config.options.component_separators, {'', ''})
      eq(config_module.config.options.section_separators, {'', ''})
    end)
    it('double separators', function()
      local config = {
        options = {
          component_separators = {'a', 'b'},
          section_separators = {'c', 'd'}
        }
      }
      config_module.apply_configuration(config)
      eq(config_module.config.options.component_separators, {'a', 'b'})
      eq(config_module.config.options.section_separators, {'c', 'd'})
    end)
    describe('single separator', function()
      it('string', function()
        local config = {
          options = {component_separators = 'a', section_separators = 'b'}
        }
        config_module.apply_configuration(config)
        eq(config_module.config.options.component_separators, {'a', 'a'})
        eq(config_module.config.options.section_separators, {'b', 'b'})
      end)
      it('table', function()
        local config = {
          options = {component_separators = {'a'}, section_separators = {'b'}}
        }
        config_module.apply_configuration(config)
        eq(config_module.config.options.component_separators, {'a', 'a'})
        eq(config_module.config.options.section_separators, {'b', 'b'})
      end)
    end)

    it('no seprarators', function()
      local config = {
        options = {component_separators = {}, section_separators = {}}
      }
      config_module.apply_configuration(config)
      eq(config_module.config.options.component_separators, {})
      eq(config_module.config.options.section_separators, {})
    end)
  end)
end)
