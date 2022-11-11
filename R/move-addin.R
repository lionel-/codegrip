addin_move_up <- function() {
  addin_move(move_up_info)
}
addin_move_right <- function() {
  addin_move(move_right_info)
}
addin_move_left <- function() {
  addin_move(move_left_info)
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
