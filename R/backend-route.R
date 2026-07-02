#' Detect scripts in a string
#'
#' Returns a character vector of script identifiers that appear in
#' \code{x} based on Unicode block ranges. Used to decide whether the
#' default Cairo backend is sufficient.
#'
#' The detection is intentionally coarse: it splits the input into
#' contiguous runs of common scripts (Latin, Han, Kana, Hangul,
#' Cyrillic, Greek, Hebrew, Arabic, Devanagari, Thai, Basic Emoji).
#'
#' @param x character vector.
#' @return character vector; one or more of:
#'   \code{"latin"}, \code{"han"}, \code{"kana"}, \code{"hangul"},
#'   \code{"cyrillic"}, \code{"greek"}, \code{"hebrew"},
#'   \code{"arabic"}, \code{"devanagari"}, \code{"thai"},
#'   \code{"emoji"}, \code{"other"}.
#' @keywords internal
detect_scripts <- function(x) {
  if (is.null(x)) return(character())
  chars <- strsplit(paste(unlist(x), collapse = ""), "")[[1]]
  out <- vapply(chars, classify_char, character(1))
  unique(out)
}

#' Internal: classify a single character by Unicode block.
#' @noRd
classify_char <- function(ch) {
  cp <- utf8_to_codepoint(ch)
  if (is.na(cp)) return("other")
  if (cp >= 0x0041 && cp <= 0x007A) return("latin")            # A-Z a-z
  if (cp >= 0x00C0 && cp <= 0x024F) return("latin")            # Latin Ext
  if (cp >= 0x0400 && cp <= 0x04FF) return("cyrillic")
  if (cp >= 0x0370 && cp <= 0x03FF) return("greek")
  if (cp >= 0x0590 && cp <= 0x05FF) return("hebrew")
  if (cp >= 0x0600 && cp <= 0x06FF) return("arabic")
  if (cp >= 0x0750 && cp <= 0x077F) return("arabic")            # Arabic Sup
  if (cp >= 0x0900 && cp <= 0x097F) return("devanagari")
  if (cp >= 0x0E00 && cp <= 0x0E7F) return("thai")
  if (cp >= 0x3040 && cp <= 0x309F) return("kana")
  if (cp >= 0x30A0 && cp <= 0x30FF) return("kana")
  if (cp >= 0x4E00 && cp <= 0x9FFF) return("han")
  if (cp >= 0x3400 && cp <= 0x4DBF) return("han")
  if (cp >= 0xAC00 && cp <= 0xD7AF) return("hangul")
  if (cp >= 0x1F300 && cp <= 0x1FAFF) return("emoji")
  if (cp >= 0x1F600 && cp <= 0x1F64F) return("emoji")
  if (cp >= 0x1F900 && cp <= 0x1F9FF) return("emoji")
  if (cp >= 0x2600 && cp <= 0x27BF) return("emoji")
  "other"
}

#' Internal: convert the first UTF-8 character to its codepoint.
#' @noRd
utf8_to_codepoint <- function(ch) {
  # utf8ToInt returns NA for invalid sequences; first element is enough.
  v <- tryCatch(utf8ToInt(ch), error = function(e) NA_integer_)
  if (length(v) == 0) NA_integer_ else v[1]
}

#' @noRd
require_suggested <- function(pkg, fn) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(sprintf(
      "`%s` requires the suggested package `%s`. Install it with:\n  install.packages(\"%s\")",
      fn, pkg, pkg), call. = FALSE)
  }
}

