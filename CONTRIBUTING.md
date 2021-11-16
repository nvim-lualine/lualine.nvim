# Contributing to lualine.nvim

Thanks for considering to contribute.

### Getting started
You're not sure where to help. You can try these
- You can look at the currently open [issues](https://github.com/nvim-lualine/lualine.nvim/issues) to see if some bug needs fixing or for
  cool feature idea. You should also look at currently open prs to see
  if some abandoned pr interests you<br>
  *We could really use some help with tests & docs they are currently lacking :)*
- You can add exciting new component, extension or theme.
  (Note: Currently we aren't accepting regular colorscheme based themes.
   We think they make more sense with colorschemes as they tend not to get
   updated once added hete. But if you have some unique themes idea like [auto](https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md#auto) or [pywal](https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md#pywal)) feel free to open an issue or pr.
- Feel free to open issues or unfinished pr for help.
  I'd actually recommend you to open an issue first for bigging prs to discuss
  the feature with maintainer beforehand. That way you'll can know if the
  feature is likely to be accepted or not before you get started also you'll
  get recommendation and help with implementation specially if you show
  willingness to implement it yourself.
- Do add tests and docs for your changes.

Good luck.

### Devloper tools
*Let's introduce you to the tools we use.*

- Your pr need to pass tests & linter. We lint our codebase with [luacheck](https://github.com/mpeterv/luacheck)
  and run tests with [plenary-test](https://github.com/nvim-lua/plenary.nvim)
  these will be ran on CI. If you want you can run tests & linter locally with
  `make test` & `make lint` respectively. Or `make check` to run both linter & tests.
  For running tests you'll have to make sure both lualine.nvim and plenery.nvim are in same directory.
- lua codebase gets formatted with [stylua](https://github.com/JohnnyMorganz/StyLua) in CI.
  So you can ignore formatting if you want. But if you want to submit formatted
  pr you can run formatter locally with `make format`.
- VimDocs are auto generated with [panvimdoc](https://github.com/kdheepak/panvimdoc) from README.md.
  So don't make changes to doc/lualine.txt . Instead add your docs to README or Wiki.
  The docgen in ran by CI. If you want to run it locally you can do so
  with `make docgen`. Note: you'll need to have [pandoc](https://github.com/jgm/pandoc) installed.
- `make precommit_check` can come quite handy it'll run all the above mentioned tools
- You can check our test coverage with `make testcov`.
  You'll need to have [luacov](https://github.com/keplerproject/luacov)
  & [luacov-console](https://github.com/spacewander/luacov-console) installed for that.
  If you want the luacovs detailed report files run the command with NOCLEAN env set.
  like `NOCLEAN=1 make testcov`
