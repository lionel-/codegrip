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

node_extents <- function(node) {
  data.frame(
    start = xml_start(node),
    end = xml_end(node)
  )
}

move_inside_info <- function(line, col, ..., info) {
  xml <- parse_xml(info)

  pos <- skip_space(lines(info), line, col)
  line <- pos[["line"]]
  col <- pos[["col"]]

  node <- node_at_position(line, col, data = xml)
  if (is_null(node)) {
    return(NULL)
  }

  in_order <- keep(tree_suffix(node), is_terminal)

  # Don't step beyond closing delimiters
  is_close <- which(is_delim_close(in_order))
  if (length(is_close)) {
    in_order <- in_order[seq(1, is_close[[1]])]
  }

  can_step_in <- which(can_step_in(in_order))
  if (!length(can_step_in)) {
    return(NULL)
  }

  inside_node <- in_order[[can_step_in[[1]] + 1L]]
  inside_line <- xml_line1(inside_node)
  inside_col <- xml_col1(inside_node)

  if (line == inside_line && col == inside_col) {
    return(NULL)
  }

  c(
    line = inside_line,
    col = inside_col
  )
}

can_step_in <- function(data) {
  is_delim_open(data)
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
