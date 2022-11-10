emacs_move <- function(cmd, ...) {
  action <- switch(
    cmd,
    rise = rise_info,
    walk = walk_info,
    back = back_info,
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
