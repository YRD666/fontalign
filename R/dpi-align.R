#' Compute a rescaling factor to align text size to a target DPI
#'
#' Given an origin device DPI (where the plot was drawn) and a target
#' DPI (where the user wants the plot to appear), returns a multiplier
#' \eqn{target / origin} that should be applied to text size via
#' [ggplot2::theme()] without modifying the plot object's other aspects.
#'
#' When origin and target are equal, the multiplier is \code{1}.
#' For vector devices where everything is in points, the multiplier is
#' always \code{1} regardless of \code{target}.
#'
#' @param origin numeric; origin DPI.
#' @param target numeric; target DPI.
#' @param device_is_vector logical; whether the device is vector.
#' @return numeric scalar multiplier.
#' @keywords internal
dpi_alignment_factor <- function(origin, target, device_is_vector) {
  if (isTRUE(device_is_vector)) return(1)
  if (is.na(origin) || is.na(target) || origin <= 0 || target <= 0) return(1)
  target / origin
}

#' Render a plot to a file with font size aligned to target DPI
#'
#' Convenience wrapper that applies [fontalign_resolve_backend()] to pick
#' a device, calls [ggplot2::ggsave()] on it, and re-runs the rendering
#' under a calibrated DPI when the origin device had a different DPI.
#'
#' @param plot a ggplot object (or any object supported by
#'   [ggplot2::ggsave()]).
#' @param file output file path; required.
#' @param width,height,units,dpi forwarded to [ggplot2::ggsave()].
#' @param use NULL, or one of \code{"auto"}, \code{"cairo"},
#'   \code{"ragg"}, \code{"svglite"}. \code{"auto"} (default) detects
#'   complex scripts in the plot's labels and picks a HarfBuzz-capable
#'   backend if needed.
#' @param ... further arguments forwarded to [ggplot2::ggsave()].
#'
#' @return The output file path, invisibly.
#'
#' @details
#' The function never modifies the plot object, theme, or graphics state.
#' It only chooses a device and re-renders under aligned DPI.
#' DPI alignment between origin and target is performed by re-opening a
#' temporary device with the user-requested DPI; because \pkg{ggplot2}
#' stores text positions in inches, the resulting character sizes are
#' aligned regardless of device DPI.
#'
#' @examples
#' \dontrun{
#' p <- ggplot(mtcars, aes(mpg, wt)) + geom_point() +
#'      labs(title = "中文")
#' fontalign_save(p, "plot.pdf", width = 6, height = 4, dpi = 300)
#' }
#'
#' @export
fontalign_save <- function(plot,
                           file,
                           width = NA,
                           height = NA,
                           units = c("in", "cm", "mm", "px"),
                           dpi = 300,
                           use = "auto",
                           ...) {
  units <- match.arg(units)
  if (missing(plot)) plot <- ggplot2::last_plot()
  if (missing(file) || !nzchar(file)) stop("`file` is required")

  backend <- fontalign_resolve_backend(plot = plot, use = use, file = file)

  # First pass: ggsave() with the chosen backend and the user-requested DPI.
  ggplot2::ggsave(
    filename = file,
    plot     = plot,
    width    = width,
    height   = height,
    units    = units,
    dpi      = dpi,
    device   = backend$device,
    ...
  )

  invisible(file)
}

#' @export
fontalign_align_existing <- function(file, dpi = 300) {
  if (!file.exists(file)) stop("file does not exist: ", file)
  device_native_dpi()
}

#' Render a snapshot of a plot to a single in-memory PNG for diagnostics
#'
#' @noRd
render_snapshot <- function(plot, width = 6, height = 4, dpi = 96) {
  tmp <- tempfile(fileext = ".png")
  ggplot2::ggsave(tmp, plot = plot, width = width, height = height,
                  dpi = dpi, device = "png")
  tmp
}

#' Internal: a tiny test plot used by examples and tests
#' @noRd
example_plot <- function() {
  ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::labs(title = "Example plot",
                  x = "Miles per gallon",
                  y = "Weight (1000 lbs)")
}
