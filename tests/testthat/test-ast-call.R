test_that("can find function call node for position", {
  path <- test_path("fixtures", "calls.R")
  xml <- parse_xml(parse_info(path))
  calls <- find_function_calls(xml)
  lines <- readLines(path)

  nodes <- function(line) {
    cols <- seq_len(nchar(lines[[line]]))
    vapply(
      cols,
      function(col) locate_node(calls, line, col, data = xml),
      integer(1)
    )
  }

  call_nodes <- lapply(seq_along(lines), nodes)
  expect_snapshot({
    "Node locations of function calls for all combinations of line and col"
    call_nodes
  })

  node <- find_function_call(4, 4, data = xml)
  expect_snapshot({
    "Positions of function call at 4:4"
    node_positions(node)[1:4]
  })
})

test_that("can retrieve function call text", {
  path <- test_path("fixtures", "calls.R")
  info <- parse_info(path)
  xml <- parse_xml(info)

  expect_snapshot({
    "Cursor on `function`"
    node <- find_function_call(2, 13, data = xml)
    cat_line(node_text(node, info = info))

    "Cursor on `quux`"
    node <- find_function_call(4, 4, data = xml)
    cat_line(node_text(node, info = info))

    "Cursor on complex call"
    node <- find_function_call(5, 3, data = xml)
    cat_line(node_text(node, info = info))

    "Cursor on `hop`"
    node <- find_function_call(11, 1, data = xml)
    cat_line(node_text(node, info = info))
  })
})

test_that("find_function_calls() selects from current node", {
  info <- parse_info(text = "foo(bar())")
  xml <- parse_xml(info)

  calls <- find_function_calls(xml)
  expect_length(calls, 2)

  expect_equal(
    node_text(calls[[1]], info = info),
    "foo(bar())"
  )
  expect_equal(
    node_text(calls[[2]], info = info),
    "bar()"
  )

  expect_equal(
    find_function_calls(calls[[1]]),
    calls
  )

  inner_calls <- find_function_calls(calls[[2]])
  expect_length(inner_calls, 1)

  expect_equal(
    inner_calls[[1]],
    calls[[2]]
  )
})

test_that("check_call() detects calls", {
  expr <- parse_xml_one(parse_info(text = "foo()"))
  expect_true(node_is_call(expr))

  expr <- parse_xml_one(parse_info(text = "foo(bar())"))
  expect_true(node_is_call(expr))

  expr <- parse_xml_one(parse_info(text = "foo + bar"))
  expect_false(node_is_call(expr))

  fn <- function(x) check_call(x)
  expect_snapshot({
    (expect_error(fn(expr)))
  })
})

test_that("can retrieve arguments of calls", {
  expr <- parse_xml_one(parse_info(text = "foo()"))
  expect_equal(
    node_call_arguments(expr),
    list()
  )

  info <- parse_info(text = "foo(1, 2, 3)")
  expr <- parse_xml_one(info)
  args <- node_call_arguments(expr)

  expect_equal(
    node_list_text(args, info = info),
    list("1", "2", "3")
  )

  info <- parse_info(text = "foo(a = 1, b, c = 3 + \n4)")
  node <- parse_xml_one(info)
  args <- node_call_arguments(node)

  expect_equal(
    node_list_text(args, info = info),
    list("a = 1", "b", "c = 3 + \n4")
  )
})

test_that("can retrieve arguments of function definitions", {
  expr <- parse_xml_one(parse_info(text = "function() NULL"))
  expect_equal(
    node_call_arguments(expr),
    list()
  )

  info <- parse_info(text = "function(a, b, c) NULL")
  expr <- parse_xml_one(info)
  args <- node_call_arguments(expr)

  expect_equal(
    node_list_text(args, info = info),
    list("a", "b", "c")
  )

  info <- parse_info(text = "function(a = 1, b, c = 3) NULL")
  expr <- parse_xml_one(info)
  args <- node_call_arguments(expr)

  expect_equal(
    node_list_text(args, info = info),
    list("a = 1", "b", "c = 3")
  )

  info <- parse_info(text = "function(a = 1, b, c = 3 + \n4) NULL")
  node <- parse_xml_one(info)
  args <- node_call_arguments(node)

  expect_equal(
    node_list_text(args, info = info),
    list("a = 1", "b", "c = 3 + \n4")
  )
})

test_that("can detect call type", {
  expect_call_shape("()", "wide")
  expect_call_shape("(a)", "wide")
  expect_call_shape("(a, b, c)", "wide")
  expect_call_shape("\n(a, b, c)\n", "wide")

  # Aligned argument or paren determines L shape
  expect_call_shape("(\n         )", "L")
  expect_call_shape("(a,\n         b)", "L")

  # Simple heuristic: first argument determines wide shape
  expect_call_shape("(a,\n b, c)", "wide")
  expect_call_shape("(a, b, c\n)", "wide")
  expect_call_shape("(a, b = b(\n), c)", "wide")

  # Simple heuristic: unaligned argument or paren determines long shape
  expect_call_shape("(\n)", "long")
  expect_call_shape("(\na)", "long")
  expect_call_shape("(\na, b, c)", "long")
  expect_call_shape("(\n\na, b, c)", "long")
})

test_that("can reshape call longer", {
  expect_snapshot({
    print_longer("()")
    print_longer("(a)")
    print_longer("(b, c)")
    print_longer("(a, b, c)")
    print_longer("(a = 1, b, c = 3)")

    "Leading indentation is preserved. First line is not indented"
    "because the reshaped text is meant to be inserted at the node"
    "coordinates."
    print_longer("  ()")
    print_longer("  (a)")
    print_longer("  (a, b)")

    "Multiline args are indented as is"
    print_longer("(a, b = foo(\nbar\n), c)")
    print_longer("(a, b = foo(\n  bar\n), c)")
    print_longer("  (a, b = foo(\n  bar\n), c)")
    print_longer("(a, b =\n  2, c)")
  })
})

test_that("can reshape call longer (L shape)", {
  expect_snapshot({
    print_longer_l("()")
    print_longer_l("(a)")
    print_longer_l("(a, b)")
    print_longer_l("(a, b, c)")
    print_longer_l("(a = 1, b, c = 3)")

    "Leading indentation is preserved. First line is not indented"
    "because the reshaped text is meant to be inserted at the node"
    "coordinates."
    print_longer_l("  ()")
    print_longer_l("  (a)")
    print_longer_l("  (a, b)")

    "Multiline args are indented as is"
    print_longer_l("(a, b = foo(\nbar\n), c)")
    print_longer_l("(a, b = foo(\n  bar\n), c)")
    print_longer_l("  (a, b = foo(\n  bar\n), c)")
    print_longer_l("(a, b =\n  2, c)")
  })
})

test_that("can reshape call wider", {
  expect_snapshot({
    print_wider("()")
    print_wider("(\n  a\n)")
    print_wider("(\n\n  a\n\n)")
    print_wider("(\n  a, \n  b\n)")
    print_wider("(\n  a, \n  b, \n  c\n)")
    print_wider("(\n  a = 1,\n  b,\n  c = 3\n)")

    "Leading indentation is ignored"
    print_wider("  ()")
    print_wider("  (\n  a\n)")
    print_wider("  (\n\n  a\n\n,\n b)")

    "Multiline args are indented as is"
    print_wider("(\n  a,\n  b = foo(\n    bar\n  ),\n  c)")
    print_wider("(\n  a,\n  b =\n    2,\n  c\n)")
  })
})

test_that("can detect function defs", {
  def <- parse_xml_one(parse_info(text = "function() NULL"))
  expect_true(node_call_is_function_def(def))
})
