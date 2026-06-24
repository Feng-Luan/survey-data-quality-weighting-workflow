# 04_run_full_workflow.R
# Run the full survey data quality and weighting workflow.

source("scripts/01_generate_simulated_survey_data.R")
source("scripts/02_quality_control.R")
source("scripts/03_raking_weights.R")

cat("\nFull workflow completed successfully.\n")
