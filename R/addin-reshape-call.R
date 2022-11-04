addin_reshape <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  text <- context$contents
  sel <- context$selection[[1]]$range

  # No reshaping for selections
  if (!identical(sel$start, sel$end)) {
    return()
  }

  line <- sel$start[[1]]
  col <- sel$start[[2]]

  info <- parse_info(text = paste(text, collapse = "\n"))
  xml <- parse_xml(info)

  call <- find_function_call(line, col, data = xml)
  if (is_null(call)) {
    return()
  }

  reshaped <- switch(
    node_call_shape(call),
    wide = node_call_longer(call, info = info),
    long = node_call_wider(call, info = info),
    abort("TODO")
  )

  pos <- node_positions(call)
  pos1 <- rstudioapi::document_position(pos$line1, pos$col1)
  pos2 <- rstudioapi::document_position(pos$line2, pos$col2 + 1L)
  range <- rstudioapi::document_range(pos1, pos2)

  rstudioapi::modifyRange(range, reshaped)
  rstudioapi::setCursorPosition(sel)
}
