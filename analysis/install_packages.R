packages <- c(
  "broom",
  "clubSandwich",
  "dplyr",
  "ggplot2",
  "metafor",
  "purrr",
  "readr",
  "stringr",
  "tibble",
  "tidyr"
)

missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

cat("Package check complete.\n")

