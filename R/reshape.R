reshape <- function(text, line, col, to = NULL) {
  info <- parse_info(text = paste(text, collapse = "\n"))
  xml <- parse_xml(info)

  call <- find_function_call(line, col, data = xml)
  if (is_null(call)) {
    return()
  }

  if (is_null(to)) {
    if (node_call_type(call) == "prefix") {
      to <- switch(
        node_call_shape(call),
        wide = if (length(node_call_arguments(call)) == 1) {
          "long"
        } else {
          "L"
        },
        L = "long",
        long = "wide",
        "none"
      )
    } else {
      to <- switch(
        node_call_shape(call),
        wide = "long",
        L = ,
        long = "wide",
        "none"
      )
    }
  }

  reshaped <- switch(
    to,
    long = node_call_longer(call, info = info),
    L = node_call_longer(call, info = info, L = TRUE),
    wide = node_call_wider(call, info = info),
    none = node_text(call),
    abort("Unexpected value for `to`.", .internal = TRUE)
  )

  pos <- node_positions(call)

  list(
    reshaped = reshaped,
    start = c(line = pos$line1, col = pos$col1),
    end = c(line = pos$line2, col = pos$col2 + 1L)
  )
}

reshape_update <- function(text, line, col, to = NULL) {
  out <- reshape(text, line, col, to = to)
  lines <- strsplit(text, "\n")[[1]]

  start_line <- out$start[["line"]]
  start_col <- out$start[["col"]]
  end_line <- out$end[["line"]]
  end_col <- out$end[["col"]]

  if (start_line == end_line) {
    lines[[start_line]] <- str_replace(
      lines[[start_line]],
      start_col,
      end_col - 1L,
      value = out$reshaped
    )
  } else {
    tail <- str_replace(lines[[end_line]], 1, end_col - 1L)
    head <- str_replace(lines[[start_line]], start_col, value = out$reshaped)
    lines[[start_line]] <- paste0(head, tail)
    lines <- lines[-end_line]
  }

  deleted <- seq2(start_line + 1L, end_line - 1L)
  if (length(deleted)) {
    lines <- lines[-deleted]
  }

  paste0(lines, collapse = "\n")
}
