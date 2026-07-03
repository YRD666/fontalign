#' Detect and inspect the active graphics device
#'
#' Low-level helpers used internally by [fontalign_save()] to decide
#' whether a device is vector or bitmap and what its native DPI is.
#'
#' @details
#' * [device_current()] returns a human-readable name of the current
#'   device, or \code{NULL} if no device is open.
#' * [device_is_vector()] returns \code{TRUE} for vector devices
#'   (\code{cairo_pdf}, \code{pdf}, \code{svg}, \code{svglite}, etc.) and
#'   \code{FALSE} for bitmap devices (\code{png}, \code{cairo_png},
#'   \code{tiff}, \code{agg_png}, \code{bmp}).
#' * [device_native_dpi()] returns the device's recording DPI when
#'   available. For vector devices this is a chosen nominal value
#'   (\code{72}); for bitmap devices it is the value of \code{res} passed
#'   at creation time, recovered via \code{grDevices:::dev.cur()$res}
#'   when accessible.
#' @name device-info
#' @return For [device_current()] a single string; for [device_is_vector()]
#'   and [device_native_dpi()] scalars.
#' @keywords internal
NULL

#' @rdname device-info
#' @keywords internal
device_current <- function() {
  devs <- grDevices::dev.list()
  if (is.null(devs) || length(devs) == 0) return(NULL)
  names(devs)[length(devs)]
}

#' @rdname device-info
#' @keywords internal
device_is_vector <- function() {
  d <- device_current()
  if (is.null(d)) NA
  d %in% c("pdf", "cairo_pdf", "svg", "svglite", "X11cairo", "CairoPDF")
}

#' @rdname device-info
#' @keywords internal
device_native_dpi <- function() {
  # Vector devices use points (1 pt = 1/72 inch).
  if (isTRUE(device_is_vector())) return(72)

  # Base R does not expose bitmap device DPI through a stable public API.
  NA_real_
}

#' Heuristic DPI resolution for a target device name and dpi argument
#'
#' When the user has not yet opened a device, decide what DPI a given
#' device_name will use at construction time.
#' @param device_name e.g. \code{"cairo_pdf"}, \code{"png"}, \code{"ragg::agg_png"}.
#' @param dpi user-requested DPI value.
#' @return numeric scalar DPI value.
#' @keywords internal
resolve_target_dpi <- function(device_name, dpi) {
  if (is.null(dpi) || is.na(dpi) || dpi <= 0) return(72)
  # Vector devices always use 72 pt = 1 inch.
  if (device_name %in% c("pdf", "cairo_pdf", "svg", "svglite")) 72
  else as.numeric(dpi)
}
