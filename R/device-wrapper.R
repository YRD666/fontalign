#' Choose the bitmap backend for fontalign devices
#'
#' @param use one of \code{"auto"}, \code{"cairo"}, or \code{"ragg"}.
#' @param device one of \code{"png"}, \code{"jpeg"}, or \code{"tiff"}.
#' @return Backend name such as \code{"ragg"}, \code{"cairo_png"}, or
#'   \code{"png"}.
#' @export
fontalign_bitmap_backend <- function(use = "auto", device = c("png", "jpeg", "tiff")) {
  use <- match.arg(use, c("auto", "cairo", "ragg"))
  device <- match.arg(device)
  if (use == "ragg") {
    require_suggested("ragg", "fontalign bitmap device use = 'ragg'")
    return("ragg")
  }
  if (use == "auto" && requireNamespace("ragg", quietly = TRUE)) {
    return("ragg")
  }
  if (capabilities("cairo")) paste0("cairo_", device) else device
}

#' Choose the bitmap backend for fontalign PNG devices
#'
#' @param use one of \code{"auto"}, \code{"cairo"}, or \code{"ragg"}.
#' @return Backend name: \code{"ragg"}, \code{"cairo_png"}, or \code{"png"}.
#' @export
fontalign_png_backend <- function(use = "auto") {
  fontalign_bitmap_backend(use = use, device = "png")
}

#' Open a PNG device with fontalign's preferred text backend
#'
#' Drop-in replacement for [grDevices::png()] in code that draws with base
#' graphics, grid, lattice, or packages that draw directly to the active device.
#' On Linux servers, \pkg{ragg} is preferred when installed because it uses
#' systemfonts/textshaping and handles multilingual text more consistently than
#' the default bitmap device. If \pkg{ragg} is unavailable, this falls back to
#' Cairo PNG when available, then to the default PNG device.
#'
#' @param filename output PNG path.
#' @param width,height device dimensions.
#' @param units one of \code{"px"}, \code{"in"}, \code{"cm"}, \code{"mm"}.
#' @param pointsize base text size in points.
#' @param bg background color.
#' @param res output resolution in DPI.
#' @param use one of \code{"auto"}, \code{"cairo"}, or \code{"ragg"}.
#' @param ... additional arguments forwarded to the device function.
#' @return Invisibly, the backend name.
#' @export
fontalign_png <- function(filename = "Rplot%03d.png",
                          width = 480,
                          height = 480,
                          units = c("px", "in", "cm", "mm"),
                          pointsize = 12,
                          bg = "white",
                          res = 300,
                          use = "auto",
                          ...) {
  fontalign_bitmap_device(
    device = "png",
    filename = filename,
    width = width,
    height = height,
    units = units,
    pointsize = pointsize,
    bg = bg,
    res = res,
    use = use,
    ...
  )
}

#' Open a JPEG device with fontalign's preferred text backend
#'
#' Drop-in replacement for [grDevices::jpeg()] in code that draws directly to
#' the active graphics device.
#'
#' @inheritParams fontalign_png
#' @param filename output JPEG path.
#' @param quality JPEG quality percentage.
#' @export
fontalign_jpeg <- function(filename = "Rplot%03d.jpeg",
                           width = 480,
                           height = 480,
                           units = c("px", "in", "cm", "mm"),
                           pointsize = 12,
                           quality = 75,
                           bg = "white",
                           res = 300,
                           use = "auto",
                           ...) {
  fontalign_bitmap_device(
    device = "jpeg",
    filename = filename,
    width = width,
    height = height,
    units = units,
    pointsize = pointsize,
    bg = bg,
    res = res,
    use = use,
    quality = quality,
    ...
  )
}

#' Open a TIFF device with fontalign's preferred text backend
#'
#' Drop-in replacement for [grDevices::tiff()] in code that draws directly to the
#' active graphics device.
#'
#' @inheritParams fontalign_png
#' @param filename output TIFF path.
#' @param compression TIFF compression method.
#' @export
fontalign_tiff <- function(filename = "Rplot%03d.tiff",
                           width = 480,
                           height = 480,
                           units = c("px", "in", "cm", "mm"),
                           pointsize = 12,
                           compression = "none",
                           bg = "white",
                           res = 300,
                           use = "auto",
                           ...) {
  fontalign_bitmap_device(
    device = "tiff",
    filename = filename,
    width = width,
    height = height,
    units = units,
    pointsize = pointsize,
    bg = bg,
    res = res,
    use = use,
    compression = compression,
    ...
  )
}

#' Draw an expression inside a fontalign-managed graphics device
#'
#' Convenience wrapper for replacing \code{png(); ...; dev.off()} blocks. The
#' device is always closed, even when the drawing expression errors.
#'
#' @param filename output path.
#' @param expr drawing expression to evaluate.
#' @param device one of \code{"png"}, \code{"jpeg"}, or \code{"tiff"}.
#' @param width,height,units,pointsize,bg,res,use forwarded to the selected
#'   fontalign bitmap device.
#' @param ... additional device arguments.
#' @return The value of \code{expr}.
#' @export
with_fontalign_device <- function(filename,
                                  expr,
                                  device = c("png", "jpeg", "tiff"),
                                  width = 480,
                                  height = 480,
                                  units = c("px", "in", "cm", "mm"),
                                  pointsize = 12,
                                  bg = "white",
                                  res = 300,
                                  use = "auto",
                                  ...) {
  device <- match.arg(device)
  units <- match.arg(units)
  fontalign_bitmap_device(
    device = device,
    filename = filename,
    width = width,
    height = height,
    units = units,
    pointsize = pointsize,
    bg = bg,
    res = res,
    use = use,
    ...
  )
  on.exit(grDevices::dev.off(), add = TRUE)
  force(expr)
}

fontalign_bitmap_device <- function(device,
                                    filename,
                                    width,
                                    height,
                                    units,
                                    pointsize,
                                    bg,
                                    res,
                                    use,
                                    ...) {
  device <- match.arg(device, c("png", "jpeg", "tiff"))
  units <- match.arg(units, c("px", "in", "cm", "mm"))
  backend <- fontalign_bitmap_backend(use = use, device = device)
  extra_args <- list(...)
  if (backend == "ragg") {
    ragg_fun <- switch(
      device,
      png = ragg::agg_png,
      jpeg = ragg::agg_jpeg,
      tiff = ragg::agg_tiff
    )
    args <- c(
      list(
        filename = filename,
        width = width,
        height = height,
        units = units,
        pointsize = pointsize,
        background = bg,
        res = res
      ),
      extra_args
    )
    do.call(ragg_fun, args)
  } else {
    device_fun <- switch(
      device,
      png = grDevices::png,
      jpeg = grDevices::jpeg,
      tiff = grDevices::tiff
    )
    args <- c(
      list(
        filename = filename,
        width = width,
        height = height,
        units = units,
        pointsize = pointsize,
        bg = bg,
        res = res
      ),
      extra_args
    )
    if (startsWith(backend, "cairo_")) {
      args$type <- "cairo"
    }
    do.call(device_fun, args)
  }
  invisible(backend)
}
