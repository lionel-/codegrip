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
      

