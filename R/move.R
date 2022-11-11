move_outside_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  node <- node_at_position(line, col, data = xml)
  if (is_null(node)) {
    return(NULL)
  }

  # Make sure we progress outwards
  col <- col - 1L

  node <- find_reshape_node(node, line, col)
  node <- node_non_terminal_parent(node)

  if (is.na(node)) {
    NULL
  } else {
    c(
      line = xml_line1(node),
      col = xml_col1(node)
    )
  }
}

move_inside_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  node <- node_at_position(line, col, data = xml)
  if (is_null(node)) {
    return(NULL)
  }

  if (vctrs::vec_compare(df_pos(line, col), as_df_pos(node)) > 0) {
    return(NULL)
  }

  if (is_delimiter(node) || is_prefix_fn(node)) {
    node <- node_parent(node)
  } else {
    # First parent: `expr` node. Second parent: `call` node.
    parent <- node_parent(node)
    if (!any(is_delimiter(xml_children(parent)))) {
      node <- node_parent(parent)
    }
  }

  set <- xml_children(node)
  loc <- detect_index(set, is_delimiter)

  if (!loc || length(set) == loc) {
    return(NULL)
  }

  down <- set[[loc + 1]]
  down_line <- xml_line1(down)
  down_col <- xml_col1(down)

  if (line == down_line && col == down_col) {
    return(NULL)
  }

  c(
    line = down_line,
    col = down_col
  )
}

move_next_info <- function(line, col, ..., info) {
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

move_previous_info <- function(line, col, ..., info) {
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
