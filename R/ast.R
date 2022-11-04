parse_xml <- function(info) {
  check_info(info)

  data <- utils::getParseData(parse(info$file, text = info$text))
  xml_text <- xmlparsedata::xml_parse_data(data)
  read_xml(xml_text)
}

parse_info <- function(file = "", text = NULL) {
  list(
    file = file,
    text = text
  )
}

is_info <- function(x) {
  is.list(x) && all(c("file", "text") %in% names(x))
}
check_info <- function(info,
                       arg = caller_arg(info),
                       call = caller_env()) {
  if (!is_info(info)) {
    abort(
      sprintf("`%s` must be a list created by `parse_info()`.", arg),
      call = call,
      arg = arg
    )
  }
}

parse_xml_one <- function(info) {
  out <- parse_xml(info)
  out <- xml_children(out)

  if (length(out) != 1) {
    abort("XML document must be length 1.")
  }

  out[[1]]
}

xml_attr_int <- function(data, attr) {
  as.integer(xml_attr(data, attr))
}

xml_line1 <- function(data) {
  xml_attr_int(data, "line1")
}
xml_line2 <- function(data) {
  xml_attr_int(data, "line2")
}
xml_col1 <- function(data) {
  xml_attr_int(data, "col1")
}
xml_col2 <- function(data) {
  xml_attr_int(data, "col2")
}
xml_start <- function(data) {
  xml_attr_int(data, "start")
}
xml_end <- function(data) {
  xml_attr_int(data, "end")
}

as_position <- function(line, col, ..., data) {
  check_dots_empty()

  max <- max_col(data) + 1L
  line * max + col
}

# Useful to recreate a position in the same dimension than
# xml_parse_data()'s `start` and `end` attributes
max_col <- function(data) {
  nodes <- xml_find_all(data, "//*")

  max(
    xml_col1(nodes),
    xml_col2(nodes),
    na.rm = TRUE
  )
}

node_positions <- function(data) {
  data.frame(
    line1 = xml_line1(data),
    col1 = xml_col1(data),
    line2 = xml_line2(data),
    col2 = xml_col2(data),
    start = xml_start(data),
    end = xml_end(data)
  )
}

merge_positions <- function(pos) {
  line1 <- min(pos$line1)
  line2 <- max(pos$line2)

  min_lines <- pos$line1 == line1
  max_lines <- pos$line2 == line2

  col1 <- min(pos$col1[min_lines])
  start <- min(pos$start[min_lines])

  col2 <- max(pos$col2[max_lines])
  end <- max(pos$end[max_lines])

  data.frame(
    line1 = line1,
    col1 = col1,
    line2 = line2,
    col2 = col2,
    start = start,
    end = end
  )
}

node_text <- function(data, ..., info) {
  check_dots_empty()

  pos <- node_positions(data)
  pos <- merge_positions(pos)

  if (nrow(pos) != 1) {
    abort("Can't find positions in `data`.")
  }

  lines <- lines(info)
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

node_list_text <- function(data, ..., info) {
  lapply(data, node_text, info = info)
}

locate_node <- function(set, line, col, ..., data) {
  check_dots_empty()

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

check_node <- function(node,
                       arg = caller_arg(node),
                       call = caller_env()) {
  if (!inherits(node, "xml_node")) {
    abort(
      sprintf("`%s` must be an XML node.", arg),
      call = call,
      arg = arg
    )
  }
}

check_node_set <- function(set,
                           arg = caller_arg(node),
                           call = caller_env()) {
  if (!inherits(set, "xml_nodeset")) {
    abort(
      sprintf("`%s` must be an XML nodeset.", arg),
      call = call,
      arg = arg
    )
  }
}

check_node_or_nodeset <- function(node,
                                  arg = caller_arg(node),
                                  call = caller_env()) {
  if (!inherits_any(node, c("xml_node", "xml_nodeset"))) {
    abort(
      sprintf("`%s` must be an XML node or nodeset.", arg),
      call = call,
      arg = arg
    )
  }
}

node_indentation <- function(node, ..., info) {
  check_dots_empty()
  check_node(node)

  line <- xml_line1(node)
  line_text <- lines(info)[[line]]

  # Replace tabs by spaces
  # FIXME: Hardcoded indent level
  line_text <- gsub("\t", strrep(" ", 2), line_text)

  indent <- regexpr("[^[:space:]]", line_text) - 1L
  max(indent, 0L)
}
