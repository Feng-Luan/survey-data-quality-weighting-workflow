# Survey Data Quality and Weighting Workflow in R

This project demonstrates a reproducible survey data workflow using simulated respondent-level survey data. It is designed as a small portfolio project for survey research, data quality control, weighting, and client-style reporting.

## Overview

The workflow covers:

- Simulated survey response data generation
- Respondent-level quality control flags
- Duplicate ID detection
- Response-time screening
- Missingness checks
- Straight-lining detection across Likert items
- Attention-check failure detection
- Demographic benchmark comparison
- Raking / iterative proportional fitting weighting
- Weighted and unweighted survey estimates
- Methodology documentation
- Reproducible R Markdown reporting

## Project Structure

```text
survey_data_quality_weighting_workflow/
├── README.md
├── data/
│   ├── population_benchmarks.csv
│   └── simulated_survey_data.csv
├── scripts/
│   ├── 01_generate_simulated_survey_data.R
│   ├── 02_quality_control.R
│   ├── 03_raking_weights.R
│   └── 04_run_full_workflow.R
├── reports/
│   ├── methodology_note.md
│   └── survey_quality_report.Rmd
└── output/
    ├── cleaned_survey_data.csv
    ├── respondent_quality_flags.csv
    ├── weighting_diagnostics.csv
    └── weighted_estimates.csv
```

## How to Run

From the project folder, run:

```r
source("scripts/04_run_full_workflow.R")
```

This will run the full workflow from data generation through quality control, raking weights, and weighted estimates.

To render the report:

```r
rmarkdown::render("reports/survey_quality_report.Rmd")
```

## Methods Summary

### Quality Control

Responses are flagged based on:

1. Duplicate respondent IDs
2. Very short completion time
3. High item-level missingness
4. Straight-lining across Likert-scale items
5. Failed attention checks

A respondent is excluded from the analytic dataset if they receive two or more quality flags.

### Raking Weighting

The workflow applies iterative proportional fitting, also known as raking, to align the cleaned survey sample to benchmark distributions for:

- Age group
- Gender
- Education

Weights are trimmed at the 1st and 99th percentiles to reduce the impact of extreme weights.

## Notes

The dataset is fully simulated and does not contain real respondent information.
