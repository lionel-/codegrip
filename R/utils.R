check_rstudio <- function(call = caller_env()) {
  if (!is_rstudio()) {
    abort("Can't use this feature outside RStudio.", call = call)
  }
}

is_rstudio <- function() {
  identical(.Platform$GUI, "RStudio")
}

cat_line <- function(...) {
  cat(paste0(..., "\n", collapse = ""))
}
