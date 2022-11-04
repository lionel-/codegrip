# This also selects function definitions
find_function_calls <- function(data) {
  xml_find_all(data, ".//*[following-sibling::OP-LEFT-PAREN]/..")
}

find_function_call <- function(line, col, ..., data) {
  check_dots_empty()

  calls <- find_function_calls(data)
  loc <- locate_node(calls, line, col, data = data)

  if (loc) {
    calls[[loc]]
  } else {
    NULL
  }
}

check_call <- function(node,
                       arg = caller_arg(node),
                       call = caller_env()) {
  check_node_or_nodeset(node, arg = arg, call = call)

  if (!node_is_call(node)) {
    abort(
      sprintf("`%s` must be a function call node.", arg),
      arg = arg,
      call = call
    )
  }
}

node_is_call <- function(node) {
  check_node_or_nodeset(node, arg = arg, call = call)

  if (inherits(node, "xml_node")) {
    set <- xml_children(node)
  } else {
    set <- node
  }
  if (length(set) < 3) {
    return(FALSE)
  }

  identical(xml_name(set[[2]]), "OP-LEFT-PAREN")
}

node_call_arguments <- function(node) {
  if (inherits(node, "xml_nodeset")) {
    set <- node
  } else {
    set <- xml_children(node)
  }
  check_call(set)

  # Remove function def body
  if (xml_name(set[[1]]) == "FUNCTION") {
    set <- set[-length(set)]
  }

  # Remove function node and parentheses
  set <- set[-c(1:2, length(set))]

  # Split on comma
  split_sep(set, xml_name(set) == "OP-COMMA")
}

node_call_is_horizontal <- function(node) {
  check_call(node)

  set <- xml_children(node)
  args <- node_call_arguments(set)

  if (!length(args)) {
    return(TRUE)
  }

  # Simple heuristic: If first argument is on the same line as the
  # opening paren, it's horizontal. Otherwise, it's vertical.
  line1_arg <- min(xml_attr_int(args[[1]], "line1"))
  line1_paren <- xml_attr_int(set[[2]], "line1")
  identical(line1_arg, line1_paren)
}

node_call_is_function_def <- function(node) {
  check_call(node)

  set <- xml_children(node)
  if (length(set) <= 3) {
    return(FALSE)
  }

  identical(xml_name(set[[1]]), "FUNCTION")
}

node_call_longer <- function(node, ..., info) {
  check_call(node)

  set <- xml_children(node)
  args_nodes <- node_call_arguments(set)
  n_args <- length(args_nodes)

  if (!n_args) {
    return(node_text(node, info = info))
  }

  indent_n <- node_indentation(node, info = info)
  indent <- strrep(" ", indent_n)
  indent_args <- strrep(" ", indent_n + 2)

  fn <- paste0(node_text(set[[1]], info = info), "(\n")

  args <- map(args_nodes[-n_args], function(node) {
    text <- node_text(node, info = info)

    # Increase indentation of multiline args
    text <- gsub("\n", paste0("\n", indent_args), text)

    paste0(indent_args, text, ",\n")
  })
  args <- paste0(as.character(args), collapse = "")

  last <- paste0(
    indent_args,
    node_text(args_nodes[[n_args]], info = info),
    "\n",
    indent,
    ")"
  )

  paste0(fn, args, last)
}

node_call_wider <- function(node, ..., info) {
  check_call(node)

  set <- xml_children(node)
  args_nodes <- node_call_arguments(set)
  n_args <- length(args_nodes)

  if (!n_args) {
    return(node_text(node, info = info))
  }

  fn <- paste0(node_text(set[[1]], info = info), "(")

  args <- map(args_nodes[-n_args], function(node) {
    text <- node_text(node, info = info)

    # Decrease indentation of multiline args
    text <- gsub("\n(  |\t)", "\n", text)

    paste0(text, ", ")
  })

  args <- as.character(compact(args))
  args <- paste0(args, collapse = "")

  last <- paste0(node_text(args_nodes[[n_args]], info = info), ")")
  paste0(fn, args, last)
}
