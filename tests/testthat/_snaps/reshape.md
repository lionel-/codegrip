# reshape() cycles function calls and definitions

    Code
      code <- "foofybaz()"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      foofybaz()
      
      i: 2
      foofybaz()
      
    Code
      code <- "foofybaz(a)"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      foofybaz(
        a
      )
      
      i: 2
      foofybaz(a)
      
      i: 3
      foofybaz(
        a
      )
      
    Code
      code <- "foofybaz(a, b = 1, c)"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      foofybaz(
        a,
        b = 1,
        c
      )
      
      i: 2
      foofybaz(a, b = 1, c)
      
      i: 3
      foofybaz(
        a,
        b = 1,
        c
      )
      
    Code
      code <- "function() NULL"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      function() NULL
      
      i: 2
      function() NULL
      
    Code
      code <- "function(a) NULL"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      function(
          a
      ) NULL
      
      i: 2
      function(a) NULL
      
      i: 3
      function(
          a
      ) NULL
      
    Code
      code <- "function(a, b = 1, c) NULL"
      snap_reshape_cycle(4, code)
    Output
      i: 1
      function(a,
               b = 1,
               c) NULL
      
      i: 2
      function(
          a,
          b = 1,
          c
      ) NULL
      
      i: 3
      function(a, b = 1, c) NULL
      
      i: 4
      function(a,
               b = 1,
               c) NULL
      

# reshape() cycles other call-like constructs

    Code
      code <- "if (a) NULL"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      if (
          a
      ) NULL
      
      i: 2
      if (a) NULL
      
    Code
      code <- "if (a) b else c"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      if (
          a
      ) b else c
      
      i: 2
      if (a) b else c
      
    Code
      code <- "while (a) NULL"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      while (
          a
      ) NULL
      
      i: 2
      while (a) NULL
      
    Code
      code <- "for (i in x) NULL"
      snap_reshape_cycle(1, code)
    Output
      i: 1
      for (i in x) NULL
      

# can reshape braced expressions

    Code
      code <- "expect_snapshot({\n  a\n  b\n})"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      expect_snapshot(
        {
          a
          b
        }
      )
      
      i: 2
      expect_snapshot({
        a
        b
      })
      
    Code
      code <- "{\n  expect_snapshot({\n    a\n    b\n  })\n}"
      snap_reshape_cycle(2, code, line = 2, col = 3)
    Output
      i: 1
      expect_snapshot(
          {
            a
            b
          }
        )
      
      i: 2
      expect_snapshot({
          a
          b
        })
      
    Code
      code <- "test_that('desc', {\n  a\n  b\n})"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      test_that(
        'desc',
        {
          a
          b
        }
      )
      
      i: 2
      test_that('desc', {
        a
        b
      })
      
      i: 3
      test_that(
        'desc',
        {
          a
          b
        }
      )
      
    Code
      code <- "test_that({\n  a\n  b\n}, desc = 'desc')"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      test_that(
        {
          a
          b
        },
        desc = 'desc'
      )
      
      i: 2
      test_that({
        a
        b
      }, desc = 'desc')
      
      i: 3
      test_that(
        {
          a
          b
        },
        desc = 'desc'
      )
      

# can reshape with multiple braced expressions

    Code
      code <- "foo({\n  1\n}, {\n  2\n})"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      foo(
        {
          1
        },
        {
          2
        }
      )
      
      i: 2
      foo({
        1
      }, {
        2
      })
      

# String arguments are correctly indented

    Code
      code <- "foo({\n  'baz'\n  'foofy'\n})"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      foo(
        {
          'baz'
          'foofy'
        }
      )
      
      i: 2
      foo({
        'baz'
        'foofy'
      })
      
      i: 3
      foo(
        {
          'baz'
          'foofy'
        }
      )
      
    Code
      code <- "foo('desc', 'bar', {\n  'baz'\n  'foofy'\n})"
      snap_reshape_cycle(3, code)
    Output
      i: 1
      foo(
        'desc',
        'bar',
        {
          'baz'
          'foofy'
        }
      )
      
      i: 2
      foo('desc', 'bar', {
        'baz'
        'foofy'
      })
      
      i: 3
      foo(
        'desc',
        'bar',
        {
          'baz'
          'foofy'
        }
      )
      

# lines within strings are not indented

    Code
      code <- "foo('{\n  1\n  2\n}')"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      foo(
        '{
        1
        2
      }'
      )
      
      i: 2
      foo('{
        1
        2
      }')
      

# can reshape calls with comments

    Code
      code <- "foo(\n  x,\n  y # comment\n)"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      foo(
        x,
        y # comment
      )
      
      i: 2
      foo(
        x,
        y # comment
      )
      
    Code
      code <- "foo(x, y # comment\n)"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      foo(
        x,
        y # comment
      )
      
      i: 2
      foo(
        x,
        y # comment
      )
      

# can reshape calls with empty arguments

    Code
      code <- "foo(x, , , y, z, )"
      snap_reshape_cycle(2, code)
    Output
      i: 1
      foo(
        x,
        ,
        ,
        y,
        z,
        
      )
      
      i: 2
      foo(x, , , y, z, )
      

