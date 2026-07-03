\name{fontalign}
\alias{fontalign}
\alias{fontalign_save}
\alias{fontalign_resolve_backend}
\alias{fontalign_check_system}
\alias{fontalign_list_fonts}
\alias{fontalign_bitmap_backend}
\alias{fontalign_png_backend}
\alias{fontalign_png}
\alias{fontalign_jpeg}
\alias{fontalign_tiff}
\alias{with_fontalign_device}
\title{Font-aligned graphics output helpers}
\description{
Render ggplot2 and device-based R graphics through font rendering backends that
keep multilingual text sizing more consistent across output formats.
}
\usage{
fontalign_save(plot, file, width = NA, height = NA,
  units = c("in", "cm", "mm", "px"), dpi = 300, use = "auto", ...)

fontalign_resolve_backend(plot, use = "auto", file = NULL)

fontalign_check_system()

fontalign_list_fonts()

fontalign_bitmap_backend(use = "auto", device = c("png", "jpeg", "tiff"))

fontalign_png_backend(use = "auto")

fontalign_png(filename = "Rplot\%03d.png", width = 480, height = 480,
  units = c("px", "in", "cm", "mm"), pointsize = 12, bg = "white",
  res = 300, use = "auto", ...)

fontalign_jpeg(filename = "Rplot\%03d.jpeg", width = 480, height = 480,
  units = c("px", "in", "cm", "mm"), pointsize = 12, quality = 75,
  bg = "white", res = 300, use = "auto", ...)

fontalign_tiff(filename = "Rplot\%03d.tiff", width = 480, height = 480,
  units = c("px", "in", "cm", "mm"), pointsize = 12,
  compression = "none", bg = "white", res = 300, use = "auto", ...)

with_fontalign_device(filename, expr, device = c("png", "jpeg", "tiff"),
  width = 480, height = 480, units = c("px", "in", "cm", "mm"),
  pointsize = 12, bg = "white", res = 300, use = "auto", ...)
}
\arguments{
\item{plot}{A ggplot object, or another object supported by
\code{ggplot2::ggsave()}.}
\item{file, filename}{Output file path.}
\item{width, height}{Output dimensions.}
\item{units}{Dimension units.}
\item{dpi, res}{Output resolution in dots per inch.}
\item{use}{Backend preference. Use \code{"auto"} for automatic routing,
\code{"ragg"} to force ragg, \code{"cairo"} to force Cairo-backed bitmap
devices where available, or \code{"svglite"} where supported by
\code{fontalign_resolve_backend()}.}
\item{device}{Bitmap device name.}
\item{pointsize}{Base device text size in points.}
\item{bg}{Background color.}
\item{quality}{JPEG quality percentage.}
\item{compression}{TIFF compression method.}
\item{expr}{Drawing expression evaluated while the device is open.}
\item{...}{Additional arguments forwarded to the selected graphics device or
\code{ggplot2::ggsave()}.}
}
\value{
\code{fontalign_save()} invisibly returns the output file path.
\code{fontalign_resolve_backend()} returns a backend descriptor list.
\code{fontalign_check_system()} invisibly returns a data frame of environment
checks. \code{fontalign_list_fonts()} returns available font families.
Bitmap device functions invisibly return the selected backend name.
\code{with_fontalign_device()} returns the value of \code{expr}.
}
\details{
For ggplot2 output, use \code{fontalign_save()} as a wrapper around
\code{ggplot2::ggsave()}. For base graphics, grid, lattice, and packages that
draw directly to the active device, use \code{fontalign_png()},
\code{fontalign_jpeg()}, \code{fontalign_tiff()}, or
\code{with_fontalign_device()} instead of opening a base graphics device
directly.
}
\examples{
\dontrun{
fontalign_check_system()

fontalign_png("base-plot.png", width = 1600, height = 1000, res = 200)
plot(1:10, main = "中文 Arabic English")
dev.off()

with_fontalign_device("base-plot.jpg", {
  plot(1:10, main = "multilingual labels")
}, device = "jpeg", width = 1600, height = 1000, res = 200)
}
}
\keyword{device}
\keyword{utilities}
