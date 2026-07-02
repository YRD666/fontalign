test_that("detect_scripts finds scripts in mixed strings", {
  scripts <- fontalign:::detect_scripts(c("Hello", "你好", "مرحبا", "नमस्ते"))
  expect_true("latin" %in% scripts)
  expect_true("han" %in% scripts)
  expect_true("arabic" %in% scripts)
  expect_true("devanagari" %in% scripts)
})

test_that("detect_scripts is empty for empty input", {
  expect_equal(fontalign:::detect_scripts(character()), character())
  expect_equal(fontalign:::detect_scripts(NULL), character())
})

test_that("emoji are detected", {
  scripts <- fontalign:::detect_scripts("Hi \u{1F600}")
  expect_true("emoji" %in% scripts)
})
