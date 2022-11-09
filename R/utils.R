check_rstudio <- function(call = caller_env()) {
  if (!is_rstudio()) {
    abort("Can't use this feature outside RStudio.", call = call)
  }
}

is_rstudio <- function() {
  identical(.Platform$GUI, "RStudio")
}

cat_line <- function(...) {
  cat(paste0(chr(...), "\n", collapse = ""))
}

lines <- function(info, call = caller_env()) {
  if (!is_null(info$text)) {
    as_lines(info$text)
  } else if (nzchar(info$file)) {
    readLines(info$file)
  } else {
    abort("Must supply either `text` or `file`.", call = call)
  }
}

as_lines <- function(text) {
  strsplit(text, "\n")[[1]]
}

split_sep <- function(x, is_sep) {
  stopifnot(
    is_logical(is_sep)
  )
  groups <- cumsum(is_sep)[!is_sep]
  unname(split(x[!is_sep], groups))
}

str_replace <- function(text, start, stop = nchar(text), value = "") {
  paste0(
    substr(text, 1, start - 1L),
    value,
    substr(text, stop + 1L, nchar(text))
  )
}

line_reindent <- function(line, n) {
  sub("^[[:space:]]*", spaces(n), line)
}

spaces <- function(n) {
  strrep(" ", n)
}
