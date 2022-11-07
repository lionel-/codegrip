snap_reshape_cycle <- function(n, code, line = 1, col = 1) {
  for (i in seq_len(n)) {
    out <- reshape(code, line, col)
    code <- out$reshaped

    cat_line(
      sprintf("i: %d", i),
      code,
      ""
    )
  }
}
