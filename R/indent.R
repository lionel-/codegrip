node_indentation <- function(node, ..., info) {
  check_dots_empty()
  check_node(node)

  line <- xml_line1(node)
  line_text <- lines(info)[[line]]

  line_indentation(line_text)
}

line_indentation <- function(line) {
  line <- replace_tabs(line)
  indent <- regexpr("[^[:space:]]", line) - 1L
  max(indent, 0L)
}

indent_adjust <- function(lines, indent, skip = -1) {
  if (!length(lines)) {
    return(lines)
  }

  data <- parse_xml(parse_info(lines = lines))
  nodes <- xml_find_all(data, "//*")

  for (i in seq_along(lines)) {
    if (i == skip) {
      next
    }

    line <- replace_tabs(lines[[i]])

    # Don't indent empty lines with parasite whitespace
    if (!nzchar(line)) {
      next
    }

    col <- regexpr("[^[:space:]]", line)
    col <- if (col < 0) 1L else col

    # Find the AST node to which the new line belongs
    loc <- locate_node(nodes, i, col, data = data)
    if (!loc) {
      abort("Expected a node in `indent_adjust()`.", .internal = TRUE)
    }
    node <- nodes[[loc]]

    # Do not adjust indentation of lines inside strings
    if (xml_name(node) == "STR_CONST" &&
        (col != xml_col1(node) ||
         i != xml_line1(node))) {
      next
    }

    new_indent_n <- max(line_indentation(line) + indent, 0)
    lines[[i]] <- line_reindent(line, new_indent_n)
  }

  lines
}
