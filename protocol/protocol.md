# Protocol: Yield response to sulfur fertilization in crop production

## Working title

Yield response to sulfur fertilizer and sulfur-based nutrient co-application in crop production: a systematic review and meta-analysis.

## Rationale

Sulfur deficiency is increasingly reported in intensive cropping systems because of lower atmospheric sulfur deposition, higher crop yields, and changes in fertilizer composition. However, sulfur is often applied together with N, P, K, Mg, or micronutrients. A conventional treatment-versus-control meta-analysis can therefore confound the sulfur effect with the companion nutrient effect.

This review prioritizes background-matched comparisons to estimate the marginal contribution of sulfur fertilization.

## Population

Field, pot, greenhouse, and controlled agronomic experiments on food, feed, fiber, oilseed, vegetable, or forage crops.

## Intervention

Sulfur fertilizer applied as elemental sulfur, sulfate sulfur, gypsum, ammonium sulfate, potassium sulfate, magnesium sulfate, bentonite sulfur, sulfur-coated fertilizer, or other sulfur-containing fertilizer.

## Comparators

Preferred comparator:

- Same non-sulfur fertilization background without sulfur.

Accepted comparator:

- Absolute no-sulfur control for S-only treatments.

Sensitivity comparator:

- Full fertilizer package versus absolute control, coded as `package_vs_absolute_control`.

## Outcomes

Primary outcome:

- Crop yield converted to t/ha where possible.

Secondary outcomes:

- Crop quality traits.
- Sulfur uptake.
- Nitrogen use efficiency.
- Economic return if available.

## Effect size

Primary effect size:

```text
lnRR = log(mean yield with S / mean yield without S)
```

Reported interpretation:

```text
percent yield response = (exp(lnRR) - 1) * 100
```

## Moderator variables

- Crop group and species.
- Crop sulfur-demand tier.
- S rate and source.
- Application method and timing.
- Soil available S.
- Soil pH and organic matter.
- Nutrient background: none, N, P, K, NPK, secondary or micronutrient.
- Region and climate zone.
- Risk of bias and comparison quality.

## Planned synthesis

1. Overall multilevel random-effects model.
2. Subgroup models by treatment role and crop group.
3. Moderator models for sulfur rate, soil available S, and crop sulfur-demand tier.
4. Sensitivity analysis excluding `package_vs_absolute_control` contrasts.
5. Sensitivity analysis excluding imputed variance rows.
6. Funnel plot and publication-bias diagnostics when the final dataset is large enough.

## Reporting standard

Use PRISMA 2020 for reporting and ROSES-style transparency for evidence synthesis workflow where useful.