#' Resolve a backend for a plot based on detected scripts
#'
#' Picks one of:
#' \itemize{
#'   \item \code{"cairo"} (default, always available)
#'   \item \code{"ragg"} (HarfBuzz-capable, requires \pkg{ragg})
#'   \item \code{"svglite"} (vector + HarfBuzz via systemfonts/Pango)
#' }
#'
#' For complex scripts (Arabic, Persian-as-Arabic, Hebrew, Devanagari,
#' Thai, or emoji), preference is given to \pkg{ragg}; \pkg{svglite} is
#' preferred for vector outputs containing complex scripts.
#'
#' @param plot a ggplot object whose labels will be inspected.
#' @param use NULL or one of \code{"auto"}, \code{"cairo"}, \code{"ragg"},
#'   \code{"svglite"}.
#' @param file target output file path; used only to choose vector vs
#'   bitmap.
#'
#' @return A list with components \code{device} (an R function or named
#'   device string) and \code{name} (a string identifying the choice).
#' @export
fontalign_resolve_backend <- function(plot, use = "auto", file = NULL) {
  if (missing(plot)) plot <- NULL
  use <- match.arg(use, c("auto", "cairo", "ragg", "svglite"))

  scripts <- if (use == "auto" && !is.null(plot)) {
    detect_scripts(plot_scripts(plot))
  } else character()
  complex <- any(scripts %in% c("arabic", "hebrew", "devanagari", "thai",
                                "emoji"))

  is_pdf <- !is.null(file) && tools::file_ext(file) == "pdf"
  is_svg <- !is.null(file) && tools::file_ext(file) %in% c("svg", "svgz")

  if (use == "auto") {
    if (is_pdf || is_svg) {
      # Vector: prefer svglite when complex, else cairo_pdf.
      if (complex && requireNamespace("svglite", quietly = TRUE)) {
        return(list(device = svglite::svglite, name = "svglite"))
      }
      return(list(device = grDevices::cairo_pdf, name = "cairo_pdf"))
    }
    # Bitmap
    if (complex && requireNamespace("ragg", quietly = TRUE)) {
      return(list(device = ragg::agg_png, name = "ragg"))
    }
    return(list(device = grDevices::png, name = "cairo_png"))
  }

  switch(use,
    cairo   = list(
      device = if (is_pdf) grDevices::cairo_pdf else grDevices::png,
      name   = if (is_pdf) "cairo_pdf" else "cairo_png"),
    ragg    = list(device = ragg::agg_png, name = "ragg"),
    svglite = list(device = svglite::svglite, name = "svglite")
  )
}

#' Extract textual labels from a ggplot
#'
#' Walks the plot's layers, scales, and theme labels and returns the
#' unique non-empty strings. Used to detect which scripts appear in a
#' plot.
#'
#' @param plot a ggplot or NULL.
#' @return character vector.
#' @keywords internal
plot_scripts <- function(plot) {
  if (is.null(plot)) return(character())
  out <- c()
  tryCatch({
    if (!is.null(plot$labels)) {
      out <- c(out, unlist(plot$labels, use.names = FALSE))
    }
    if (!is.null(plot$theme)) {
      th <- plot$theme
      for (element in c("plot.title", "plot.subtitle", "plot.caption",
                        "axis.title", "axis.text", "legend.title",
                        "legend.text", "strip.text")) {
        if (!is.null(th[[element]])) {
          elt <- th[[element]]
          if (inherits(elt, "element_text")) {
            out <- c(out, elt$family)  # family might be NULL
          }
        }
      }
    }
  }, error = function(e) NULL)
  out <- out[!is.na(out) & nzchar(out)]
  unique(out)
}

#' List all fontconfig-registered font families
#'
#' Runs \code{fc-list : family | sort -u} and returns the unique entries.
#' Returns an empty character vector if fontconfig is not available.
#'
#' @return character vector of family names.
#' @export
fontalign_list_fonts <- function() {
  if (!nzchar(Sys.which("fc-list"))) {
    cli::cli_alert_warning("fc-list not on PATH; returning empty vector")
    return(character())
  }
  out <- tryCatch(system("fc-list family", intern = TRUE),
                  error = function(e) character())
  if (length(out) == 0) return(character())
  families <- sub(":.*$", "", out)
  unique(families)
}
