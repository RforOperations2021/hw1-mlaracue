my_theme <- theme_gray() + 
    theme(
        panel.background = element_rect(fill = "#e5e5e5"),
        plot.background = element_rect(fill = "#e5e5e5"),
        legend.box.background = element_rect(fill = "#e5e5e5", color = "#e5e5e5"),
        legend.background = element_rect(fill = "#e5e5e5", color = "#e5e5e5"),
        legend.text = element_text(color = "#2c241e"),
        legend.title = element_text(color = "#2c241e"),
        legend.key = element_rect(fill = "#e5e5e5", color = "#e5e5e5"),
        axis.text = element_text(color = "#2c241e"),
        axis.title = element_text(color = "#2c241e"),
        plot.title = element_text(color = "#2c241e"),
        plot.subtitle = element_text(color = "#2c241e", size = 9),
        axis.line.y = element_blank(),
        axis.line.x = element_line(color = "#2c241e"),
        panel.grid.major.y = element_line(color = "#2c241e", linetype = "dashed", size = .05),
        panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.ticks = element_blank()
    )