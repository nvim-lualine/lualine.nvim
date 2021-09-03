.DEFAULT_GOAL = check

lint:
	@luacheck lua/lualine
	@luacheck lua/tests
	@luacheck examples/

format:
	@stylua --config-path=.stylua.toml lua/ examples/

test:
	@nvim --headless -u lua/tests/minimal_init.lua -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './lua/tests/minimal_init.lua' }"

check: lint test
