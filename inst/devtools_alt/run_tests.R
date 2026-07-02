root <- "D:/Program Files/R/R-4.4.1/sandbox/fontalign"
old <- setwd(root)
on.exit(setwd(old))
.libPaths(c(root, .libPaths()))

# Source package code into a child namespace-like env
ns <- new.env(parent = globalenv())
sources <- c("R/utils.R", "R/backend-route.R", "R/device-detect.R",
             "R/dpi-align.R", "R/check-system.R", "R/fontalign-package.R")
for (f in sources) sys.source(f, envir = ns)

# Helper: env_eval to use the local namespace env for testthat eval
test_env <- function(code) {
  eval(parse(text = code), envir = ns)
}

library(testthat)
library(ggplot2)

cat("=== test-utils ===\n")
local({
  expect_equal(ns$coalesce(NULL, "x"), "x")
  expect_equal(ns$coalesce(NA, "x"), "x")
  expect_equal(ns$coalesce("", "x"), "x")
  expect_equal(ns$coalesce("a", "x"), "a")
  expect_true(is.na(ns$sys_version("definitely-not-a-real-binary-xyz")))
  expect_false(ns$has_exec("definitely-not-a-real-binary-xyz"))
})
cat("PASS\n")

cat("=== test-detect-scripts ===\n")
local({
  scripts <- ns$detect_scripts(c("Hello", "你好", "مرحبا", "नमस्ते"))
  expect_true("latin" %in% scripts)
  expect_true("han" %in% scripts)
  expect_true("arabic" %in% scripts)
  expect_true("devanagari" %in% scripts)
  expect_equal(ns$detect_scripts(character()), character())
  expect_equal(ns$detect_scripts(NULL), character())
  scripts2 <- ns$detect_scripts(intToUtf8(c(72, 105, 32, 0x1F600)))
  expect_true("emoji" %in% scripts2)
})
cat("PASS\n")

cat("=== test-dpi-align ===\n")
local({
  expect_equal(ns$dpi_alignment_factor(96, 300, TRUE), 1)
  expect_equal(ns$dpi_alignment_factor(96, 300, FALSE),
               300/96, tolerance = 1e-9)
  expect_equal(ns$dpi_alignment_factor(200, 200, FALSE), 1)
  expect_equal(ns$dpi_alignment_factor(NA, 300, FALSE), 1)
})
cat("PASS\n")

cat("=== test-backend-route ===\n")
local({
  p_la <- ggplot(mtcars, aes(mpg, wt)) +
          geom_point() + labs(title = "Latin only")
  r_la <- ns$fontalign_resolve_backend(p_la, use = "auto",
                                       file = tempfile(fileext = ".pdf"))
  expect_true(r_la$name %in% c("cairo_pdf", "svglite"))

  if (requireNamespace("ragg", quietly = TRUE)) {
    p_ar <- ggplot(mtcars, aes(mpg, wt)) +
            geom_point() + labs(title = "مرحبا")
    r_ar <- ns$fontalign_resolve_backend(p_ar, use = "auto",
                                         file = tempfile(fileext = ".png"))
    expect_equal(r_ar$name, "ragg")
  }

  p_en <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
  expect_equal(
    ns$fontalign_resolve_backend(p_en, use = "cairo",
                                 file = tempfile(fileext = ".png"))$name,
    "cairo_png")
})
cat("PASS\n")

cat("=== test-check-system ===\n")
local({
  df <- suppressMessages(ns$fontalign_check_system())
  expect_s3_class(df, "data.frame")
  expect_true(all(c("component", "status", "version") %in% names(df)))
  expect_true(all(df$status %in% c("ok", "warn", "fail")))
  out <- ns$fontalign_list_fonts()
  expect_true(is.character(out))
})
cat("PASS\n")

cat("=== test-save-basic ===\n")
local({
  p <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
  out_png <- tempfile(fileext = ".png")
  ns$fontalign_save(p, out_png, width = 4, height = 3, dpi = 96)
  expect_true(file.exists(out_png))
  expect_gt(file.info(out_png)$size, 0)

  out_pdf <- tempfile(fileext = ".pdf")
  ns$fontalign_save(p, out_pdf, width = 4, height = 3)
  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 0)
})
cat("PASS\n")

cat("\nALL OK\n")
