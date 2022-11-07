test_that("reshape() cycles function calls and definitions", {
  expect_snapshot({
    code <- "foofybaz()"
    snap_reshape_cycle(2, code)

    code <- "foofybaz(a)"
    snap_reshape_cycle(3, code)

    code <- "foofybaz(a, b = 1, c)"
    snap_reshape_cycle(3, code)


    code <- "function() NULL"
    snap_reshape_cycle(2, code)

    code <- "function(a) NULL"
    snap_reshape_cycle(3, code)

    code <- "function(a, b = 1, c) NULL"
    snap_reshape_cycle(4, code)
  })
})

# Might change in the future
test_that("reshape() cycles other call-like constructs", {
  expect_snapshot({
    code <- "if (a) NULL"
    snap_reshape_cycle(2, code)

    code <- "if (a) b else c"
    snap_reshape_cycle(2, code)

    code <- "while (a) NULL"
    snap_reshape_cycle(2, code)

    code <- "for (i in x) NULL"
    snap_reshape_cycle(1, code)
  })
})
