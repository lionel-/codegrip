test_that("can skip whitespace", {
  lines <- "foo"
  expect_equal(
    skip_space(lines, 1, 1),
    c(line = 1, col = 1)
  )
  expect_equal(
    skip_space(lines, 1, 3),
    c(line = 1, col = 3)
  )

  lines <- "  foo  bar"
  expect_equal(
    skip_space(lines, 1, 1),
    c(line = 1, col = 3)
  )
  expect_equal(
    skip_space(lines, 1, 6),
    c(line = 1, col = 8)
  )
  expect_equal(
    skip_space(lines, 1, 8),
    c(line = 1, col = 8)
  )

  lines <- c("foo", "  bar")
  expect_equal(
    skip_space(lines, 2, 1),
    c(line = 2, col = 3)
  )
  expect_equal(
    skip_space(lines, 2, 3),
    c(line = 2, col = 3)
  )

  lines <- c("foo ", "", "bar")
  expect_equal(
    skip_space(lines, 1, 4),
    c(line = 3, col = 1)
  )
  expect_equal(
    skip_space(lines, 2, 1),
    c(line = 3, col = 1)
  )

  # NOTE: Is this correct?
  lines <- ""
  expect_equal(
    skip_space(lines, 1, 1),
    c(line = 1, col = 0)
  )

  lines <- "  "
  expect_equal(
    skip_space(lines, 1, 1),
    c(line = 1, col = 2)
  )
  expect_equal(
    skip_space(lines, 1, 2),
    c(line = 1, col = 2)
  )

  # NOTE: Should this be `col = 2`?
  lines <- c("  ", " ")
  expect_equal(
    skip_space(lines, 1, 1),
    c(line = 2, col = 1)
  )
})
