test_that("fontalign_save writes a PNG file", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  out <- tempfile(fileext = ".png")
  fontalign_save(p, out, width = 4, height = 3, dpi = 96)
  expect_true(file.exists(out))
  expect_gt(file.info(out)$size, 0)
})

test_that("fontalign_save writes a PDF file", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  out <- tempfile(fileext = ".pdf")
  fontalign_save(p, out, width = 4, height = 3)
  expect_true(file.exists(out))
  expect_gt(file.info(out)$size, 0)
})

test_that("fontalign_save and ggplot2::ggsave produce same file for Latin labels", {
  skip_on_cran()
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
       ggplot2::geom_point() +
       ggplot2::labs(title = "Latin plot")
  ref <- tempfile(fileext = ".pdf")
  fa  <- tempfile(fileext = ".pdf")
  ggplot2::ggsave(ref, p, width = 4, height = 3)
  fontalign_save(p, fa, width = 4, height = 3)
  expect_equal(file.info(ref)$size, file.info(fa)$size,
               tolerance = 0.05)
})
