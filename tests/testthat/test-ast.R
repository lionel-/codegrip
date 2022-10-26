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
  expect_snapshot(call_nodes)
})
