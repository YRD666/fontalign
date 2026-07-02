library(fontalign)
library(ggplot2)

# Chinese labels: per-glyph characters, no shaping needed,
# so Cairo backend is fine on systems with a CJK font installed.
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
     geom_point() +
     labs(title = "鸢尾花数据集",
          x = "萼片长度（厘米）",
          y = "萼片宽度（厘米）")

fontalign_save(p, "iris_cn.pdf", width = 6, height = 4, dpi = 300)
fontalign_save(p, "iris_cn.png", width = 6, height = 4, dpi = 300)
