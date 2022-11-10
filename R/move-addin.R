addin_move_rise <- function() {
  addin_move(rise_info)
}
addin_move_walk <- function() {
  addin_move(walk_info)
}
addin_move_back <- function() {
  addin_move(back_info)
}

addin_move <- function(action) {
  tryCatch(
    addin_move_unsafe(action),
    error = function(...) NULL
  )
}

addin_move_unsafe <- function(action) {
  context <- rstudioapi::getActiveDocumentContext()
  lines <- context$contents
  sel <- context$selection[[1]]$range

  # No traversal for selections
  if (!identical(sel$start, sel$end)) {
    return()
  }

  line <- sel$start[[1]]
  col <- sel$start[[2]]

  parse_info <- parse_info(lines = lines)
  out <- action(line, col, info = parse_info)

  if (!is_null(out)) {
    pos <- rstudioapi::document_position(out[["line"]], out[["col"]])
    rstudioapi::setCursorPosition(pos)
  }
}
