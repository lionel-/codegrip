check_rstudio <- function(call = caller_env()) {
  if (!is_rstudio()) {
    abort("Can't use this feature outside RStudio.", call = call)
  }
}

is_rstudio <- function() {
  identical(.Platform$GUI, "RStudio")
}

cat_line <- function(...) {
  cat(paste0(..., "\n", collapse = ""))
}

lines <- function(info, call = caller_env()) {
  if (!is_null(info$text)) {
    strsplit(info$text, "\n")[[1]]
  } else if (nzchar(info$file)) {
    readLines(info$file)
  } else {
    abort("Must supply either `text` or `file`.", call = call)
  }
}

split_sep <- function(x, is_sep) {
  stopifnot(
    is_logical(is_sep)
  )
  groups <- cumsum(is_sep)[!is_sep]
  unname(split(x[!is_sep], groups))
}
