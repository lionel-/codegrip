emacs_move <- function(cmd, ...) {
  action <- switch(
    cmd,
    "outside" = move_outside_info,
    "inside" = move_inside_info,
    "next" = move_next_info,
    "previous" = move_previous_info,
    function(...) FALSE
  )
  tryCatch(
    emacs_move_unsafe(action, ...),
    error = function(cnd) FALSE
  )
}

emacs_move_unsafe <- function(action_info, file, line, col) {
  parse_info <- parse_info(file = file)
  out <- action_info(line, col, info = parse_info)

  writeLines(character(), file)
  print_lisp(out, file)

  !is_null(out)
}
