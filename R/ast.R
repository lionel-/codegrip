parse_xml <- function(file = "", text = NULL) {
  data <- utils::getParseData(parse(file, text = text))
  xml_text <- xmlparsedata::xml_parse_data(data)
  xml2::read_xml(xml_text)
}

as_position <- function(line, col, ..., data) {
  max <- max_col(data) + 1L
  line * max + col
}

# Useful to recreate a position in the same dimension than
# xml_parse_data()'s `start` and `end` attributes
max_col <- function(data) {
  nodes <- xml2::xml_find_all(data, "//*")

  col1 <- as.integer(xml2::xml_attr(nodes, "col1"))
  col2 <- as.integer(xml2::xml_attr(nodes, "col2"))

  max(col1, col2, na.rm = TRUE)
}

node_positions <- function(data) {
  line1 <- as.integer(xml2::xml_attr(data, "line1"))
  line2 <- as.integer(xml2::xml_attr(data, "line2"))

  col1 <- as.integer(xml2::xml_attr(data, "col1"))
  col2 <- as.integer(xml2::xml_attr(data, "col2"))

  start <- as.integer(xml2::xml_attr(data, "start"))
  end <- as.integer(xml2::xml_attr(data, "end"))

  data.frame(
    line1 = line1,
    col1 = col1,
    line2 = line2,
    col2 = col2,
    start = start,
    end = end
  )
}

locate_node <- function(set, line, col, ..., data) {
  pos <- node_positions(set)

  start <- pos$start
  end <- pos$end
  cursor <- as_position(line, col, data = data)

  in_range <- cursor >= start & cursor <= end
  if (!any(in_range)) {
    return(0L)
  }

  width <- end - start
  innermost <- which(width == min(width[in_range]) & in_range)

  # There shouldn't be multiple matches but just in case
  innermost[[1]]
}

# This also selects function definitions
find_function_calls <- function(data) {
  xml2::xml_find_all(data, "//*/*[following-sibling::OP-LEFT-PAREN]/..")
}

find_function_call <- function(line, col, ..., data) {
  calls <- find_function_calls(data)
  loc <- locate_node(calls, line, col, data = data)

  if (loc) {
    calls[[loc]]
  } else {
    NULL
  }
}
