#' Reshape expressions longer or wider
#'
#' @description `addin_reshape()` lets you cycle between different shapes of
#'   function calls. For instance, reshaping transforms code from wide to long
#'   shape and vice versa:
#'   ```
#'   list(a, b, c)
#'
#'   list(
#'     a,
#'     b,
#'     c
#'   )
#'   ```
#'   Note that for function definitions, `addin_reshape()` cycles through two
#'   different long shapes. The traditional L form uses more horizontal space
#'   whereas the flat form uses less horizontal space and the arguments are
#'   always aligned at double indent:
#'   ```
#'   foo <- function(a, b, c) {
#'     NULL
#'   }
#'
#'   foo <- function(a,
#'                   b,
#'                   c) {
#'     NULL
#'   }
#'
#'   foo <- function(
#'     a,
#'     b,
#'     c
#'   ) {
#'     NULL
#'   }
#'   ```
#' @export
addin_reshape <- function() {
  tryCatch(
    addin_reshape_unsafe(),
    error = function(...) NULL
  )
}

addin_reshape_unsafe <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  lines <- context$contents
  sel <- context$selection[[1]]$range

  # No reshaping for selections
  if (!identical(sel$start, sel$end)) {
    return()
  }

  line <- sel$start[[1]]
  col <- sel$start[[2]]

  parse_info <- parse_info(lines = lines)
  out <- reshape_info(line, col, info = parse_info)

  pos1 <- rstudioapi::document_position(out$start[["line"]], out$start[["col"]])
  pos2 <- rstudioapi::document_position(out$end[["line"]], out$end[["col"]])
  range <- rstudioapi::document_range(pos1, pos2)

  rstudioapi::modifyRange(range, out$reshaped)
  rstudioapi::setCursorPosition(sel)
}
