.DEFAULT_GOAL = build
CFLAGS = -Wall -Werror -fPIC

ifeq ($(OS),Windows_NT)
	MKD = -mkdir
	RM = cmd /C rmdir /Q /S
	CC = gcc
	TARGET := liblualine.dll
else
	MKD = mkdir -p
	RM = rm -rf
	TARGET := liblualine.so
endif

lint:
	@luacheck lua/lualine
	@luacheck lua/tests
	@luacheck examples/

format:
	@for file in `find . -name '*.lua'`;do lua-format $$file -i; done;

test:
	@nvim --headless -u lua/tests/minimal_init.lua -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './lua/tests/minimal_init.lua' }"

check: lint test

SRC = $(wildcard src/*.c)
INCLUDES = $(wildcard src/*.h)

build: $(SRC) $(INCLUDES)
	$(MKD) build
	$(CC) -O3 $(CFLAGS) -shared $(SRC) -o build/$(TARGET)

debug: $(SRC) $(INCLUDES)
	$(MKD) build
	$(CC) -O0 -g -fsanitize=address $(CFLAGS) -shared $(SRC) -o build/$(TARGET)

clean:
	$(RM) build/

# vim:noet
