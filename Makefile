.DEFAULT_GOAL = check

lint:
	@luacheck lua/lualine
	@luacheck lua/tests
	@luacheck examples/

format:
	@stylua --config-path=.stylua.toml lua/ examples/

test:
	@mkdir -p tmp_home
	@export XDG_DATA_HOME='./tmp_home' && \
	export XDG_CONFIG_HOME='./tmp_home' && \
	nvim --headless --noplugin --clean -u lua/tests/minimal_init.lua -c "lua require'plenary.test_harness'.test_directory( 'lua/tests/', { minimal_init = './lua/tests/minimal_init.lua' })"
	@rmdir tmp_home

# Install luacov & luacov-console from luarocks
testcov:
	@mkdir -p tmp_home
	@export XDG_DATA_HOME='./tmp_home' && \
	export XDG_CONFIG_HOME='./tmp_home' && \
	export TEST_COV=true && \
	nvim --headless --noplugin --clean -u lua/tests/minimal_init.lua -c "lua require'plenary.test_harness'.test_directory( 'lua/tests/', { minimal_init = './lua/tests/minimal_init.lua' })"
	@luacov-console lua/
	@luacov-console -s
ifeq ($(NOCLEAN), )
		@rm luacov.*
endif
	@rmdir tmp_home

docgen:
	@bash ./scripts/docgen.sh

precommit_check: docgen format test lint

check: lint test
