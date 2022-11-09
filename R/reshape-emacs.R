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
  out <- reshape_info(line, col, file = file)

  writeLines(character(), file)
  print_lisp(out, file)

  !is_null(out)
}
