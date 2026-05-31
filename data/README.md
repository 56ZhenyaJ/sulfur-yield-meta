# Data guidance

Do not commit copyrighted study PDFs, extracted full-text tables, or publisher-owned supplementary files.

Recommended workflow:

1. Save bibliographic files in `data/raw/` locally.
2. Extract one treatment-control contrast per row using `data/templates/sulfur_yield_extraction_template.csv`.
3. Prefer background-matched controls:
   - `S + N` versus `N`
   - `S + NPK` versus `NPK`
   - `S + micronutrient` versus the same micronutrient background without S
4. Use `package_vs_absolute_control` only when the paper does not provide a matched non-S control.
5. Keep uncertainty data where possible: SD, SE, CI, LSD, or replicate-level data.

The example file in `data/example/` is synthetic and is only provided for pipeline testing.

