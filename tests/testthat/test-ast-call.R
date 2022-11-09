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

test_that("can retrieve argument of if calls", {
  info <- parse_info(text = "if (a) b")
  node <- parse_xml_one(info)
  expect_equal(
    map(node_call_arguments(node), node_text, info = info),
    list("a")
  )

  info <- parse_info(text = "if (a) b else c")
  node <- parse_xml_one(info)
  expect_equal(
    map(node_call_arguments(node), node_text, info = info),
    list("a")
  )
})

test_that("can retrieve body of prefix calls", {
  expect_null(node_call_body(p("foo()")))

  info <- parse_info(text = "function(a) b")
  node <- parse_xml_one(info)
  expect_equal(
    map(node_call_body(node), node_text, info = info),
    list("b")
  )

  info <- parse_info(text = "while (a) b")
  node <- parse_xml_one(info)
  expect_equal(
    map(node_call_body(node), node_text, info = info),
    list("b")
  )

  info <- parse_info(text = "if (a) b")
  node <- parse_xml_one(info)
  expect_equal(
    map(node_call_body(node), node_text, info = info),
    list("b")
  )

  info <- parse_info(text = "if (a) b else c")
  node <- parse_xml_one(info)
  expect_equal(
    map(node_call_body(node), node_text, info = info),
    list("b", "else", "c")
  )

  expect_error(
    node_call_body(p("for (i in x) b")),
    "must be a function call node"
  )
})

test_that("can detect prefix calls", {
  expect_equal(
    node_call_type(p("function(a) NULL")),
    "prefix"
  )
  expect_equal(
    node_call_type(p("if (a) NULL")),
    "prefix"
  )
  expect_equal(
    node_call_type(p("while (a) NULL")),
    "prefix"
  )

  # `for` calls are not ordinary parenthesised expressions
  expect_error(
    node_call_type(p("for (x in i) NULL")),
    "must be a function call node"
  )
})
