library(fontalign)
library(ggplot2)

# Multi-lingual example: Chinese + English captions.
# fontalign detects scripts and routes to the appropriate backend.
p <- ggplot(mtcars, aes(mpg, wt, colour = factor(cyl))) +
     geom_point() +
     labs(title = "油耗与车重 / Fuel efficiency vs Weight",
          x = "每加仑英里 / MPG",
          y = "车重（千磅）")

# Vector output: Cairo auto-fallback handles both scripts on
# a Linux server with Noto CJK + Noto Sans installed.
fontalign_save(p, "global_users.pdf", width = 6, height = 4, dpi = 300)
