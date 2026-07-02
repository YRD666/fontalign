test_that("fontalign_resolve_backend picks cairo_pdf for vector output", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
       ggplot2::geom_point() +
       ggplot2::labs(title = "Latin only")
  r <- fontalign_resolve_backend(p, use = "auto",
                                 file = tempfile(fileext = ".pdf"))
  expect_true(r$name %in% c("cairo_pdf", "svglite"))
})

test_that("fontalign_resolve_backend picks ragg for Arabic bitmap", {
  skip_if_not_installed("ragg")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
       ggplot2::geom_point() +
       ggplot2::labs(title = "مرحبا")
  r <- fontalign_resolve_backend(p, use = "auto",
                                 file = tempfile(fileext = ".png"))
  expect_equal(r$name, "ragg")
})

test_that("fontalign_resolve_backend respects forced choices", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
       ggplot2::geom_point()
  expect_equal(
    fontalign_resolve_backend(p, use = "cairo",
                              file = tempfile(fileext = ".png"))$name,
    "cairo_png")
  skip_if_not_installed("ragg")
  expect_equal(
    fontalign_resolve_backend(p, use = "ragg",
                              file = tempfile(fileext = ".png"))$name,
    "ragg")
})
