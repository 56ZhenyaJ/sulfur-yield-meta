plot_yield_gain_by_role <- function(effects) {
  ggplot2::ggplot(
    effects,
    ggplot2::aes(x = treatment_role, y = yield_gain_percent, color = comparison_quality)
  ) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, color = "grey55") +
    ggplot2::geom_jitter(width = 0.15, height = 0, alpha = 0.75, size = 2) +
    ggplot2::stat_summary(fun = mean, geom = "point", shape = 18, size = 4, color = "black") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      x = NULL,
      y = "Yield response to sulfur (%)",
      color = "Contrast quality",
      title = "Sulfur yield response by treatment role"
    ) +
    ggplot2::theme_minimal(base_size = 12)
}

plot_dose_response <- function(effects) {
  ggplot2::ggplot(
    effects,
    ggplot2::aes(x = s_rate_kg_ha, y = yield_gain_percent, color = crop_s_demand)
  ) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, color = "grey55") +
    ggplot2::geom_point(alpha = 0.78, size = 2) +
    ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = TRUE, linewidth = 0.8) +
    ggplot2::labs(
      x = "Sulfur rate (kg S/ha)",
      y = "Yield response to sulfur (%)",
      color = "Crop S demand",
      title = "Dose-response pattern for sulfur fertilization"
    ) +
    ggplot2::theme_minimal(base_size = 12)
}

plot_soil_s_gradient <- function(effects) {
  dat <- effects |>
    dplyr::filter(!is.na(.data$soil_available_s_mg_kg))

  ggplot2::ggplot(
    dat,
    ggplot2::aes(x = soil_available_s_mg_kg, y = yield_gain_percent, color = crop_group)
  ) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, color = "grey55") +
    ggplot2::geom_point(alpha = 0.78, size = 2) +
    ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE, linewidth = 0.8) +
    ggplot2::labs(
      x = "Initial soil available S (mg/kg)",
      y = "Yield response to sulfur (%)",
      color = "Crop group",
      title = "Response gradient by initial soil sulfur"
    ) +
    ggplot2::theme_minimal(base_size = 12)
}

save_pipeline_figures <- function(effects, output_dir = "figures") {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  plots <- list(
    yield_gain_by_role = plot_yield_gain_by_role(effects),
    dose_response = plot_dose_response(effects),
    soil_s_gradient = plot_soil_s_gradient(effects)
  )

  purrr::iwalk(plots, function(plot, name) {
    ggplot2::ggsave(
      filename = file.path(output_dir, paste0(name, ".png")),
      plot = plot,
      width = 8,
      height = 5,
      dpi = 300
    )
  })

  invisible(plots)
}

