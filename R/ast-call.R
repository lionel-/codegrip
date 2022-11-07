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
  check_call(node)
  set <- node_children(node)

  # Remove prefix call (function, while, etc) body
  if (node_call_type(node) == "prefix") {
    set <- set[-length(set)]
  }

  # Remove function node and parentheses
  set <- set[-c(1:2, length(set))]

  # Split on comma
  split_sep(set, xml_name(set) == "OP-COMMA")
}

node_call_type <- function(node) {
  prefix_fns <- c(
    "FUNCTION",
    "IF",
    "FOR",
    "WHILE"
  )

  if (node_call_fn(node) %in% prefix_fns) {
    "prefix"
  } else {
    "bare"
  }
}

node_call_fn <- function(node) {
  check_call(node)
  set <- node_children(node)
  xml_name(set[[1]])
}

node_call_shape <- function(node) {
  check_call(node)

  set <- xml_children(node)
  args <- node_call_arguments(set)

  parens <- node_call_parens(node)
  left_paren <- parens[[1]]
  right_paren <- parens[[2]]

  if (!length(args)) {
    if (identical(xml_line1(left_paren), xml_line1(right_paren))) {
      return("wide")
    } else if (identical(xml_col1(left_paren), xml_col1(right_paren) - 1L)) {
      return("L")
    } else {
      return("long")
    }
  }

  # Simple heuristic: If first argument is on the same line as the
  # opening paren, it's horizontal. Otherwise, it's vertical.
  paren_line1 <- xml_line1(left_paren)
  arg_line1 <- min(xml_line1(args[[1]]))

  if (!identical(paren_line1, arg_line1)) {
    return("long")
  }
  if (length(args) <= 1) {
    return("wide")
  }

  paren_col1 <- xml_col1(left_paren)
  arg_col1 <- min(xml_col1(args[[2]]))

  if (identical(paren_col1, arg_col1 - 1L)) {
    "L"
  } else {
    "wide"
  }
}

node_call_parens <- function(node) {
  check_call(node)
  set <- xml_children(node)

  left <- set[[2]]

  if (node_call_type(node) == "prefix") {
    right <- set[[length(set) - 1]]
  } else {
    right <- set[[length(set)]]
  }

  list(left = left, right = right)
}

node_call_longer <- function(node, ..., L = FALSE, info) {
  check_call(node)

  set <- xml_children(node)
  args_nodes <- node_call_arguments(set)
  n_args <- length(args_nodes)

  if (!n_args) {
    return(node_text(node, info = info))
  }

  prefix <- node_call_type(node) == "prefix"

  if (prefix) {
    body <- node_text(set[[length(set)]], info = info)
    suffix <- paste0(" ", body)
  } else {
    suffix <- ""
  }

  indent_n <- node_indentation(node, info = info)
  indent <- strrep(" ", indent_n)

  fn <- node_text(set[[1]], info = info)

  if (L) {
    fn <- paste0(fn, "(")
    left_paren <- node_call_parens(node)[[1]]
    indent_args <- strrep(" ", xml_col2(left_paren))
  } else {
    fn <- paste0(fn, "(\n")
    if (prefix) {
      indent_args_n <- indent_n + 2 * 2
    } else {
      indent_args_n <- indent_n + 2
    }
    indent_args <- strrep(" ", indent_args_n)
  }

  if (L) {
    fn <- paste0(fn, node_text(args_nodes[[1]], info = info))

    if (n_args == 1) {
      return(paste0(fn, ")", suffix))
    }

    if (n_args > 1) {
      fn <- paste0(fn, ",\n")
    }

    n_args <- n_args - 1L
    args_nodes <- args_nodes[-1]
  }

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
    if (!L) "\n",
    if (!L) indent,
    ")"
  )

  paste0(fn, args, last, suffix)
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

  if (node_call_type(node) == "prefix") {
    body <- node_text(set[[length(set)]], info = info)
    suffix <- paste0(" ", body)
  } else {
    suffix <- ""
  }

  last <- paste0(node_text(args_nodes[[n_args]], info = info), ")")
  paste0(fn, args, last, suffix)
}
