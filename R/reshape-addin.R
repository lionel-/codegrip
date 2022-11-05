addin_reshape <- function() {
  tryCatch(
    addin_reshape_unsafe(),
    error = function(...) NULL
  )
}

addin_reshape_unsafe <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  text <- context$contents
  sel <- context$selection[[1]]$range

  # No reshaping for selections
  if (!identical(sel$start, sel$end)) {
    return()
  }

  line <- sel$start[[1]]
  col <- sel$start[[2]]

  out <- reshape(text, line, col)

  pos1 <- rstudioapi::document_position(out$start[["line"]], out$start[["col"]])
  pos2 <- rstudioapi::document_position(out$end[["line"]], out$end[["col"]])
  range <- rstudioapi::document_range(pos1, pos2)

  rstudioapi::modifyRange(range, out$reshaped)
  rstudioapi::setCursorPosition(sel)
}
