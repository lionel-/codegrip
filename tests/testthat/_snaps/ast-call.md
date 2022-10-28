# can find function call node for position

    Code
      # Node locations of function calls for all combinations of line and col
      call_nodes
    Output
      [[1]]
      [1] 0 0 0 0 0 0 0 0 0
      
      [[2]]
       [1] 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1
      
      [[3]]
       [1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      
      [[4]]
       [1] 1 1 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 2 2 2 2 1 1 1 1 1 1
      
      [[5]]
       [1] 1 1 4 4 4 4 4 4 4 4
      
      [[6]]
      [1] 4 4 4 4
      
      [[7]]
      [1] 1 1 1
      
      [[8]]
      integer(0)
      
      [[9]]
      integer(0)
      
      [[10]]
      [1] 5 5 5 5
      
      [[11]]
      [1] 5 5 5 5 5
      
      [[12]]
      [1] 5
      

---

    Code
      # Positions of function call at 4:4
      node_positions(node)[1:4]
    Output
        line1 col1 line2 col2
      1     4    3     4   21

# can retrieve function call text

    Code
      # Cursor on `function`
      node <- find_function_call(2, 13, data = xml)
      cat_line(node_text(node, info = info))
    Output
      function(bar,
                      baz) {
        quux(1, list(2), 3) # foo
        (foo)(4,
        5)
        }
    Code
      # Cursor on `quux`
      node <- find_function_call(4, 4, data = xml)
      cat_line(node_text(node, info = info))
    Output
      quux(1, list(2), 3)
    Code
      # Cursor on complex call
      node <- find_function_call(5, 3, data = xml)
      cat_line(node_text(node, info = info))
    Output
      (foo)(4,
        5)
    Code
      # Cursor on `hop`
      node <- find_function_call(11, 1, data = xml)
      cat_line(node_text(node, info = info))
    Output
      hop(
        hip
      )

# check_call() detects calls

    Code
      (expect_error(fn(expr)))
    Output
      <error/rlang_error>
      Error in `fn()`:
      ! `x` must be a function call node.

# can reshape call longer

    Code
      print_longer("list()")
    Output
      list()
    Code
      print_longer("list(1)")
    Output
      list(
        1
      )
    Code
      print_longer("list(1, 2)")
    Output
      list(
        1,
        2
      )
    Code
      print_longer("list(1, 2, 3)")
    Output
      list(
        1,
        2,
        3
      )
    Code
      # Leading indentation is preserved. First line is not indented
      # because the reshaped text is meant to be inserted at the node
      # coordinates.
      print_longer("  list()")
    Output
      list()
    Code
      print_longer("  list(1)")
    Output
      list(
          1
        )
    Code
      print_longer("  list(1, 2)")
    Output
      list(
          1,
          2
        )
    Code
      # Multiline args are indented as is
      print_longer("list(1, foo(\nbar\n), 3)")
    Output
      list(
        1,
        foo(
        bar
        ),
        3
      )
    Code
      print_longer("list(1, foo(\n  bar\n), 3)")
    Output
      list(
        1,
        foo(
          bar
        ),
        3
      )
    Code
      print_longer("  list(1, foo(\n  bar\n), 3)")
    Output
      list(
          1,
          foo(
            bar
          ),
          3
        )

# can reshape call wider

    Code
      print_wider("list()")
    Output
      list()
    Code
      print_wider("list(\n  1\n)")
    Output
      list(1)
    Code
      print_wider("list(\n\n  1\n\n)")
    Output
      list(1)
    Code
      print_wider("list(\n  1, \n  2\n)")
    Output
      list(1, 2)
    Code
      print_wider("list(\n  1, \n  2, \n  3\n)")
    Output
      list(1, 2, 3)
    Code
      # Leading indentation is ignored
      print_wider("  list()")
    Output
      list()
    Code
      print_wider("  list(\n  1\n)")
    Output
      list(1)
    Code
      print_wider("  list(\n\n  1\n\n,\n 2)")
    Output
      list(1, 2)
    Code
      # Multiline args are indented as is
      print_wider("list(\n  1,\n  foo(\n    bar\n  ),\n  3)")
    Output
      list(1, foo(
        bar
      ), 3)

