test_that("can move up", {
  code <-
"foo({
  bar(
    point(4, 5)
  )
})
"

  info <- parse_info(text = code)

  expect_null(
    move_up_info(1, 3, info = info)
  )
  expect_equal(
    move_up_info(3, 5, info = info),
    c(line = 2, col = 6)
  )
  expect_equal(
    move_up_info(2, 6, info = info),
    c(line = 1, col = 5)
  )
  expect_equal(
    move_up_info(1, 5, info = info),
    c(line = 1, col = 4)
  )
  expect_null(
    move_up_info(1, 4, info = info)
  )
})

test_that("can move right and left", {
  code <-
"foo({
  bar(
    point(1, 1)
  )
})
"
  info <- parse_info(text = code)

  a <- c(line = 1, col = 1)
  b <- c(line = 1, col = 4)
  c <- c(line = 1, col = 5)
  d <- c(line = 2, col = 6)
  e <- c(line = 3, col = 10)

  expect_equal(inject(move_right_info(!!!a, info = info)), b)
  expect_equal(inject(move_right_info(!!!b, info = info)), c)
  expect_equal(inject(move_right_info(!!!c, info = info)), d)
  expect_equal(inject(move_right_info(!!!d, info = info)), e)
  expect_null(inject(move_right_info(!!!e, info = info)))

  expect_equal(inject(move_left_info(!!!e, info = info)), d)
  expect_equal(inject(move_left_info(!!!d, info = info)), c)
  expect_equal(inject(move_left_info(!!!c, info = info)), b)
  expect_null(inject(move_left_info(!!!b, info = info)))
  expect_null(inject(move_left_info(!!!a, info = info)))
})