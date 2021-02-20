my_theme <- theme_gray() + 
  theme(
    legend.text = element_text(color = "#2c241e"),
    legend.title = element_text(color = "#2c241e"),
    axis.text = element_text(color = "#2c241e"),
    axis.title = element_text(color = "#2c241e"),
    plot.title = element_text(color = "#2c241e"),
    plot.subtitle = element_text(color = "#2c241e", size = 9),
    axis.line.y = element_blank(),
    axis.line.x = element_line(color = "#2c241e"),
    panel.grid.major.y = element_line(
      color = "#2c241e", 
      linetype = "dashed", 
      size = .05
    ),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )