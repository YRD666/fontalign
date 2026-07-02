library(fontalign)
library(ggplot2)

# Latin-only labels; default Cairo backend suffices.
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
     geom_point() +
     labs(title = "Iris dataset",
          x = "Sepal length (cm)",
          y = "Sepal width (cm)")

# fontalign_save aligns text size to target dpi=300 across devices.
fontalign_save(p, "iris_en.pdf", width = 6, height = 4, dpi = 300)
fontalign_save(p, "iris_en.png", width = 6, height = 4, dpi = 300)
