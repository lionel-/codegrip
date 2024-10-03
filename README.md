# codegrip

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/lionel-/codegrip/branch/main/graph/badge.svg)](https://app.codecov.io/gh/lionel-/codegrip?branch=main)
[![R-CMD-check](https://github.com/lionel-/codegrip/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lionel-/codegrip/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

codegrip provides [RStudio addins](http://rstudio.github.io/rstudioaddins/) and Emacs commands for reshaping R code and navigating across syntactic constructs.


### Reshaping

`addin_reshape` lets you cycle between different shapes of function calls. For instance, reshaping transforms code from wide to long shape and vice versa.

<img src="man/figures/README/reshape-call.svg"/>

Note that for function definitions, `addin_reshape` cycles through two different long shapes. The traditional L form uses more horizontal space whereas the flat form uses less horizontal space and the arguments are always aligned at single indent:

<img src="man/figures/README/reshape-def.svg"/>


### Navigating

There are currently two motions implemented in codegrip: outwards and inwards.


- `addin_move_inside` finds the first opening delimiter (`(`, `[`, or `{`) _after_ your cursor and steps inside it.

- `addin_move_outside` finds the first opening delimiter _before_ your cursor and steps outside it.

<img src="man/figures/README/move.svg"/>

These motions are handy for quick navigation across to quickly jump from a function argument to the corresponding function call. From there, you can reshape the whole call using `addin_reshape`.

<img src="man/figures/README/move-reshape.svg"/>


## Installation

The package is not yet on CRAN but you can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lionel-/codegrip")
```


### Setup

Suggested keybindings:

- `Alt + Tab`: `addin_reshape`
- `Alt + 3`: `addin_move_outside`
- `Alt + 4`: `addin_move_inside`

Not yet implemented:

- `Alt + 1`: `addin_move_backwards`
- `Alt + 2`: `addin_move_forwards`


## Using in Visual Studio Code

`addin_reshape` is available for keybinding in VS Code. See [here](https://github.com/REditorSupport/vscode-R/wiki/RStudio-addin-support#enabling-rstudio-addin-support) for instructions on enabling general addin support.

Once addins are enabled, add the following to `keybindings.json`:

```json
{
  "key": "Alt+tab",
  "command": "r.runCommand",
  "description": "Reshape expressions longer or wider",
  "when": "editorTextFocus",
  "args": "codegrip::addin_reshape()"
}
```

## Roadmap

- Forward and backward motions.

- Adding arguments to a function call using forward backward motions.

- Reshaping of repeated calls like `foo(...)(...)`. This will help reshaping data.table pipelines, e.g. `DT[...][...]`.

- Reshaping of `{` expressions.

- Reshaping of pipelines of binary operations, including pipes.

- Columnar formatting of `tibble::tribble()` calls.

- Selection of syntactic constructs, such as function arguments.


## Limitations

codegrip currently uses the R parser to figure out the structure of your code. Because of this, it doesn't work with malformed or partially written code. Your whole file must be valid R code for codegrip commands to work.
