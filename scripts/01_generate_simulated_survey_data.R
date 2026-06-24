# 01_generate_simulated_survey_data.R
# Generate simulated respondent-level survey data and benchmark distributions.

set.seed(2026)

dir.create("data", showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)

n <- 900

survey_data <- data.frame(
  respondent_id = sprintf("R%05d", 1:n),
  age_group = sample(
    c("18-29", "30-44", "45-64", "65+"),
    n,
    replace = TRUE,
    prob = c(0.34, 0.36, 0.22, 0.08)
  ),
  gender = sample(
    c("Female", "Male", "Other"),
    n,
    replace = TRUE,
    prob = c(0.58, 0.40, 0.02)
  ),
  education = sample(
    c("High school or less", "Some college", "Bachelor's", "Graduate"),
    n,
    replace = TRUE,
    prob = c(0.18, 0.28, 0.34, 0.20)
  ),
  region = sample(
    c("Northeast", "Midwest", "South", "West"),
    n,
    replace = TRUE,
    prob = c(0.18, 0.24, 0.36, 0.22)
  ),
  completion_time_sec = round(rlnorm(n, meanlog = log(430), sdlog = 0.55)),
  attention_check = sample(c("Correct", "Incorrect"), n, replace = TRUE, prob = c(0.95, 0.05))
)

# Simulate 10 Likert-scale survey questions.
for (j in 1:10) {
  survey_data[[paste0("q", j)]] <- sample(
    1:5,
    n,
    replace = TRUE,
    prob = c(0.08, 0.15, 0.25, 0.34, 0.18)
  )
}

# Add realistic missingness.
for (j in 1:10) {
  miss_idx <- sample(1:n, size = round(0.025 * n))
  survey_data[miss_idx, paste0("q", j)] <- NA
}

# Simulate straight-lining behavior.
straight_ids <- sample(1:n, size = 35)
for (i in straight_ids) {
  value <- sample(1:5, 1)
  survey_data[i, paste0("q", 1:10)] <- value
}

# Simulate speeders.
fast_ids <- sample(setdiff(1:n, straight_ids), size = 30)
survey_data$completion_time_sec[fast_ids] <- sample(25:85, length(fast_ids), replace = TRUE)

# Simulate duplicate respondents.
duplicate_rows <- survey_data[sample(1:n, 12), ]
survey_data <- rbind(survey_data, duplicate_rows)

# Population benchmark distributions.
population_benchmarks <- data.frame(
  variable = c(
    rep("age_group", 4),
    rep("gender", 3),
    rep("education", 4)
  ),
  category = c(
    "18-29", "30-44", "45-64", "65+",
    "Female", "Male", "Other",
    "High school or less", "Some college", "Bachelor's", "Graduate"
  ),
  population_prop = c(
    0.22, 0.27, 0.32, 0.19,
    0.51, 0.48, 0.01,
    0.32, 0.28, 0.24, 0.16
  )
)

write.csv(survey_data, "data/simulated_survey_data.csv", row.names = FALSE)
write.csv(population_benchmarks, "data/population_benchmarks.csv", row.names = FALSE)

cat("Generated simulated survey data and population benchmarks.\n")
