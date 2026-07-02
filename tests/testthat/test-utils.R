test_that("coalesce handles NULL, NA, and empty", {
  expect_equal(fontalign:::coalesce(NULL, "x"), "x")
  expect_equal(fontalign:::coalesce(NA, "x"), "x")
  expect_equal(fontalign:::coalesce("", "x"), "x")
  expect_equal(fontalign:::coalesce("a", "x"), "a")
})

test_that("sys_version returns NA when command is missing", {
  expect_true(is.na(fontalign:::sys_version("definitely-not-a-real-binary-xyz")))
})

test_that("has_exec detects missing executables", {
  expect_false(fontalign:::has_exec("definitely-not-a-real-binary-xyz"))
})
