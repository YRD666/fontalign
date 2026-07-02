test_that("dpi_alignment_factor is 1 for vector devices", {
  expect_equal(
    fontalign:::dpi_alignment_factor(origin = 96, target = 300, device_is_vector = TRUE),
    1
  )
})

test_that("dpi_alignment_factor scales for bitmap devices", {
  expect_equal(
    fontalign:::dpi_alignment_factor(origin = 96, target = 300, device_is_vector = FALSE),
    300/96,
    tolerance = 1e-9
  )
})

test_that("dpi_alignment_factor is 1 when origin equals target", {
  expect_equal(
    fontalign:::dpi_alignment_factor(origin = 200, target = 200, device_is_vector = FALSE),
    1
  )
})

test_that("dpi_alignment_factor is 1 on bad input", {
  expect_equal(
    fontalign:::dpi_alignment_factor(origin = NA, target = 300, device_is_vector = FALSE),
    1
  )
})
