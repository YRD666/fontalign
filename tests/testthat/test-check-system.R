test_that("fontalign_check_system returns a data frame with expected columns", {
  out <- suppressMessages(fontalign_check_system())
  expect_s3_class(out, "data.frame")
  expect_named(out, c("component", "status", "version"))
  expect_true(all(out$status %in% c("ok", "warn", "fail")))
})

test_that("fontalign_list_fonts returns character vector or empty", {
  out <- fontalign_list_fonts()
  expect_true(is.character(out))
})
