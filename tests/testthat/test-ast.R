test_that("Can detect indentations", {
  info <- parse_info(test_path("fixtures", "calls.R"))
  xml <- parse_xml(info)

  calls <- find_function_calls(xml)

  indents <- sapply(calls, function(call) node_indentation(call, info = info))
  expect_equal(
    indents,
    c(0L, 2L, 2L, 2L, 0L)
  )
})
