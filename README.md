# Sulfur Yield Meta

[![R pipeline](https://github.com/56ZhenyaJ/sulfur-yield-meta/actions/workflows/r-pipeline.yml/badge.svg)](https://github.com/56ZhenyaJ/sulfur-yield-meta/actions/workflows/r-pipeline.yml)

Reproducible toolkit for an agronomic meta-analysis of sulfur fertilizer effects on crop yield, with special attention to sulfur applied alone and sulfur co-applied with nitrogen, phosphorus, potassium, magnesium, and micronutrients.

## Why this project is different

Most fertilizer meta-analyses treat a fertilization package as one treatment. That can overstate the sulfur effect when sulfur is applied together with other nutrients. This project is designed around a stricter agronomic question:

> What is the marginal yield response to sulfur when the non-sulfur nutrient background is matched?

The project therefore separates:

- `S-only` effects: sulfur versus no sulfur without added companion nutrients.
- `S+N`, `S+P`, `S+K`, `S+NPK`, and `S+micronutrient` effects: sulfur versus the same background fertilization without sulfur.
- `Package` effects: full nutrient package versus absolute control, kept as a separate sensitivity layer.
- Soil and crop moderators: soil available S, soil pH, crop group, S source, rate, application timing, and baseline yield.

## Core research questions

1. How much does sulfur fertilization increase crop yield overall?
2. Is the yield response stronger for sulfur-demanding crops such as oilseed rape, brassicas, legumes, and alliums?
3. Does co-application with N, P, K, Mg, Zn, or B change the sulfur response?
4. Is there a dose-response threshold or diminishing return for S rate?
5. Which soil conditions predict a large yield response?

## Project structure

```text
sulfur-yield-meta/
├── R/                         # Reusable analysis functions
├── analysis/                  # Pipeline entrypoint
├── data/
│   ├── example/               # Synthetic demo data
│   ├── processed/             # Generated effect-size tables
│   ├── raw/                   # Put extracted real studies here
│   └── templates/             # Extraction template and codebook CSV
├── docs/                      # Search, screening, extraction, innovation notes
├── figures/                   # Generated plots
├── manuscript/                # Quarto manuscript skeleton
└── protocol/                  # Review protocol skeleton
```

## Quick start

Install R packages and run the demo pipeline:

```r
source("analysis/install_packages.R")
source("analysis/run_pipeline.R")
```

By default the pipeline uses `data/example/sulfur_yield_example.csv`. To analyze your own data, copy the template:

```text
data/templates/sulfur_yield_extraction_template.csv
```

to:

```text
data/raw/sulfur_yield_extraction.csv
```

Then fill one row per treatment-control contrast and rerun:

```r
source("analysis/run_pipeline.R")
```

## Effect-size logic

The default effect size is the natural log response ratio:

```text
lnRR = log(mean_yield_treatment / mean_yield_control)
```

It is reported back as percent yield gain:

```text
yield_gain_percent = (exp(lnRR) - 1) * 100
```

For a sulfur co-application study, the preferred control is not an unfertilized control. It is the same nutrient background without sulfur. For example:

```text
S + N + P + K  versus  N + P + K
```

This keeps the estimate focused on the sulfur contribution.

## Innovation modules

- Background-matched sulfur contrast taxonomy.
- S-only versus S co-application moderator framework.
- Soil sulfur deficiency stratification.
- Crop sulfur-demand tiering.
- Dose-response curve for S rate.
- Sensitivity flags for package effects and incomplete variance reporting.
- PRISMA/ROSES-ready documentation.

## Chinese summary

本项目用于开展“硫肥及硫肥配合其他元素对作物增产效应”的农学 Meta 分析。项目重点不是简单比较“施肥包 vs 不施肥”，而是尽量构建“相同非硫养分背景下，有硫 vs 无硫”的对照，从而更准确估计硫肥本身的边际增产效应。

推荐优先录入以下对照：

- 单施硫肥 vs 不施硫肥
- 硫+氮 vs 单施氮
- 硫+磷 vs 单施磷
- 硫+钾 vs 单施钾
- 硫+NPK vs NPK
- 硫+中微量元素 vs 相同背景但无硫处理

## Citation

If you use this repository, please cite it using the metadata in `CITATION.cff`.
