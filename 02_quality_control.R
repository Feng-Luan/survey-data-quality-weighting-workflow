# 02_quality_control.R
# Conduct respondent-level survey data quality control.

survey_data <- read.csv("data/simulated_survey_data.csv")
question_cols <- paste0("q", 1:10)

count_unique_nonmissing <- function(x) {
  length(unique(x[!is.na(x)]))
}

survey_data$flag_duplicate_id <- duplicated(survey_data$respondent_id) |
  duplicated(survey_data$respondent_id, fromLast = TRUE)

survey_data$flag_fast_response <- survey_data$completion_time_sec < 90

survey_data$item_missing_rate <- rowMeans(is.na(survey_data[, question_cols]))
survey_data$flag_high_missingness <- survey_data$item_missing_rate > 0.25

survey_data$unique_likert_values <- apply(
  survey_data[, question_cols],
  1,
  count_unique_nonmissing
)

survey_data$flag_straight_lining <- survey_data$unique_likert_values == 1

survey_data$flag_attention_check_failed <- survey_data$attention_check == "Incorrect"

flag_cols <- c(
  "flag_duplicate_id",
  "flag_fast_response",
  "flag_high_missingness",
  "flag_straight_lining",
  "flag_attention_check_failed"
)

survey_data$quality_flag_count <- rowSums(survey_data[, flag_cols])
survey_data$exclude_from_analysis <- survey_data$quality_flag_count >= 2

quality_summary <- data.frame(
  metric = c(
    "Total responses",
    "Duplicate respondent ID",
    "Very short completion time",
    "High item missingness",
    "Straight-lining",
    "Attention check failed",
    "Excluded from analysis",
    "Retained for analysis"
  ),
  count = c(
    nrow(survey_data),
    sum(survey_data$flag_duplicate_id),
    sum(survey_data$flag_fast_response),
    sum(survey_data$flag_high_missingness),
    sum(survey_data$flag_straight_lining),
    sum(survey_data$flag_attention_check_failed),
    sum(survey_data$exclude_from_analysis),
    sum(!survey_data$exclude_from_analysis)
  )
)

cleaned_data <- subset(survey_data, exclude_from_analysis == FALSE)

write.csv(survey_data, "output/respondent_quality_flags.csv", row.names = FALSE)
write.csv(cleaned_data, "output/cleaned_survey_data.csv", row.names = FALSE)
write.csv(quality_summary, "output/quality_control_summary.csv", row.names = FALSE)

print(quality_summary)
cat("Quality control outputs saved to output/.\n")
