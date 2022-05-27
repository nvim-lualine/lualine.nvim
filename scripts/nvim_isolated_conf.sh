#!/bin/sh

# Copyright (c) 2020-2021 shadmansaleh
# MIT license, see LICENSE for more details.

USAGE="Usage nvim_isolated_conf.sh [OPTIONS] Directory
A tool to easily test isolated neovim config

Options:
  -c       Create a minimal config tree at Directory
  -e       Edit init.vim of config in Directory
  -h       Show this message
  -l       Load neovim with config from Directory
"

INIT_TEMPLATE="call plug#begin(\"%s/.local/share/nvim/plugged\")
\" Your plugins go here like
Plug 'nvim-lualine/lualine.nvim'


call plug#end()

\" Your Viml part of config goes here
\" colorscheme onedark


lua << END
-- Your lua part of config goes here
require'lualine'.setup {

}


END

\" Instructions:
\" -------------------------------------------------------------
\" Load this config with nvim_isolated_conf.sh -l %s
\" Remember to run :PlugInstall after changing plugin section
\" Also delete the comments before putting this file on issue
\" That will reduce noise
\" You can delete %s once you're done"

while getopts "c:e:hl:" arg; do
  case $arg in
    h) Help=true;;
    c) CreateDirInput=$OPTARG;;
    l) LoadDirInput=$OPTARG;;
    e) EditDirInput=$OPTARG;;
  esac
done
shift $((OPTIND -1))


if ! [ -z $LoadDirInput ];then
  LoadDir=$(realpath $LoadDirInput)
  if [ -d $LoadDir ];then
    export NVIM_CONFIG_HOME=$LoadDir
    export XDG_CONFIG_HOME=$NVIM_CONFIG_HOME/.config
    export XDG_DATA_HOME=$NVIM_CONFIG_HOME/.local/share
    export XDG_CACHE_HOME=$NVIM_CONFIG_HOME/.cache
    export XDG_STATE_HOME=$NVIM_CONFIG_HOME/.local/state
    nvim $@
  else
    echo "Sorry can't load neovim config. ${LoadDir} doesn't exist"
  fi
elif ! [ -z $CreateDirInput ];then
  CreateDir=$(realpath $CreateDirInput)
  echo "Creating directories"
  mkdir -p ${CreateDir}/.local/share/nvim/site/autoload
  mkdir -p ${CreateDir}/.config/nvim
  echo "Installing VimPlug"
  wget -q "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -O ${CreateDir}/.local/share/nvim/site/autoload/plug.vim
  echo "Writing minimal init"
  printf "${INIT_TEMPLATE}" ${CreateDir} ${CreateDir} ${CreateDir} > ${CreateDir}/.config/nvim/init.vim
  echo ""
  echo "You can edit the ${CreateDirInput}/.config/nvim/init.vim to put your config"
  echo "You can load this config with nvim_isolated_conf.sh -l ${CreateDirInput}"
  echo "You can open config (init.vim) to edit with nvim_isolated_conf.sh -e ${CreateDirInput}"
elif ! [ -z $EditDirInput ];then
  if [ -d $EditDirInput  ];then
    if ! [ -z $EDITOR ];then
      $EDITOR $EditDirInput/.config/nvim/init.vim
    else
      nvim $EditDirInput/.config/nvim/init.vim
    fi
  else
    echo "Sorry can't load neovim config. ${LoadDir} doesn't exist"
  fi
else
  printf "$USAGE"
fi
