test_that("can rise outwards", {
  code <-
"foo((
  bar(
    point(4, 5)
  )
))
"

  info <- parse_info(text = code)

  expect_null(
    rise_info(1, 3, info = info)
  )
  expect_equal(
    rise_info(3, 5, info = info),
    c(line = 2, col = 6)
  )
  expect_equal(
    rise_info(2, 6, info = info),
    c(line = 1, col = 5)
  )
  expect_equal(
    rise_info(1, 5, info = info),
    c(line = 1, col = 4)
  )
  expect_null(
    rise_info(1, 4, info = info)
  )
})

test_that("can walk forward", {
  code <-
"foo((
  bar(
    point(1, 1)
  )
))
"
  info <- parse_info(text = code)

  expect_equal(
    walk_info(1, 1, info = info),
    c(line = 1, col = 4)
  )
  expect_equal(
    walk_info(1, 4, info = info),
    c(line = 1, col = 5)
  )
  expect_equal(
    walk_info(1, 5, info = info),
    c(line = 2, col = 6)
  )
  expect_null(walk_info(3, 10, info = info))
})
