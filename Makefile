.DEFAULT_GOAL = check

lint:
	@luacheck lua/lualine
	@luacheck lua/tests
	@luacheck examples/

format:
	@for file in `find . -name '*.lua'`;do lua-format $$file -i; done;

test:
	@nvim --headless -u lua/tests/minimal_init.lua -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './lua/tests/minimal_init.lua' }"

check: lint test
