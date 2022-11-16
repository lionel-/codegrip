addin_move_outside <- function() {
  addin_move(move_outside_info)
}
addin_move_inside <- function() {
  addin_move(move_inside_info)
}
addin_move_next <- function() {
  addin_move(move_next_info)
}
addin_move_previous <- function() {
  addin_move(move_previous_info)
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
