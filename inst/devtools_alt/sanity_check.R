root <- "D:/Program Files/R/R-4.4.1/sandbox/fontalign"
setwd(root)
.libPaths(c(root, .libPaths()))

# Skip pkgbuild's heavy machinery; do the minimum:
# 1. Source every R file.
# 2. Run testthat directly.
cat("=== sourcing R files ===\n")
for (f in list.files("R", full.names = TRUE, pattern = "\\.R$")) {
  cat("source:", f, "\n")
  tryCatch(source(f), error = function(e) cat("  ERROR:", conditionMessage(e), "\n"))
}

cat("\n=== loading via devtools-style load_all emulation ===\n")
ns_env <- new.env(parent = globalenv())
for (f in list.files("R", full.names = TRUE, pattern = "\\.R$")) {
  sys.source(f, envir = ns_env)
}
# Manually inject package globals (since we have no .onLoad).
assign("fonts_noto_cjk_count", 0, envir = ns_env)

cat("=== functions defined ===\n")
print(ls(ns_env))

cat("\n=== check_cairo_pango / fontalign_check_system (raw) ===\n")
print(ns_env$fontalign_check_system)

cat("\n=== detect_scripts tests ===\n")
scripts <- ns_env$detect_scripts(c("Hello", "你好", "مرحبا", "नमस्ते", "🎉"))
print(scripts)

cat("\n=== plot_scripts roundtrip ===\n")
suppressPackageStartupMessages({
  library(ggplot2)
})
# Manually alias internal helpers used by plot_scripts and friends
# without going through pkgload (which trips on Windows here).
assign("plot_scripts", ns_env$plot_scripts, envir = globalenv())
assign("fontalign_save", ns_env$fontalign_save, envir = globalenv())
assign("fontalign_resolve_backend", ns_env$fontalign_resolve_backend,
       envir = globalenv())
assign("fontalign_list_fonts", ns_env$fontalign_list_fonts, envir = globalenv())
assign("fontalign_check_system", ns_env$fontalign_check_system, envir = globalenv())
assign("device_is_vector", ns_env$device_is_vector, envir = globalenv())
assign("dpi_alignment_factor", ns_env$dpi_alignment_factor, envir = globalenv())

# %||% from rlang if available; otherwise define inline
if (!exists("%||%", envir = globalenv())) {
  `%||%` <- function(a, b) if (!is.null(a)) a else b
}

p <- ggplot(mtcars, aes(mpg, wt)) +
  geom_point() +
  labs(title = "Latin plot",
       x = "MPG",
       y = "Weight")
ps <- ns_env$plot_scripts(p)
cat("plot_scripts: ", paste(ps, collapse = " | "), "\n", sep = "")

cat("\n=== fontalign_resolve_backend (no plot) ===\n")
r <- ns_env$fontalign_resolve_backend(plot = NULL,
                                      use = "auto",
                                      file = "test.png")
cat("name:", r$name, "\n")

cat("\n=== fontalign_save roundtrip ===\n")
out_pdf <- file.path(root, "_test_out.pdf")
ns_env$fontalign_save(p, out_pdf, width = 4, height = 3, dpi = 96)
cat("file exists:", file.exists(out_pdf), "size:", file.info(out_pdf)$size, "\n")

cat("\n=== ALL DONE ===\n")
