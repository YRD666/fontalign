test_that("fontalign_png opens a bitmap device for base graphics", {
  out <- tempfile(fileext = ".png")
  fontalign_png(out, width = 480, height = 320, res = 120)
  plot(1:4, 1:4, main = "中文 عربي English", xlab = "时间", ylab = "value")
  grDevices::dev.off()

  expect_true(file.exists(out))
  expect_gt(file.info(out)$size, 0)
})

test_that("with_fontalign_device evaluates code and closes the device", {
  out <- tempfile(fileext = ".png")
  before <- grDevices::dev.cur()

  value <- with_fontalign_device(
    out,
    {
      plot(1:3, 1:3, main = "base graphics 中文 عربي")
      "returned"
    },
    width = 480,
    height = 320,
    res = 120
  )

  expect_equal(value, "returned")
  expect_equal(grDevices::dev.cur(), before)
  expect_true(file.exists(out))
  expect_gt(file.info(out)$size, 0)
})

test_that("fontalign_png prefers ragg for PNG when available", {
  skip_if_not_installed("ragg")
  expect_equal(fontalign_png_backend(use = "auto"), "ragg")
  expect_equal(fontalign_png_backend(use = "ragg"), "ragg")
  expect_true(fontalign_png_backend(use = "cairo") %in% c("cairo_png", "png"))
})

test_that("fontalign bitmap wrappers cover jpeg and tiff devices", {
  jpeg_out <- tempfile(fileext = ".jpg")
  tiff_out <- tempfile(fileext = ".tiff")

  fontalign_jpeg(jpeg_out, width = 480, height = 320, res = 120)
  plot(1:4, 1:4, main = "JPEG 中文 عربي English")
  grDevices::dev.off()

  fontalign_tiff(tiff_out, width = 480, height = 320, res = 120)
  plot(1:4, 1:4, main = "TIFF 中文 عربي English")
  grDevices::dev.off()

  expect_true(file.exists(jpeg_out))
  expect_true(file.exists(tiff_out))
  expect_gt(file.info(jpeg_out)$size, 0)
  expect_gt(file.info(tiff_out)$size, 0)
})

test_that("with_fontalign_device selects non-png bitmap devices", {
  out <- tempfile(fileext = ".jpg")

  value <- with_fontalign_device(
    out,
    {
      plot(1:3, 1:3, main = "JPEG wrapper 中文 عربي")
      "jpeg"
    },
    device = "jpeg",
    width = 480,
    height = 320,
    res = 120
  )

  expect_equal(value, "jpeg")
  expect_true(file.exists(out))
  expect_gt(file.info(out)$size, 0)
})
