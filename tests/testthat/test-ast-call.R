test_that("can find function call node for position", {
  path <- test_path("fixtures", "calls.R")
  xml <- parse_xml(path)
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
  xml <- parse_xml(path)

  expect_snapshot({
    "Cursor on `function`"
    node <- find_function_call(2, 13, data = xml)
    cat_line(node_text(node, path))

    "Cursor on `quux`"
    node <- find_function_call(4, 4, data = xml)
    cat_line(node_text(node, path))

    "Cursor on complex call"
    node <- find_function_call(5, 3, data = xml)
    cat_line(node_text(node, path))

    "Cursor on `hop`"
    node <- find_function_call(11, 1, data = xml)
    cat_line(node_text(node, path))
  })
})

test_that("find_function_calls() selects from current node", {
  text <- "foo(bar())"
  xml <- parse_xml(text = text)

  calls <- find_function_calls(xml)
  expect_length(calls, 2)

  expect_equal(
    node_text(calls[[1]], text = text),
    "foo(bar())"
  )
  expect_equal(
    node_text(calls[[2]], text = text),
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
  expr <- parse_xml_one(text = "foo()")
  expect_true(node_is_call(expr))

  expr <- parse_xml_one(text = "foo(bar())")
  expect_true(node_is_call(expr))

  expr <- parse_xml_one(text = "foo + bar")
  expect_false(node_is_call(expr))

  fn <- function(x) check_call(x)
  expect_snapshot({
    (expect_error(fn(expr)))
  })
})

test_that("can find arguments", {
  text <- "foo(1, 2, 3)"
  expr <- parse_xml_one(text = text)
  args <- node_call_arguments(expr)

  expect_equal(
    lapply(args, \(x) node_text(x, text = text)),
    list("1", "2", "3")
  )
})
