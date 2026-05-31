fit_meta_model <- function(dat, mods = NULL) {
  if (nrow(dat) < 2) {
    return(NULL)
  }

  formula_mods <- if (is.null(mods)) {
    NULL
  } else {
    stats::as.formula(paste("~", mods))
  }

  tryCatch(
    {
      mv_args <- list(
        yi = dat$yi,
        V = dat$vi,
        random = stats::as.formula("~ 1 | study_id / experiment_id"),
        method = "REML",
        data = dat
      )
      if (!is.null(formula_mods)) {
        mv_args$mods <- formula_mods
      }
      do.call(metafor::rma.mv, mv_args)
    },
    error = function(e) {
      message("rma.mv failed, falling back to rma.uni: ", conditionMessage(e))
      tryCatch(
        {
          uni_args <- list(
            yi = dat$yi,
            vi = dat$vi,
            method = "REML",
            data = dat
          )
          if (!is.null(formula_mods)) {
            uni_args$mods <- formula_mods
          }
          do.call(metafor::rma.uni, uni_args)
        },
        error = function(e2) {
          message("rma.uni also failed: ", conditionMessage(e2))
          NULL
        }
      )
    }
  )
}

tidy_meta_coefficients <- function(model, label = "model") {
  if (is.null(model)) {
    return(tibble::tibble())
  }

  estimate_lnrr <- as.numeric(stats::coef(model))
  model_se <- as.numeric(model$se)
  ci_lb_lnrr <- as.numeric(model$ci.lb)
  ci_ub_lnrr <- as.numeric(model$ci.ub)
  model_pval <- as.numeric(model$pval)

  terms <- names(stats::coef(model))
  if (is.null(terms) || length(terms) == 0) {
    terms <- paste0("term_", seq_along(estimate_lnrr))
  }

  tibble::tibble(
    model = label,
    term = terms,
    estimate_lnrr = estimate_lnrr,
    se = model_se,
    ci_lb_lnrr = ci_lb_lnrr,
    ci_ub_lnrr = ci_ub_lnrr,
    p_value = model_pval,
    estimate_percent = (exp(estimate_lnrr) - 1) * 100,
    ci_lb_percent = (exp(ci_lb_lnrr) - 1) * 100,
    ci_ub_percent = (exp(ci_ub_lnrr) - 1) * 100
  )
}

fit_subgroup_models <- function(effects, group_col) {
  if (!group_col %in% names(effects)) {
    return(tibble::tibble())
  }

  effects |>
    dplyr::filter(!is.na(.data[[group_col]]), .data[[group_col]] != "") |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_col))) |>
    dplyr::group_modify(function(.x, .y) {
      model <- fit_meta_model(.x)
      out <- tidy_meta_coefficients(model, label = paste0("subgroup_", group_col))
      dplyr::mutate(out, subgroup = as.character(.y[[1]]), k = nrow(.x))
    }) |>
    dplyr::ungroup() |>
    dplyr::rename(group = dplyr::all_of(group_col))
}

fit_moderator_models <- function(effects) {
  candidate_models <- list(
    treatment_role = "0 + factor(treatment_role)",
    comparison_quality = "0 + factor(comparison_quality)",
    crop_s_demand = "0 + factor(crop_s_demand)",
    sulfur_rate_linear = "s_rate_kg_ha",
    soil_available_s_linear = "soil_available_s_mg_kg"
  )

  purrr::imap_dfr(candidate_models, function(mods, model_name) {
    needed_vars <- all.vars(stats::as.formula(paste("~", mods)))
    model_data <- effects |>
      tidyr::drop_na(dplyr::any_of(c("yi", "vi", needed_vars)))

    if (nrow(model_data) < 3) {
      return(tibble::tibble())
    }

    tidy_meta_coefficients(fit_meta_model(model_data, mods = mods), label = paste0("moderator_", model_name))
  })
}

run_meta_models <- function(effects) {
  preferred <- effects |>
    dplyr::filter(.data$comparison_quality != "sensitivity_package_effect")

  overall <- fit_meta_model(preferred)

  list(
    overall = tidy_meta_coefficients(overall, label = "overall_preferred"),
    subgroups_treatment_role = fit_subgroup_models(preferred, "treatment_role"),
    subgroups_crop_group = fit_subgroup_models(preferred, "crop_group"),
    moderators = fit_moderator_models(preferred)
  )
}

write_model_outputs <- function(model_outputs, output_dir = "data/processed") {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  purrr::iwalk(model_outputs, function(tbl, name) {
    if (is.data.frame(tbl) && nrow(tbl) > 0) {
      readr::write_csv(tbl, file.path(output_dir, paste0(name, ".csv")))
    }
  })

  invisible(output_dir)
}
