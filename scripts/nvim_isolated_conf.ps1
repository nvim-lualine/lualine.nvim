param(
    [Parameter()]
    [Switch]$h = $false,
    [String]$c = "",
    [String]$l = "",
    [String]$e = ""
)

$USAGE = "Usage nvim_isolated_conf.sh [OPTIONS] Directory
A tool to easily test isolated neovim config

Options:
  -c       Create a minimal config tree at Directory
  -e       Edit init.vim of config in Directory
  -h       Show this message
  -l       Load neovim with config from Directory
"

$INIT_TEMPLATE="call plug#begin(`"%s/.local/share/nvim/plugged`")
`" Your plugins go here like
Plug 'nvim-lualine/lualine.nvim'


call plug#end()

`" Your Viml part of config goes here
`" colorscheme onedark


lua << END
-- Your lua part of config goes here
require'lualine'.setup {

}


END

`" Instructions:
`" -------------------------------------------------------------
`" Load this config with nvim_isolated_conf.sh -l %s
`" Remember to run :PlugInstall after changing plugin section
`" Also delete the comments before putting this file on issue
`" That will reduce noise
`" You can delete %s once you're done"


If ($l -ne "") {
  $l = Resolve-Path -Path $l
  if (Test-Path -Path $l) {
    $NVIM_CONFIG_HOME = $l
    $env:XDG_CONFIG_HOME = "$NVIM_CONFIG_HOME\.config"
    $env:XDG_DATA_HOME   = "$NVIM_CONFIG_HOME\.local\share"
    $env:XDG_CACHE_HOME  = "$NVIM_CONFIG_HOME\.cache"
    $env:XDG_STATE_HOME  = "$NVIM_CONFIG_HOME\.local\state"
    Remove-Item Env:\XDG_CONFIG_HOME
    Remove-Item Env:\XDG_DATA_HOME
    Remove-Item Env:\XDG_CACHE_HOME
    Remove-Item Env:\XDG_STATE_HOME
    nvim $args
  } else {
    Write-Output "Sorry can't load config. $l doesn't exits."
  }
}
