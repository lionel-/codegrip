find_reshape_node <- function(node, line, col) {
  pos <- df_pos(line, col)

  while (!is.na(node)) {
    set <- xml_children(node)

    can_reshape <- can_reshape(set)
    if (any(can_reshape)) {
      first_loc <- which(can_reshape)[[1]]
      first <- set[[first_loc]]
      first_pos <- as_df_pos(first)

      if (vctrs::vec_compare(pos, first_pos) >= 0) {
        return(first)
      }
    }

    node <- node_parent(node)
  }

  node
}

can_reshape <- function(data) {
  is_delim_open(data)
}

#' Prepare Reshape Information
#'
#' Prior to performing an editor-specific operation, prepare minimal
#' information needed to perform the action.
#'
#' @param line,col `integer` The location of the cursor as the focus of the
#'   reshape action.
#' @param ... Arguments unused
#' @param info `list` of named elements `file` (`string`), `lines`
#'   (`character()`) and `xml` ([`xml2::xml_new_document()`]), as produced
#'   using `parse_info()`.
#' @param to `string` An optional hint for the reshape action. Expecting one of
#'   `"wide"` (single line call), `"L"` (indented to the call left parenthesis)
#'   or `"long"` (arguments indented by one indentation).
#'
#' @export
reshape_info <- function(line, col, ..., info, to = NULL) {
  info <- parse_info_complete(info)
  call <- find_function_call(line, col, data = info$xml)
  call_lines <- node_text_lines(call, info = info)

  if (is_null(call)) {
    return()
  }

  pos <- node_positions(call)
  n_ns_chars <- count_nonspace_chars_to(
    call_lines,
    line = 1L + line - pos$line1,
    col = if (line == 1) 1L + col - pos$col1 else col
  )

  if (is_null(to)) {
    if (node_call_type(call) == "prefix") {
      to <- switch(
        node_call_shape(call),
        wide = if (length(node_call_arguments(call)) == 1) {
          "long"
        } else {
          "L"
        },
        L = "long",
        long = "wide",
        "none"
      )
    } else {
      to <- switch(
        node_call_shape(call),
        wide = "long",
        L = ,
        long = "wide",
        "none"
      )
    }
  }

  reshaped <- switch(
    to,
    long = node_call_longer(call, info = info),
    L = node_call_longer(call, info = info, L = TRUE),
    wide = node_call_wider(call, info = info),
    none = node_text(call),
    abort("Unexpected value for `to`.", .internal = TRUE)
  )

  n_char_re <- sprintf("^((\\s*\\S){%s}).*", n_ns_chars)
  n_char <- nchar(gsub(n_char_re, "\\1", reshaped))

  list(
    reshaped = reshaped,
    start = c(line = pos$line1, col = pos$col1),
    end = c(line = pos$line2, col = pos$col2 + 1L),
    cursor = c(char = n_char)
  )
}

reshape <- function(line, col, ..., info, to = NULL) {
  out <- reshape_info(line, col, info = info, to = to)
  lines <- lines(info)

  start_line <- out$start[["line"]]
  start_col <- out$start[["col"]]
  end_line <- out$end[["line"]]
  end_col <- out$end[["col"]]

  if (start_line == end_line) {
    lines[[start_line]] <- str_replace(
      lines[[start_line]],
      start_col,
      end_col - 1L,
      value = out$reshaped
    )
  } else {
    tail <- str_replace(lines[[end_line]], 1, end_col - 1L)
    head <- str_replace(lines[[start_line]], start_col, value = out$reshaped)
    lines[[start_line]] <- paste0(head, tail)
    lines <- lines[-end_line]
  }

  deleted <- seq2(start_line + 1L, end_line - 1L)
  if (length(deleted)) {
    lines <- lines[-deleted]
  }

  paste0(lines, collapse = "\n")
}
