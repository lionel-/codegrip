emacs_rise <- function(...) {
  tryCatch(
    emacs_rise_unsafe(...),
    error = function(cnd) FALSE
  )
}

emacs_rise_unsafe <- function(file, line, col) {
  parse_info <- parse_info(file = file)
  out <- rise_info(line, col, info = parse_info)

  writeLines(character(), file)
  print_lisp(out, file)

  !is_null(out)
}
