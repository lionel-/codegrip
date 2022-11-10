rise_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  node <- node_at_position(line, col, data = xml)
  if (is_null(node)) {
    return(NULL)
  }

  # Make sure we progress outwards
  col <- col - 1L

  node <- find_reshape_node(node, line, col)

  if (is.na(node)) {
    NULL
  } else {
    c(
      line = xml_line1(node),
      col = xml_col1(node)
    )
  }
}
