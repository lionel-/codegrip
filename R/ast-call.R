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

  set <- set[-1]
  set <- set[xml_name(set) == "expr"]

  set
}

node_call_is_horizontal <- function(node) {
  check_call(node)

  set <- xml_children(node)

  if (length(set) <= 3) {
    return(TRUE)
  }

  # Simple heuristic: If first argument is on the same line as the
  # opening paren, it's horizontal. Otherwise, it's vertical.
  line1 <- xml_attr_int(set, "line1")
  identical(line1[[2]], line1[[3]])
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
  n <- length(set)

  if (n == 3) {
    return(node_text(node, info = info))
  }

  indent_n <- node_indentation(node, info = info)
  indent <- strrep(" ", indent_n)
  indent_args <- strrep(" ", indent_n + 2)

  fn <- paste0(node_text(set[[1]], info = info), "(\n")

  args <- node_call_arguments(set)
  args <- map(args[-length(args)], function(node) {
    text <- node_text(node, info = info)

    # Increase indentation of multiline args
    text <- gsub("\n", paste0("\n", indent_args), text)

    paste0(indent_args, text, ",\n")
  })
  args <- paste0(as.character(args), collapse = "")

  last <- paste0(
    indent_args,
    node_text(set[[n - 1]], info = info),
    "\n",
    indent,
    ")"
  )

  paste0(fn, args, last)
}

node_call_wider <- function(node, ..., info) {
  check_call(node)

  set <- xml_children(node)
  n <- length(set)

  if (n == 3) {
    return(node_text(node, info = info))
  }

  fn <- paste0(node_text(set[[1]], info = info), "(")

  args <- set[-c(1:2, c(-1, 0) + n)]
  args <- map(args, function(node) {
    if (xml_name(node) != "OP-COMMA") {
      text <- node_text(node, info = info)

      # Decrease indentation of multiline args
      text <- gsub("\n(  |\t)", "\n", text)

      paste0(text, ", ")
    }
  })

  args <- as.character(compact(args))
  args <- paste0(args, collapse = "")

  last <- paste0(node_text(set[[n - 1]], info = info), ")")

  paste0(fn, args, last)
}
