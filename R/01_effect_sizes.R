required_columns <- c(
  "study_id",
  "experiment_id",
  "crop_group",
  "crop_species",
  "treatment_id",
  "treatment_role",
  "comparison_frame",
  "s_rate_kg_ha",
  "yield_t_ha",
  "control_yield_t_ha"
)

numeric_columns <- c(
  "year",
  "latitude",
  "longitude",
  "soil_ph",
  "soil_organic_matter_g_kg",
  "soil_available_s_mg_kg",
  "baseline_yield_t_ha",
  "s_rate_kg_ha",
  "co_n_kg_ha",
  "co_p2o5_kg_ha",
  "co_k2o_kg_ha",
  "co_mg_kg_ha",
  "co_zn_kg_ha",
  "co_b_kg_ha",
  "yield_t_ha",
  "yield_sd",
  "yield_se",
  "yield_n",
  "control_yield_t_ha",
  "control_yield_sd",
  "control_yield_se",
  "control_n"
)

validate_sulfur_data <- function(dat) {
  missing <- setdiff(required_columns, names(dat))
  if (length(missing) > 0) {
    stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  invisible(dat)
}

infer_crop_s_demand <- function(crop_group, crop_species) {
  crop_group <- tolower(ifelse(is.na(crop_group), "", crop_group))
  crop_species <- tolower(ifelse(is.na(crop_species), "", crop_species))
  crop_text <- paste(crop_group, crop_species)

  dplyr::case_when(
    stringr::str_detect(crop_text, "rapeseed|canola|mustard|brassica|cabbage|broccoli|cauliflower|onion|garlic|allium") ~ "high",
    stringr::str_detect(crop_text, "oilseed|vegetable|forage|alfalfa") ~ "high",
    stringr::str_detect(crop_text, "legume|soybean|peanut|bean|pea") ~ "medium",
    stringr::str_detect(crop_text, "wheat|rice|maize|corn|barley|cereal") ~ "lower",
    TRUE ~ "unknown"
  )
}

infer_nutrient_background <- function(dat) {
  co_cols <- intersect(
    c("co_n_kg_ha", "co_p2o5_kg_ha", "co_k2o_kg_ha", "co_mg_kg_ha", "co_zn_kg_ha", "co_b_kg_ha"),
    names(dat)
  )

  for (col in co_cols) {
    dat[[col]][is.na(dat[[col]])] <- 0
  }

  dat |>
    dplyr::mutate(
      has_n = .data$co_n_kg_ha > 0,
      has_p = .data$co_p2o5_kg_ha > 0,
      has_k = .data$co_k2o_kg_ha > 0,
      has_mg = .data$co_mg_kg_ha > 0,
      has_zn = .data$co_zn_kg_ha > 0,
      has_b = .data$co_b_kg_ha > 0,
      nutrient_background = dplyr::case_when(
        has_n & has_p & has_k ~ "NPK",
        has_n & !has_p & !has_k ~ "N",
        !has_n & has_p & !has_k ~ "P",
        !has_n & !has_p & has_k ~ "K",
        has_n | has_p | has_k ~ "mixed_NPK_partial",
        has_mg | has_zn | has_b ~ "secondary_or_micronutrient",
        TRUE ~ "none"
      )
    )
}

prepare_sulfur_data <- function(dat, assumed_cv = 0.15) {
  validate_sulfur_data(dat)

  dat <- dat |>
    dplyr::mutate(dplyr::across(dplyr::any_of(numeric_columns), ~ suppressWarnings(as.numeric(.x)))) |>
    infer_nutrient_background() |>
    dplyr::mutate(
      crop_s_demand = infer_crop_s_demand(.data$crop_group, .data$crop_species),
      yield_n_final = dplyr::coalesce(.data$yield_n, 3),
      control_n_final = dplyr::coalesce(.data$control_n, 3),
      yield_sd_from_se = dplyr::if_else(!is.na(.data$yield_se), .data$yield_se * sqrt(.data$yield_n_final), NA_real_),
      control_yield_sd_from_se = dplyr::if_else(!is.na(.data$control_yield_se), .data$control_yield_se * sqrt(.data$control_n_final), NA_real_),
      yield_sd_final = dplyr::coalesce(.data$yield_sd, .data$yield_sd_from_se, .data$yield_t_ha * assumed_cv),
      control_yield_sd_final = dplyr::coalesce(
        .data$control_yield_sd,
        .data$control_yield_sd_from_se,
        .data$control_yield_t_ha * assumed_cv
      ),
      variance_source = dplyr::case_when(
        !is.na(.data$yield_sd) & !is.na(.data$control_yield_sd) ~ "reported_sd",
        !is.na(.data$yield_se) | !is.na(.data$control_yield_se) ~ "converted_from_se",
        TRUE ~ "imputed_cv"
      ),
      comparison_quality = dplyr::case_when(
        .data$comparison_frame == "s_vs_no_s_same_background" ~ "preferred_background_matched",
        .data$comparison_frame == "s_only_vs_absolute_control" ~ "acceptable_s_only",
        .data$comparison_frame == "package_vs_absolute_control" ~ "sensitivity_package_effect",
        TRUE ~ "unclear"
      )
    )

  dat
}

compute_lnrr_effects <- function(dat) {
  dat |>
    dplyr::filter(.data$yield_t_ha > 0, .data$control_yield_t_ha > 0) |>
    dplyr::mutate(
      yi = log(.data$yield_t_ha / .data$control_yield_t_ha),
      vi = (.data$yield_sd_final^2 / (.data$yield_n_final * .data$yield_t_ha^2)) +
        (.data$control_yield_sd_final^2 / (.data$control_n_final * .data$control_yield_t_ha^2)),
      sei = sqrt(.data$vi),
      yield_gain_percent = (exp(.data$yi) - 1) * 100,
      ci_low_percent = (exp(.data$yi - 1.96 * .data$sei) - 1) * 100,
      ci_high_percent = (exp(.data$yi + 1.96 * .data$sei) - 1) * 100
    ) |>
    dplyr::filter(is.finite(.data$yi), is.finite(.data$vi), .data$vi > 0)
}

write_effect_table <- function(effects, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(effects, path)
  invisible(path)
}

