.DEFAULT_GOAL = check

lint:
	@luacheck lua/lualine
	@luacheck lua/tests
	@luacheck examples/

format:
	@stylua --config-path=.stylua.toml lua/ examples/

test:
	@nvim --headless -u lua/tests/minimal_init.lua -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './lua/tests/minimal_init.lua' }"

docgen:
	@bash ./scripts/docgen.sh

precommit_check: docgen format test lint

check: lint test
