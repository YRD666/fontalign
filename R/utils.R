#' Internal: a compact `coalesce` for NULL or empty values
#'
#' Used to make `get0()` and `Sys.which()` results friendly to printing.
#' @param a,b values; `a` is returned if not NULL/empty.
#' @noRd
coalesce <- function(a, b) {
  if (is.null(a) || (length(a) == 1 && is.na(a)) || (length(a) == 1 && a == "")) {
    b
  } else {
    a
  }
}

#' Internal: yes/no check, tolerating missing executables
#'
#' Returns TRUE if the executable is on PATH.
#' @noRd
has_exec <- function(cmd) {
  nzchar(Sys.which(cmd))
}

#' Internal: capture process version, or NA_character_
#'
#' @param cmd command to run via \code{system(..., intern = TRUE)}.
#' @noRd
sys_version <- function(cmd) {
  out <- tryCatch(suppressWarnings(system(cmd, intern = TRUE)),
                  error = function(e) character())
  if (length(out) == 0) NA_character_ else trimws(out[1])
}
