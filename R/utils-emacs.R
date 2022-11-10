# Bare bones printer for limited use cases
print_lisp <- function(x, file = stdout(), last = FALSE) {
  cat <- function(...) {
    base::cat(..., file = file, append = TRUE)
    NULL
  }

  finish <- function(x = NULL) {
    if (!is_null(x)) {
      cat(x)
    }
    if (!last) {
      cat("\n")
    }

    invisible(NULL)
  }

  supported <- c(
    "list",
    "character",
    "logical",
    "integer",
    "double",
    "NULL"
  )

  type <- typeof(x)
  if (!type %in% supported) {
    abort(sprintf("Unimplemented type %s.", type), .internal = TRUE)
  }

  switch(
    type,
    NULL = return(finish("nil"))
  )

  cat("(")

  nms <- names(x)
  n <- length(x)

  for (i in seq_len(n)) {
    if (!is_null(nms)) {
      cat(paste0(":", nms[[i]], " "))
    }

    switch(
      type,
      list = print_lisp(x[[i]], file, last = i == n),
      character = cat(encodeString(x[[i]], quote = "\"")),
      logical = ,
      integer = ,
      double = cat(x[[i]])
    )

    if (i < n) {
      cat(" ")
    }
  }

  finish(")")
}
