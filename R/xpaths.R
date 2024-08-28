xml_node_at <- function(line, col) {
  # nolint start
  xpath <- paste0(
    # any node that is
    "//*[",
      # followed
      "following::*[",
        # immediately by a node that is
        "position() = 1",
        " and ",
        # at or beyond 'line', and
        "number(@line1) >= %s",
        " and ",
        # at or beyond 'col'
        "number(@col1) > %s", 
      "]",
    "]"
  )
  # nolint end
  sprintf(xpath, line, col)
}

