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
  check_node_or_nodeset(node)

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

  right_paren <- match("OP-RIGHT-PAREN", xml_name(set))
  if (!right_paren) {
    abort("Can't find right paren.", .internal = TRUE)
  }

  # Remove prefix call (function, while, etc) body
  n <- length(set)
  if (right_paren < n) {
    set <- set[-seq(right_paren + 1, n)]
    n <- right_paren
  }

  # Remove function node and parentheses
  set <- set[-c(1:2, n)]

  if (length(set)) {
    # Split on comma
    split_sep(set, xml_name(set) == "OP-COMMA")
  } else {
    list()
  }
}

node_call_body <- function(node) {
  check_call(node)
  set <- node_children(node)

  right_paren <- match("OP-RIGHT-PAREN", xml_name(set))
  if (!right_paren) {
    abort("Can't find right paren.", .internal = TRUE)
  }

  n <- length(set)
  if (right_paren == n) {
    NULL
  } else {
    set[seq(right_paren + 1, n)]
  }
}

node_call_type <- function(node) {
  if (node_call_fn(node) %in% prefix_fn_node_names) {
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

node_call_needs_space_before_paren <- function(node) {
  need_space_fns <- c(
    "IF",
    "FOR",
    "WHILE"
  )

  node_call_fn(node) %in% need_space_fns
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

node_call_separators <- function(node) {
  set <- xml_children(node)
  set[xml_name(set) %in% c("OP-LEFT-PAREN", "OP-COMMA")]
}
