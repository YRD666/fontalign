# Multi-language plot demo using fontalign
#
# This script renders the same ggplot2 plot with labels in different
# scripts (Latin, Chinese, Japanese, Korean, Arabic, Hebrew, Thai,
# Hindi, mixed) and saves them through fontalign_save() so we can see
# how backend routing and font sizing behave side-by-side.
#
# Run with:
#   Rscript multilang_demo.R

# --- Load fontalign sources directly (no install needed) -------------
root <- "D:/Program Files/R/R-4.4.1/sandbox/fontalign"
ns <- new.env(parent = globalenv())
for (f in c("R/utils.R", "R/backend-route.R", "R/device-detect.R",
            "R/dpi-align.R", "R/check-system.R")) {
  sys.source(file.path(root, f), envir = ns)
}
fontalign_save <- ns$fontalign_save
fontalign_check_system <- ns$fontalign_check_system
fontalign_resolve_backend <- ns$fontalign_resolve_backend

suppressPackageStartupMessages({
  library(ggplot2)
})

# --- Output directory ------------------------------------------------
out_dir <- "D:/Program Files/R/R-4.4.1/sandbox/fontalign/inst/demo_out"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("\n=== fontalign_check_system() ===\n")
suppressMessages(fontalign_check_system())

# --- Helper: build a labeled ggplot ---------------------------------
make_plot <- function(title, sub = NULL, xlab = "X", ylab = "Y") {
  ggplot(mtcars, aes(mpg, wt, colour = factor(cyl))) +
    geom_point(size = 2) +
    labs(title = title, subtitle = sub,
         x = xlab, y = ylab,
         colour = "cyl / 缸") +
    theme_minimal(base_size = 12)
}

# --- Per-language plots ---------------------------------------------
plots <- list(
  la = list(title = "Latin only",            sub = "Mileage vs Weight",
            xlab = "Miles per gallon",       ylab = "Weight (1000 lbs)"),
  cn = list(title = "中文标题",            sub = "油耗与车重",
            xlab = "每加仑英里",            ylab = "车重（千磅）"),
  jp = list(title = "日本語タイトル",       sub = "燃費と重量",
            xlab = "1ガロンあたりのマイル数", ylab = "重量（千ポンド）"),
  ko = list(title = "한국어 제목",           sub = "연비와 차중",
            xlab = "갤런당 마일",             ylab = "차량 무게 (천 파운드)"),
  ar = list(title = "عنوان عربي",            sub = "استهلاك الوقود والوزن",
            xlab = "ميل لكل غالون",           ylab = "الوزن (ألف رطل)"),
  he = list(title = "כותרת בעברית",         sub = "צריכת דלק ומשקל",
            xlab = "מייל לגלון",              ylab = "משקל (אלפי ליברות)"),
  hi = list(title = "हिन्दी शीर्षक",          sub = "माइलेज और वज़न",
            xlab = "मील प्रति गैलन",         ylab = "वज़न (हज़ार पाउंड)"),
  th = list(title = "หัวเรื่องภาษาไทย",    sub = "อัตราสิ้นเปลืองกับน้ำหนัก",
            xlab = "ไมล์ต่อแกลลอน",            ylab = "น้ำหนัก (พันปอนด์)"),
  mix = list(title = "Mixed: 混合 / Mixed",
             sub = "English + 中文 + العربية + हिन्दी",
             xlab = "X / X轴 / محور", ylab = "Y / Y轴 / محور")
)

# --- Save each as PDF (vector) and PNG (raster) --------------------
for (nm in names(plots)) {
  p <- do.call(make_plot, plots[[nm]])

  pdf_path <- file.path(out_dir, paste0("plot_", nm, ".pdf"))
  png_path <- file.path(out_dir, paste0("plot_", nm, ".png"))

  fontalign_save(p, pdf_path, width = 6, height = 4)
  fontalign_save(p, png_path, width = 6, height = 4, dpi = 150)
  cat(sprintf("[ok] %s -> pdf=%s png=%s\n", nm, basename(pdf_path),
              basename(png_path)))
}

# --- Side-by-side panel for the multilingual lineup -----------------
panels <- list(
  la = plots$la,
  cn = plots$cn,
  ko = plots$ko,
  ar = plots$ar,
  jp = plots$jp,
  he = plots$he,
  hi = plots$hi,
  th = plots$th
)

make_panel <- function(plot_data) {
  do.call(make_plot, plot_data) +
    theme(plot.title = element_text(size = 11),
          plot.subtitle = element_text(size = 9),
          axis.title = element_text(size = 9))
}

library(gridExtra)
panel_plot <- do.call(gridExtra::arrangeGrob,
                      c(lapply(panels, make_panel),
                        list(ncol = 2)))

panel_pdf <- file.path(out_dir, "panel_all.pdf")
panel_png <- file.path(out_dir, "panel_all.png")
ggsave(panel_pdf, panel_plot, width = 12, height = 14)
ggsave(panel_png, panel_plot, width = 12, height = 14, dpi = 150)
cat(sprintf("[ok] panel -> %s + %s\n", basename(panel_pdf),
            basename(panel_png)))

# --- Render the Chinese plot through every backend explicitly -------
cn_plot <- do.call(make_plot, plots$cn)
backends <- list(
  cairo_pdf = "grDevices::cairo_pdf",
  cairo_png = "grDevices::png",
  rag       = "ragg::agg_png",
  svg       = "svglite::svglite"
)

for (bname in names(backends)) {
  ext <- if (bname == "cairo_pdf") ".pdf"
         else if (bname == "svg") ".svg"
         else ".png"
  path <- file.path(out_dir, paste0("cn_backend_", bname, ext))

  open_dev <- function(dev_call) {
    parts <- strsplit(dev_call, "::", fixed = TRUE)[[1]]
    pkg <- parts[1]
    fn  <- parts[2]
    args <- if (ext == ".pdf" || ext == ".svg") {
      list(filename = path, width = 6, height = 4)
    } else {
      list(filename = path, width = 1200, height = 800, res = 150)
    }
    do.call(get(fn, envir = asNamespace(pkg)), args)
  }

  ok <- tryCatch({
    open_dev(backends[[bname]])
    print(cn_plot)
    dev.off()
    TRUE
  }, error = function(e) {
    cat(sprintf("[skip] backend %s: %s\n", bname, conditionMessage(e)))
    FALSE
  })

  if (ok && file.exists(path)) {
    cat(sprintf("[ok] backend %s -> %s (%d bytes)\n", bname,
                basename(path), file.info(path)$size))
  }
}

cat("\nAll outputs in:", out_dir, "\n")
