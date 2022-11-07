reshape <- function(text, line, col) {
  info <- parse_info(text = paste(text, collapse = "\n"))
  xml <- parse_xml(info)

  call <- find_function_call(line, col, data = xml)
  if (is_null(call)) {
    return()
  }

  if (node_call_type(call) == "prefix") {
    reshaped <- switch(
      node_call_shape(call),
      wide = if (length(node_call_arguments(call)) == 1) {
        node_call_longer(call, info = info)
      } else {
        node_call_longer(call, info = info, L = TRUE)
      },
      L = node_call_longer(call, info = info),
      long = node_call_wider(call, info = info),
      node_text(call)
    )
  } else {
    reshaped <- switch(
      node_call_shape(call),
      wide = node_call_longer(call, info = info),
      L = ,
      long = node_call_wider(call, info = info),
      node_text(call)
    )
  }

  pos <- node_positions(call)

  list(
    reshaped = reshaped,
    start = c(line = pos$line1, col = pos$col1),
    end = c(line = pos$line2, col = pos$col2 + 1L)
  )
}
