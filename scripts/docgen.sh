# Copyright (c) 2020-2021 shadmansaleh
# MIT license, see LICENSE for more details.

PANVIMDOC_TAG_VERSION="v2.7.1" # panvimdoc version

# panvimdocs metadata
PANVIMDOC_VIMDOC="lualine"
PANVIMDOC_DESCRIPTION="fast and easy to configure statusline plugin for neovim"
PANVIMDOC_PANDOC="README.md"
PANVIMDOC_VERSION="NVIM v0.5.0"
PANVIMDOC_TOC=true
PANDOC_OUTPUT="doc/lualine.txt"

PANVIMDOC_INSTALLED=false # Whether panvimdoc was installed by this script

if [ ! -d "panvimdoc/" ];then
  # Grab panvimdoc if not present
  PANVIMDOC_INSTALLED=true
  echo "Installing panvimdoc"
  git clone --depth 1\
    --branch "${PANVIMDOC_TAG_VERSION}"\
    "https://github.com/kdheepak/panvimdoc" "panvimdoc"
fi

echo "Generating docs"
pandoc --metadata=project:"${PANVIMDOC_VIMDOC}"\
       --metadata=toc:${PANVIMDOC_TOC}\
       --metadata=vimversion:"${PANVIMDOC_VERSION}"\
       --metadata=description:"${PANVIMDOC_DESCRIPTION}"\
       --lua-filter ./panvimdoc/scripts/skip-blocks.lua\
       --lua-filter ./panvimdoc/scripts/include-files.lua\
       -t ./panvimdoc/scripts/panvimdoc.lua\
       -o "${PANDOC_OUTPUT}"\
       "${PANVIMDOC_PANDOC}"

if $PANVIMDOC_INSTALLED ;then
  # Remove panvimdoc if it was installed by this script
  echo "Removing panvimdoc"
  rm -rf panvimdoc
fi

