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

node_call_longer <- function(node, ..., L = FALSE, info) {
  check_call(node)
  base_indent <- 2

  set <- xml_children(node)
  args_nodes <- node_call_arguments(set)
  n_args <- length(args_nodes)
  current_indent_n <- node_indentation(node, info = info)

  if (!n_args) {
    return(node_text(node, info = info))
  }

  prefix <- node_call_type(node) == "prefix"

  if (node_call_needs_space_before_paren(node)) {
    left_paren_text <- " ("
  } else {
    left_paren_text <- "("
  }

  if (prefix) {
    body <- node_text(node_call_body(node), info = info)
    suffix <- paste0(" ", body)
    indent_factor <- 2
  } else {
    suffix <- ""
    indent_factor <- 1
  }

  fn <- node_text(set[[1]], info = info)
  left_paren <- node_call_parens(node)[[1]]

  if (L) {
    fn <- paste0(fn, left_paren_text)
    new_indent_n <- xml_col2(left_paren)
  } else {
    fn <- paste0(fn, left_paren_text, "\n")
    if (prefix) {
      new_indent_n <- current_indent_n + base_indent * indent_factor
    } else {
      new_indent_n <- current_indent_n + base_indent
    }
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

  arg_text <- function(arg) {
    lines <- node_text_lines(arg, info = info)
    lines[[1]] <- line_reindent(lines[[1]], new_indent_n)

    arg_line_n <- xml_line1(arg)[[1]]
    sep_line_ns <- xml_line1(node_call_separators(node))

    if (any(arg_line_n == sep_line_ns)) {
      arg_parent_indent_n <- 0L
    } else {
      arg_parent_indent_n <- xml_col1(arg)[[1L]] + 1L
    }

    if (L) {
      arg_indent_n <- new_indent_n - current_indent_n - arg_parent_indent_n
    } else {
      arg_indent_n <- base_indent * indent_factor - arg_parent_indent_n
    }

    lines <- indent_adjust(lines, arg_indent_n, skip = 1)

    paste0(lines, collapse = "\n")
  }

  args <- map(args_nodes[-n_args], function(node) {
    paste0(arg_text(node), ",\n")
  })
  args <- paste0(as.character(args), collapse = "")

  last <- paste0(
    arg_text(args_nodes[[n_args]]),
    if (!L) "\n",
    if (!L) spaces(current_indent_n),
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

  if (node_call_needs_space_before_paren(node)) {
    left_paren_text <- " ("
  } else {
    left_paren_text <- "("
  }

  fn <- paste0(node_text(set[[1]], info = info), left_paren_text)

  base_indent <- 2
  arg_text <- function(node) {
    lines <- indent_adjust(
      node_text_lines(node, info = info),
      -base_indent
    )
    paste0(lines, collapse = "\n")
  }

  args <- map(args_nodes[-n_args], function(node) {
    paste0(arg_text(node), ", ")
  })

  args <- as.character(compact(args))
  args <- paste0(args, collapse = "")

  if (node_call_type(node) == "prefix") {
    body <- node_text(node_call_body(node), info = info)
    suffix <- paste0(" ", body)
  } else {
    suffix <- ""
  }

  last <- paste0(arg_text(args_nodes[[n_args]]), ")")
  paste0(fn, args, last, suffix)
}
