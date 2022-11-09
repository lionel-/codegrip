emacs_reshape <- function(...) {
  tryCatch(
    expr = {
      emacs_reshape_unsafe(...)
    },
    error = function(cnd) {
      FALSE
    }
  )
}

emacs_reshape_unsafe <- function(file, line, col) {
  parse_info <- parse_info(file = file)
  out <- reshape_info(line, col, info = parse_info)

  writeLines(character(), file)
  print_lisp(out, file)

  !is_null(out)
}
