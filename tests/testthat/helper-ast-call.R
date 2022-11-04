print_longer <- function(text, ...) {
  call <- sub_call_shape(text)
  def <- sub_def_shape(text)

  indent <- regexpr("[^[:space:]]", text) - 1
  indent <- strrep(" ", indent)

  cat_line(
    paste0(indent, as_longer(call, ...)),
    "\n",
    paste0(indent, as_longer(def, ...))
  )
}
print_longer_l <- function(text, ...) {
  print_longer(text, L = TRUE)
}
as_longer <- function(text, ...) {
  info <- parse_info(text = text)
  node_call_longer(
    parse_xml_one(info),
    info = info,
    ...
  )
}

print_wider <- function(text, ...) {
  call <- sub_call_shape(text)
  def <- sub_def_shape(text)

  indent <- regexpr("[^[:space:]]", text) - 1
  indent <- strrep(" ", indent)

  cat_line(
    paste0(indent, as_wider(call, ...)),
    "\n",
    paste0(indent, as_wider(def, ...))
  )
}
as_wider <- function(text, ...) {
  info <- parse_info(text = text)
  node_call_wider(
    parse_xml_one(info),
    info = info,
    ...
  )
}

expect_call_shape <- function(text, type) {
  call <- sub_call_shape(text)
  expect_equal(
    node_call_shape(p(call)),
    type
  )

  def <- sub_def_shape(text)
  expect_equal(
    node_call_shape(p(def)),
    type
  )
}

sub_call_shape <- function(text) {
  sub("\\(", "foofybaz\\(", text)
}
sub_def_shape <- function(text) {
  def <- sub("\\(", "function\\(", text)
  sub("\\)[[:space:]]*$", "\\) NULL", def)
}
