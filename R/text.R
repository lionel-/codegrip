rx_spaces <- "[[:space:]]"
rx_not_spaces <- "[^[:space:]]"

skip_space <- function(lines, line, col, ...) {
  line_text <- lines[[line]]
  if (!line_is_at_whitespace(line_text, col)) {
    return(c(line = line, col = col))
  }

  n <- nchar(line_text)
  line_text <- substr(line_text, col, n)
  trimmed_n <- n - nchar(line_text)

  not_space_loc <- regexpr(rx_not_spaces, line_text)
  if (not_space_loc > 0) {
    return(c(line = line, col = not_space_loc + trimmed_n))
  }

  for (i in seq2(line + 1L, length(lines))) {
    line_text <- lines[[i]]

    not_space_loc <- regexpr(rx_not_spaces, line_text)
    if (not_space_loc > 0) {
      return(c(line = i, col = not_space_loc))
    }
  }

  # In case an empty `for` loop didn't initialise `i`
  i <- i %||% line

  c(line = i, col = nchar(lines[[i]]))
}

line_is_at_whitespace <- function(line, col) {
  at_end <- col == nchar(line) + 1
  at_end || grepl(rx_spaces, substr(line, col, col))
}

chr_suffix <- function(x, start) {
  substr(x, start, nchar(x))
}
