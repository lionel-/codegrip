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
