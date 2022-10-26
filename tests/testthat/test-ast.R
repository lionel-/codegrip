test_that("Can detect indentations", {
  path <- test_path("fixtures", "calls.R")
  xml <- parse_xml(path)

  calls <- find_function_calls(xml)

  indents <- sapply(calls, function(call) node_indentation(call, file = path))
  expect_equal(
    indents,
    c(0L, 2L, 2L, 2L, 0L)
  )
})
