packages <- c("dplyr", "ggplot2", "metafor", "purrr", "readr", "stringr", "tibble", "tidyr")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop(
    "Missing packages: ",
    paste(missing_packages, collapse = ", "),
    ". Run source('analysis/install_packages.R') first.",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(metafor)
  library(purrr)
  library(readr)
  library(stringr)
  library(tibble)
  library(tidyr)
})

if (!file.exists("R/01_effect_sizes.R") && file.exists("../R/01_effect_sizes.R")) {
  setwd("..")
}

source("R/01_effect_sizes.R")
source("R/02_models.R")
source("R/03_figures.R")

raw_path <- "data/raw/sulfur_yield_extraction.csv"
example_path <- "data/example/sulfur_yield_example.csv"
input_path <- if (file.exists(raw_path)) raw_path else example_path

message("Reading input: ", input_path)
raw_data <- readr::read_csv(input_path, show_col_types = FALSE)

effects <- raw_data |>
  prepare_sulfur_data(assumed_cv = 0.15) |>
  compute_lnrr_effects()

write_effect_table(effects, "data/processed/effect_sizes.csv")

model_outputs <- run_meta_models(effects)
write_model_outputs(model_outputs, "data/processed")

save_pipeline_figures(effects, "figures")

message("Pipeline complete.")
message("Effect sizes: data/processed/effect_sizes.csv")
message("Model summaries: data/processed/*.csv")
message("Figures: figures/*.png")
