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

