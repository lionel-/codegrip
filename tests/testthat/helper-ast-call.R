print_longer <- function(text) {
  cat_line(as_longer(text))
}
as_longer <- function(text) {
  info <- parse_info(text = text)
  node_call_longer(
    parse_xml_one(info),
    info = info
  )
}

print_wider <- function(text) {
  cat_line(as_wider(text))
}
as_wider <- function(text) {
  info <- parse_info(text = text)
  node_call_wider(
    parse_xml_one(info),
    info = info
  )
}

expect_call_shape <- function(text, type) {
  call <- sub("\\(", "funciton\\(", text)
  expect_equal(
    node_call_shape(p(call)),
    type
  )

  def <- sub("\\(", "function\\(", text)
  def <- sub("\\)[[:space:]]*$", "\\) NULL", def)
  expect_equal(
    node_call_shape(p(def)),
    type
  )
}
