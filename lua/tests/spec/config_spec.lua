local eq = assert.are.same

describe('config parsing', function()
  local config_module = require 'lualine.config'

  describe('options', function()
    describe('icons_enabled', function()
      it('default', function()
        config_module.apply_configuration({})
        eq(config_module.config.options.icons_enabled, true)
      end)
      it('custom', function()
        local config = {options = {icons_enabled = false}}
        config_module.apply_configuration(config)
        eq(config_module.config.options.icons_enabled, false)
      end)
    end)

    describe('theme', function()
      it('default', function()
        config_module.apply_configuration({})
        eq(config_module.config.options.theme, 'gruvbox')
      end)
      it('custom', function()
        local config = {options = {theme = 'nord'}}
        config_module.apply_configuration(config)
        eq(config_module.config.options.theme, 'nord')
        config = {options = {theme = {}}}
        config_module.apply_configuration(config)
        eq(config_module.config.options.theme, {})
      end)
    end)

    describe('separators', function()
      it('default', function()
        config_module.apply_configuration({})
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

    describe('disabled filetypes', function()
      it('default', function()
        config_module.apply_configuration({})
        eq(config_module.config.options.disabled_filetypes, {})
      end)
      it('custom', function()
        local config = {options = {disabled_filetypes = {'lua'}}}
        config_module.apply_configuration(config)
        eq(config_module.config.options.disabled_filetypes, {'lua'})
      end)
    end)

    describe('non default global option', function()
      it('default', function()
        local config = {options = {}}
        config_module.apply_configuration(config)
        eq(config_module.config.options.non_default_global_option, nil)
      end)
      it('custom', function()
        local config = {options = {non_default_global_option = 1}}
        config_module.apply_configuration(config)
        eq(config_module.config.options.non_default_global_option, 1)
      end)
    end)
  end)
end)
