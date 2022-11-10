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
  if (!is_null(info$lines)) {
    info$lines
  } else if (nzchar(info$file)) {
    readLines(info$file)
  } else {
    abort("Must supply either `text` or `file`.", call = call)
  }
}

as_lines <- function(text) {
  strsplit(text, "\n")[[1]]
}

split_sep <- function(xs, is_sep) {
  stopifnot(
    is_logical(is_sep)
  )

  n <- sum(is_sep) + 1L
  out <- rep(list(xs[0]), n)

  j <- 1L
  locs <- integer()

  for (i in seq_along(xs)) {
    if (is_sep[[i]]) {
      out[[j]] <- xs[locs]
      locs <- integer()
      j <- j + 1L
    } else {
      locs <- c(locs, i)
    }
  }
  out[[j]] <- xs[locs]

  out
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

replace_tabs <- function(text) {
  # FIXME: Hardcoded indent level
  base_indent <- 2

  gsub("\t", strrep(" ", base_indent), text)
}
