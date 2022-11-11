move_up_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  node <- node_at_position(line, col, data = xml)
  if (is_null(node)) {
    return(NULL)
  }

  # Make sure we progress outwards
  col <- col - 1L

  node <- find_reshape_node(node, line, col)

  if (is_terminal(node) && !is.na(parent <- node_parent(node))) {
    node <- parent
  }

  if (is.na(node)) {
    NULL
  } else {
    c(
      line = xml_line1(node),
      col = xml_col1(node)
    )
  }
}

move_right_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  current_node <- node_at_position(line, col, data = xml)
  if (is_null(current_node)) {
    return(NULL)
  }

  in_order <- keep(tree_suffix(current_node), is_terminal)

  if (can_reshape(current_node)) {
    in_order <- in_order[-1]
  }

  can_reshape <- which(can_reshape(in_order))
  if (!length(can_reshape)) {
    return(NULL)
  }

  out <- in_order[[can_reshape[[1]]]]
  c(
    line = xml_line1(out),
    col = xml_col1(out)
  )
}

move_left_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  current_node <- node_at_position(line, col, data = xml)
  if (is_null(current_node)) {
    return(NULL)
  }

  in_order <- rev(keep(tree_prefix(current_node), is_terminal))

  if (can_reshape(current_node)) {
    in_order <- in_order[-1]
  }

  can_reshape <- which(can_reshape(in_order))
  if (!length(can_reshape)) {
    return(NULL)
  }

  out <- in_order[[can_reshape[[1]]]]
  c(
    line = xml_line1(out),
    col = xml_col1(out)
  )
}
