parse_xml <- function(file = "", text = NULL) {
  data <- utils::getParseData(parse(file, text = text))
  xml_text <- xmlparsedata::xml_parse_data(data)
  xml2::read_xml(xml_text)
}

xml_attr_int <- function(data, attr) {
  as.integer(xml2::xml_attr(data, attr))
}

as_position <- function(line, col, ..., data) {
  max <- max_col(data) + 1L
  line * max + col
}

# Useful to recreate a position in the same dimension than
# xml_parse_data()'s `start` and `end` attributes
max_col <- function(data) {
  nodes <- xml2::xml_find_all(data, "//*")

  col1 <- xml_attr_int(nodes, "col1")
  col2 <- xml_attr_int(nodes, "col2")

  max(col1, col2, na.rm = TRUE)
}

node_positions <- function(data) {
  line1 <- xml_attr_int(data, "line1")
  line2 <- xml_attr_int(data, "line2")

  col1 <- xml_attr_int(data, "col1")
  col2 <- xml_attr_int(data, "col2")

  start <- xml_attr_int(data, "start")
  end <- xml_attr_int(data, "end")

  data.frame(
    line1 = line1,
    col1 = col1,
    line2 = line2,
    col2 = col2,
    start = start,
    end = end
  )
}

node_text <- function(data, file = "", text = NULL) {
  pos <- node_positions(data)

  if (nrow(pos) != 1) {
    abort("Can't find positions in `data`.")
  }

  if (is_null(text)) {
    lines <- readLines(file)
  } else {
    lines <- strsplit(text, "\n")[[1]]
  }

  line_range <- pos$line1:pos$line2
  lines <- lines[line_range]

  if (!length(lines)) {
    abort("Can't find text in `data`.")
  }

  n <- length(lines)
  lines[[n]] <- substr(lines[[n]], 1, pos$col2)
  lines[[1]] <- substr(lines[[1]], pos$col1, nchar(lines[[1]]))

  paste(lines, collapse = "\n")
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
  xml2::xml_find_all(data, ".//*[following-sibling::OP-LEFT-PAREN]/..")
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
