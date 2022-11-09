test_that("can detect call type", {
  expect_call_shape("()", "wide")
  expect_call_shape("(a)", "wide")
  expect_call_shape("(a, b, c)", "wide")
  expect_call_shape("\n(a, b, c)\n", "wide")

  # Aligned argument or paren determines L shape
  expect_call_shape("(\n         )", "L")
  expect_call_shape("(a,\n         b)", "L")

  # Simple heuristic: first argument determines wide shape
  expect_call_shape("(a,\n b, c)", "wide")
  expect_call_shape("(a, b, c\n)", "wide")
  expect_call_shape("(a, b = b(\n), c)", "wide")

  # Simple heuristic: unaligned argument or paren determines long shape
  expect_call_shape("(\n)", "long")
  expect_call_shape("(\na)", "long")
  expect_call_shape("(\na, b, c)", "long")
  expect_call_shape("(\n\na, b, c)", "long")
})

test_that("can reshape call longer", {
  expect_snapshot({
    print_longer("()")
    print_longer("(a)")
    print_longer("(b, c)")
    print_longer("(a, b, c)")
    print_longer("(a = 1, b, c = 3)")

    "Leading indentation is preserved. First line is not indented"
    "because the reshaped text is meant to be inserted at the node"
    "coordinates."
    print_longer("  ()")
    print_longer("  (a)")
    print_longer("  (a, b)")

    "Multiline args are indented as is"
    print_longer("(a, b = foo(\n  bar\n), c)")
    print_longer("(a, b =\n  2, c)")
    print_longer("  (a, b = foo(\n    bar  \n  ), c)")

    "Wrong indentation is preserved"
    print_longer("(a, b = foo(\nbar\n), c)")
    print_longer("  (a, b = foo(\n  bar\n), c)")
  })
})

test_that("can reshape call longer (L shape)", {
  expect_snapshot({
    print_longer_l("()")
    print_longer_l("(a)")
    print_longer_l("(a, b)")
    print_longer_l("(a, b, c)")
    print_longer_l("(a = 1, b, c = 3)")

    "Leading indentation is preserved. First line is not indented"
    "because the reshaped text is meant to be inserted at the node"
    "coordinates."
    print_longer_l("  ()")
    print_longer_l("  (a)")
    print_longer_l("  (a, b)")

    "Multiline args are indented as is"
    print_longer_l("(a, b = foo(\n  bar\n), c)")
    print_longer_l("(a, b =\n  2, c)")
    print_longer_l("  (a, b = foo(\n    bar  \n  ), c)")

    "Wrong indentation is preserved"
    print_longer_l("(a, b = foo(\nbar\n), c)")
    print_longer_l("  (a, b = foo(\n  bar\n), c)")
  })
})

test_that("can reshape call wider", {
  expect_snapshot({
    print_wider("()")
    print_wider("(\n  a\n)")
    print_wider("(\n\n  a\n\n)")
    print_wider("(\n  a, \n  b\n)")
    print_wider("(\n  a, \n  b, \n  c\n)")
    print_wider("(\n  a = 1,\n  b,\n  c = 3\n)")

    "Leading indentation is ignored"
    print_wider("  ()")
    print_wider("  (\n  a\n)")
    print_wider("  (\n\n  a\n\n,\n b)")

    "Multiline args are indented as is"
    print_wider("(\n  a,\n  b = foo(\n    bar\n  ),\n  c)")
    print_wider("(\n  a,\n  b =\n    2,\n  c\n)")
  })
})
