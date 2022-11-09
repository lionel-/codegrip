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
    Code
      print_longer("  (a, b = foo(\n    bar  \n  ), c)")
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
      # Wrong indentation is preserved
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
    Code
      print_longer_l("  (a, b = foo(\n    bar  \n  ), c)")
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
      # Wrong indentation is preserved
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

