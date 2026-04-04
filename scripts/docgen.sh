# Copyright (c) 2020-2021 shadmansaleh
# MIT license, see LICENSE for more details.

PANVIMDOC_TAG_VERSION="v4.0.1" # panvimdoc version

# panvimdocs metadata
PANVIMDOC_VIMDOC="lualine"
PANVIMDOC_DESCRIPTION="fast and easy to configure statusline plugin for neovim"
PANVIMDOC_PANDOC="README.md"
PANVIMDOC_VERSION="NVIM v0.7.0"
PANVIMDOC_TOC=true
PANVIMDOC_DOC_MAPPING=true
PANVIMDOC_DOC_MAPPING_PROJECT_NAME=false
PANVIMDOC_SHIFT_HEADING_LEVEL_BY="-1"
PANVIMDOC_INCREMENT_HEADING_LEVEL_BY="0"
PANVIMDOC_DEDUP_SUBHEADINGS=false

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
./panvimdoc/panvimdoc.sh \
       --project-name "${PANVIMDOC_VIMDOC}"\
       --toc ${PANVIMDOC_TOC}\
       --vim-version "${PANVIMDOC_VERSION}"\
       --description "${PANVIMDOC_DESCRIPTION}"\
       --input-file "${PANVIMDOC_PANDOC}"\
       --doc-mapping "${PANVIMDOC_DOC_MAPPING}"\
       --doc-mapping-project-name "${PANVIMDOC_DOC_MAPPING_PROJECT_NAME}"\
       --shift-heading-level-by "${PANVIMDOC_SHIFT_HEADING_LEVEL_BY}"\
       --increment-heading-level-by "${PANVIMDOC_INCREMENT_HEADING_LEVEL_BY}"\
       --dedup-subheadings "${PANVIMDOC_DEDUP_SUBHEADINGS}"

if $PANVIMDOC_INSTALLED ;then
  # Remove panvimdoc if it was installed by this script
  echo "Removing panvimdoc"
  rm -rf panvimdoc
fi

