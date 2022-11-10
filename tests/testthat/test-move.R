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

test_that("can walk forward and backward", {
  code <-
"foo((
  bar(
    point(1, 1)
  )
))
"
  info <- parse_info(text = code)

  a <- c(line = 1, col = 1)
  b <- c(line = 1, col = 4)
  c <- c(line = 1, col = 5)
  d <- c(line = 2, col = 6)
  e <- c(line = 3, col = 10)

  expect_equal(inject(walk_info(!!!a, info = info)), b)
  expect_equal(inject(walk_info(!!!b, info = info)), c)
  expect_equal(inject(walk_info(!!!c, info = info)), d)
  expect_equal(inject(walk_info(!!!d, info = info)), e)
  expect_null(inject(walk_info(!!!e, info = info)))

  expect_equal(inject(back_info(!!!e, info = info)), d)
  expect_equal(inject(back_info(!!!d, info = info)), c)
  expect_equal(inject(back_info(!!!c, info = info)), b)
  expect_null(inject(back_info(!!!b, info = info)))
  expect_null(inject(back_info(!!!a, info = info)))
})
