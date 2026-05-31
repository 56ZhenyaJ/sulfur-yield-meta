# Extraction guide

## One row per contrast

Each row should represent one sulfur treatment and its chosen control.

Good contrast:

```text
NPK + S versus NPK
```

Weaker contrast:

```text
NPK + S versus no fertilizer
```

The weaker contrast can still be included as `package_vs_absolute_control`, but it should not drive the primary sulfur effect estimate.

## Converting sulfur rates

Always code `s_rate_kg_ha` as elemental S.

Examples:

- Ammonium sulfate: about 24% S.
- Potassium sulfate: about 18% S.
- Magnesium sulfate heptahydrate: about 13% S.
- Gypsum: depends on hydration and purity; document the assumption.

## Variance data

Preferred:

1. SD and n.
2. SE and n.
3. CI or LSD converted to SD.
4. Imputed coefficient of variation, only for sensitivity analysis.

The demo pipeline imputes missing SD using a 15% CV so the example can run. For a publishable paper, replace imputed variance with extracted or defensible converted variance whenever possible.

