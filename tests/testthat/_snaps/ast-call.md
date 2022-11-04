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
      print_longer("()")
    Output
      foofybaz()
      function() NULL
    Code
      print_longer("(a)")
    Output
      foofybaz(
        a
      )
      function(
          a
      ) NULL
    Code
      print_longer("(b, c)")
    Output
      foofybaz(
        b,
        c
      )
      function(
          b,
          c
      ) NULL
    Code
      print_longer("(a, b, c)")
    Output
      foofybaz(
        a,
        b,
        c
      )
      function(
          a,
          b,
          c
      ) NULL
    Code
      print_longer("(a = 1, b, c = 3)")
    Output
      foofybaz(
        a = 1,
        b,
        c = 3
      )
      function(
          a = 1,
          b,
          c = 3
      ) NULL
    Code
      # Leading indentation is preserved. First line is not indented
      # because the reshaped text is meant to be inserted at the node
      # coordinates.
      print_longer("  ()")
    Output
        foofybaz()
        function() NULL
    Code
      print_longer("  (a)")
    Output
        foofybaz(
          a
        )
        function(
            a
        ) NULL
    Code
      print_longer("  (a, b)")
    Output
        foofybaz(
          a,
          b
        )
        function(
            a,
            b
        ) NULL
    Code
      # Multiline args are indented as is
      print_longer("(a, b = foo(\nbar\n), c)")
    Output
      foofybaz(
        a,
        b = foo(
        bar
        ),
        c
      )
      function(
          a,
          b = foo(
          bar
          ),
          c
      ) NULL
    Code
      print_longer("(a, b = foo(\n  bar\n), c)")
    Output
      foofybaz(
        a,
        b = foo(
          bar
        ),
        c
      )
      function(
          a,
          b = foo(
            bar
          ),
          c
      ) NULL
    Code
      print_longer("  (a, b = foo(\n  bar\n), c)")
    Output
        foofybaz(
          a,
          b = foo(
            bar
          ),
          c
        )
        function(
            a,
            b = foo(
              bar
            ),
            c
        ) NULL
    Code
      print_longer("(a, b =\n  2, c)")
    Output
      foofybaz(
        a,
        b =
          2,
        c
      )
      function(
          a,
          b =
            2,
          c
      ) NULL

# can reshape call longer (L shape)

    Code
      print_longer_l("()")
    Output
      foofybaz()
      function() NULL
    Code
      print_longer_l("(a)")
    Output
      foofybaz(a)
      function(a) NULL
    Code
      print_longer_l("(a, b)")
    Output
      foofybaz(a,
               b)
      function(a,
               b) NULL
    Code
      print_longer_l("(a, b, c)")
    Output
      foofybaz(a,
               b,
               c)
      function(a,
               b,
               c) NULL
    Code
      print_longer_l("(a = 1, b, c = 3)")
    Output
      foofybaz(a = 1,
               b,
               c = 3)
      function(a = 1,
               b,
               c = 3) NULL
    Code
      # Leading indentation is preserved. First line is not indented
      # because the reshaped text is meant to be inserted at the node
      # coordinates.
      print_longer_l("  ()")
    Output
        foofybaz()
        function() NULL
    Code
      print_longer_l("  (a)")
    Output
        foofybaz(a)
        function(a) NULL
    Code
      print_longer_l("  (a, b)")
    Output
        foofybaz(a,
                 b)
        function(a,
                 b) NULL
    Code
      # Multiline args are indented as is
      print_longer_l("(a, b = foo(\nbar\n), c)")
    Output
      foofybaz(a,
               b = foo(
               bar
               ),
               c)
      function(a,
               b = foo(
               bar
               ),
               c) NULL
    Code
      print_longer_l("(a, b = foo(\n  bar\n), c)")
    Output
      foofybaz(a,
               b = foo(
                 bar
               ),
               c)
      function(a,
               b = foo(
                 bar
               ),
               c) NULL
    Code
      print_longer_l("  (a, b = foo(\n  bar\n), c)")
    Output
        foofybaz(a,
                 b = foo(
                   bar
                 ),
                 c)
        function(a,
                 b = foo(
                   bar
                 ),
                 c) NULL
    Code
      print_longer_l("(a, b =\n  2, c)")
    Output
      foofybaz(a,
               b =
                 2,
               c)
      function(a,
               b =
                 2,
               c) NULL

# can reshape call wider

    Code
      print_wider("()")
    Output
      foofybaz()
      function() NULL
    Code
      print_wider("(\n  a\n)")
    Output
      foofybaz(a)
      function(a) NULL
    Code
      print_wider("(\n\n  a\n\n)")
    Output
      foofybaz(a)
      function(a) NULL
    Code
      print_wider("(\n  a, \n  b\n)")
    Output
      foofybaz(a, b)
      function(a, b) NULL
    Code
      print_wider("(\n  a, \n  b, \n  c\n)")
    Output
      foofybaz(a, b, c)
      function(a, b, c) NULL
    Code
      print_wider("(\n  a = 1,\n  b,\n  c = 3\n)")
    Output
      foofybaz(a = 1, b, c = 3)
      function(a = 1, b, c = 3) NULL
    Code
      # Leading indentation is ignored
      print_wider("  ()")
    Output
        foofybaz()
        function() NULL
    Code
      print_wider("  (\n  a\n)")
    Output
        foofybaz(a)
        function(a) NULL
    Code
      print_wider("  (\n\n  a\n\n,\n b)")
    Output
        foofybaz(a, b)
        function(a, b) NULL
    Code
      # Multiline args are indented as is
      print_wider("(\n  a,\n  b = foo(\n    bar\n  ),\n  c)")
    Output
      foofybaz(a, b = foo(
        bar
      ), c)
      function(a, b = foo(
        bar
      ), c) NULL
    Code
      print_wider("(\n  a,\n  b =\n    2,\n  c\n)")
    Output
      foofybaz(a, b =
        2, c)
      function(a, b =
        2, c) NULL

