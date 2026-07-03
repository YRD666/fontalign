# fontalign

Backend-agnostic font size alignment for ggplot2 outputs. Targets Linux
servers running global-facing analytics platforms.

## What this package does

`fontalign` solves three problems that show up when the same plot is rendered
to PDF, PNG, and SVG on a Linux server:

1. Font size consistency: A 12pt label in `ggsave("plot.pdf", ...)` must
   appear the same size as in `ggsave("plot.png", ..., dpi = 300)`.
2. Complex-script fallback: Arabic, Persian, Devanagari, Thai, and emoji
   need HarfBuzz shaping and a fontconfig fallback chain. Cairo alone is
   insufficient on bare RHEL/CentOS images.
3. Deployment diagnostics: System admins need a one-shot check that
   reports whether the system has the fonts and libraries required.

`fontalign` does **not** modify your ggplot object, theme, or graphics
state. For ggplot objects it wraps `ggsave()` and routes rendering to an
appropriate backend based on the detected writing systems in your labels.
For base graphics, grid, lattice, and packages that draw directly to the
active device, it provides device-level wrappers around bitmap output.

## Quick start

```r
library(fontalign)
fontalign_check_system()                  # once per server, sanity check

p <- ggplot(...) + theme(text = element_text(family = "Noto Sans CJK SC"))

# Save with explicit target DPI; fontalign aligns accordingly.
fontalign_save(p, "plot.pdf", width = 6, height = 4, dpi = 300)

# Force HarfBuzz-capable backend for plots containing Arabic.
fontalign_save(p, "plot.png", width = 6, height = 4, dpi = 300,
               use = "ragg")
```

For code that currently uses `png(); ...; dev.off()`, use the device wrapper:

```r
fontalign_png("base-plot.png", width = 1600, height = 1000, res = 200)
plot(1:10, main = "中文 عربي English")
dev.off()

# Or let fontalign close the device even if drawing errors.
with_fontalign_device(
  "base-plot.png",
  {
    plot(1:10, main = "中文 عربي English")
    text(5, 8, "多语言 label")
  },
  width = 1600,
  height = 1000,
  res = 200
)
```

The same device API covers JPEG and TIFF:

```r
fontalign_jpeg("base-plot.jpg", width = 1600, height = 1000, res = 200)
plot(1:10, main = "中文 عربي English")
dev.off()

with_fontalign_device(
  "base-plot.tiff",
  {
    plot(1:10, main = "中文 عربي English")
  },
  device = "tiff",
  width = 1600,
  height = 1000,
  res = 200
)
```

## Design philosophy

* Do not modify ggplot2 internals or theme defaults.
* Do not globally `trace()` base graphics functions.
* Wrap `ggsave()` for ggplot objects and provide device-level wrappers for
  code that draws to active bitmap devices.
* Defer complex-script shaping to backends that already do it well
  (ragg, svglite). Do not reinvent HarfBuzz.

See `vignette("why-fontalign")` for the longer story.

## Server setup (Linux)

Recommended baseline for Ubuntu/Debian:

```bash
apt-get install -y \
  libcairo2-dev libpango1.0-dev libfontconfig1-dev \
  libharfbuzz-dev libfribidi-dev librsvg2-dev \
  fonts-noto fonts-noto-cjk fonts-noto-color-emoji

R -e 'install.packages(c("ragg", "svglite", "rsvg", "systemfonts", "textshaping"))'
```

## Status

0.1.0 — Linux only, vector (cairo_pdf / svglite) + bitmap
(cairo_png/jpeg/tiff, ragg).
Windows and macOS will fall back to default devices with a warning.

## License

MIT.
