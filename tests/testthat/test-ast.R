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

test_that("indent_adjust() works", {
  code <- as_lines("{
  a
  b
}")
  exp <- as_lines("  {
    a
    b
  }")
  out <- indent_adjust(code, 2)
  expect_equal(out, exp)
  expect_equal(indent_adjust(out, -2), code)

  # Newlines in strings are preserved
  code <- as_lines("{'
  a
  b
'}")
  exp <- as_lines("  {'
  a
  b
'}")
  out <- indent_adjust(code, 2)
  expect_equal(out, exp)
  expect_equal(indent_adjust(out, -2), code)
})
