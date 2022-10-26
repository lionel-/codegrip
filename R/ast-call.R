# This also selects function definitions
find_function_calls <- function(data) {
  xml_find_all(data, ".//*[following-sibling::OP-LEFT-PAREN]/..")
}

find_function_call <- function(line, col, ..., data) {
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
  check_node(node, arg = arg, call = call)

  if (!node_is_call(node)) {
    abort(
      sprintf("`%s` must be a function call node.", arg),
      arg = arg,
      call = call
    )
  }
}

node_is_call <- function(node) {
  check_node(node)

  children <- xml_children(node)
  if (length(children) < 3) {
    return(FALSE)
  }

  identical(xml_name(children[[2]]), "OP-LEFT-PAREN")
}
