# Contributing to lualine.nvim

Thanks for considering to contribute.

### Getting started

If you're not sure where to help? You can try these:

- You can look at the currently open [issues](https://github.com/nvim-lualine/lualine.nvim/issues)
  to see if some bug needs fixing or for cool feature ideas.<br>
  You should also look at currently open PRs ([Pull requests](https://github.com/nvim-lualine/lualine.nvim/pulls)) to see if some abandoned PR interests you.<br>
  *We could really use some help with tests & docs they are currently lacking :)*
- You can add an exciting new component, extension or theme.
  Note: Currently we aren't adding regular colorscheme based themes.
  We think they make more sense with colorschemes as they tend not to get
  updated once added here. But if you have some unique themes idea like [auto](https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md#auto) or [pywal](https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md#pywal) feel free to open an PR or issue.
- Feel free to open issues or unfinished PRs for help.
  I'd actually recommend you to open an issue first for bigger PRs to discuss
  the feature with a maintainer beforehand. That way you can know if the
  feature is likely to be accepted or not before you get started.
  You'll get recommendation and help with implementation specially if you show
  willingness to implement it yourself.
- Do add tests and docs for your changes.

Good luck!

### Developer tools

*Let's introduce you to the tools we use.*

- Your PR needs to pass tests & linter. We lint our codebase with [luacheck](https://github.com/mpeterv/luacheck)
  and run tests with [plenary-test][plenary.nvim] these will be ran on CI. If you want you can run tests & linter
  locally with `make test` & `make lint` respectively. Or `make check` to run both linter & tests. For running
  tests you'll have to make sure lualine.nvim, [plenary.nvim][plenary.nvim] and
  [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) are in same directory.
- Lua codebase gets formatted with [stylua](https://github.com/JohnnyMorganz/StyLua) in CI.
  So you can ignore formatting. But if you want to submit formatted
  PR you can run formatter locally with `make format`.
- VimDocs are auto generated with [panvimdoc](https://github.com/kdheepak/panvimdoc) from README.md.
  So don't make changes to doc/lualine.txt . Instead add your docs to README or Wiki.
  The docgen in ran by CI too. If you want to run it locally you can do so
  with `make docgen`. Note: you'll need to have [pandoc](https://github.com/jgm/pandoc) installed.
- `make precommit_check` can come quite handy it'll run all the above mentioned tools
- You can check our test coverage with `make testcov`.
  You'll need to have [luacov](https://github.com/keplerproject/luacov)
  & [luacov-console](https://github.com/spacewander/luacov-console) installed for that.
  If you want luacov's detailed report files, run the command with the `NOCLEAN` env set.
  For example `NOCLEAN=1 make testcov`

[plenary.nvim]: https://github.com/nvim-lua/plenary.nvim
