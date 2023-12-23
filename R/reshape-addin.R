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
