#' fontalign: Backend-Agnostic Font Size Alignment for ggplot2 Outputs
#'
#' Wraps [ggplot2::ggsave()] so that rendered text size matches the target
#' `dpi` regardless of which graphics device is used, without modifying the
#' plot object, theme, or graphics state. Routes plots containing complex
#' scripts (Arabic, Persian, Devanagari, Thai) to a HarfBuzz-capable
#' backend such as \pkg{ragg} or \pkg{svglite}.
#'
#' @section Why fontalign:
#' On Linux servers, the same `ggsave()` invocation can produce different
#' text sizes depending on the device and system font configuration. This
#' package provides a single entry point, [fontalign_save()], that picks an
#' appropriate backend and aligns text size to the target DPI exactly.
#'
#' @seealso [fontalign_save()], [fontalign_check_system()],
#'   [fontalign_resolve_backend()].
#'
#' @keywords package
"_PACKAGE"
