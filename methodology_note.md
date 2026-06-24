# Methodology Note

## Project Purpose

This project demonstrates a reproducible survey data workflow for respondent-level data quality control, cleaning, weighting, and reporting. The data are simulated and are intended for demonstration only.

## Data Collection Context

The simulated dataset represents respondent-level survey data with demographic variables, survey item responses, completion time, and an attention-check item. The workflow is designed to resemble a small client-facing survey research process where analysts must evaluate data quality before producing weighted estimates.

## Quality Control Criteria

Respondents are flagged using the following rules:

1. **Duplicate respondent ID**  
   Respondents are flagged if the same respondent ID appears more than once.

2. **Very short completion time**  
   Respondents are flagged if survey completion time is less than 90 seconds.

3. **High missingness**  
   Respondents are flagged if more than 25% of Likert-scale survey items are missing.

4. **Straight-lining**  
   Respondents are flagged if they provide the same non-missing answer across all Likert-scale items.

5. **Attention-check failure**  
   Respondents are flagged if they fail the attention-check item.

Respondents with two or more quality flags are excluded from the analytic dataset.

## Weighting Approach

After quality control, the analytic sample is weighted using raking, also known as iterative proportional fitting. Raking adjusts respondent-level weights so that the weighted sample margins align with external benchmark distributions.

The weighting variables are:

- Age group
- Gender
- Education

In a real survey project, benchmark distributions could come from Census, ACS, voter files, or other validated population sources. In this demo, benchmark distributions are simulated.

## Weight Trimming

Weights are trimmed at the 1st and 99th percentiles to reduce the influence of extreme weights and improve estimate stability.

## Deliverables

The workflow produces:

- Respondent-level quality flags
- Cleaned analytic survey data
- Raking diagnostics
- Trimmed respondent weights
- Weighted and unweighted survey estimates
