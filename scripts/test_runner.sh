#!/usr/bin/env bash
set -e

REPO_DIR=$(git rev-parse --show-toplevel)

nvim_t() {
	nvim -u "$REPO_DIR/tests/minimal_init.lua" -c "set runtimepath+=$REPO_DIR" "$@"
}

if [ -n "$1" ]; then
  nvim_t --headless -c "lua require('plenary.busted').run('$1')"
else
  nvim_t --headless -c "lua require'plenary.test_harness'.test_directory( 'tests/', { minimal_init = './tests/minimal_init.lua' })" -c "qa!"
fi
