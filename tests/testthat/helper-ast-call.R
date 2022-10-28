print_longer <- function(text) {
  info <- parse_info(text = text)

  text <- node_call_longer(
    parse_xml_one(info),
    info = info
  )

  cat_line(text)
  invisible(NULL)
}
