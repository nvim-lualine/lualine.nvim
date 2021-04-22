.DEFAULT_GOAL = check

lint:
	@luacheck lua/lualine
	@luacheck tests

format:
	@for file in `find -name '*.lua'`;do lua-format $$file -i; done;

test:
	@nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }"

check: lint test

all: check
