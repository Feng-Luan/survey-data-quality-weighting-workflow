# 03_raking_weights.R
# Apply simple raking / iterative proportional fitting to cleaned survey data.

cleaned_data <- read.csv("output/cleaned_survey_data.csv")
benchmarks <- read.csv("data/population_benchmarks.csv")

rake_weights <- function(data, benchmark_data, variables, max_iter = 50, tolerance = 1e-6) {
  weights <- rep(1, nrow(data))
  diagnostics <- data.frame()

  for (iter in 1:max_iter) {
    max_diff <- 0

    for (var in variables) {
      bench_var <- subset(benchmark_data, variable == var)

      for (i in seq_len(nrow(bench_var))) {
        category <- bench_var$category[i]
        target_prop <- bench_var$population_prop[i]

        idx <- data[[var]] == category
        current_prop <- sum(weights[idx], na.rm = TRUE) / sum(weights, na.rm = TRUE)

        if (!is.na(current_prop) && current_prop > 0) {
          adjustment <- target_prop / current_prop
          weights[idx] <- weights[idx] * adjustment
          max_diff <- max(max_diff, abs(target_prop - current_prop))
        }
      }
    }

    diagnostics <- rbind(
      diagnostics,
      data.frame(iteration = iter, max_absolute_difference = max_diff)
    )

    if (max_diff < tolerance) {
      break
    }
  }

  list(weights = weights, diagnostics = diagnostics)
}

variables_to_rake <- c("age_group", "gender", "education")

rake_result <- rake_weights(
  data = cleaned_data,
  benchmark_data = benchmarks,
  variables = variables_to_rake,
  max_iter = 50,
  tolerance = 1e-6
)

cleaned_data$weight_raw <- rake_result$weights

# Trim weights to reduce instability.
lower_bound <- quantile(cleaned_data$weight_raw, 0.01, na.rm = TRUE)
upper_bound <- quantile(cleaned_data$weight_raw, 0.99, na.rm = TRUE)
cleaned_data$weight_trimmed <- pmin(pmax(cleaned_data$weight_raw, lower_bound), upper_bound)

weighted_mean <- function(x, w) {
  sum(x * w, na.rm = TRUE) / sum(w[!is.na(x)], na.rm = TRUE)
}

question_cols <- paste0("q", 1:10)

weighted_estimates <- data.frame(
  question = question_cols,
  unweighted_mean = sapply(cleaned_data[, question_cols], mean, na.rm = TRUE),
  weighted_mean = sapply(cleaned_data[, question_cols], weighted_mean, w = cleaned_data$weight_trimmed),
  nonmissing_n = sapply(cleaned_data[, question_cols], function(x) sum(!is.na(x)))
)

weight_summary <- data.frame(
  metric = c(
    "Minimum raw weight",
    "Maximum raw weight",
    "Mean raw weight",
    "Minimum trimmed weight",
    "Maximum trimmed weight",
    "Mean trimmed weight"
  ),
  value = c(
    min(cleaned_data$weight_raw, na.rm = TRUE),
    max(cleaned_data$weight_raw, na.rm = TRUE),
    mean(cleaned_data$weight_raw, na.rm = TRUE),
    min(cleaned_data$weight_trimmed, na.rm = TRUE),
    max(cleaned_data$weight_trimmed, na.rm = TRUE),
    mean(cleaned_data$weight_trimmed, na.rm = TRUE)
  )
)

write.csv(cleaned_data, "output/cleaned_weighted_survey_data.csv", row.names = FALSE)
write.csv(rake_result$diagnostics, "output/weighting_diagnostics.csv", row.names = FALSE)
write.csv(weighted_estimates, "output/weighted_estimates.csv", row.names = FALSE)
write.csv(weight_summary, "output/weight_summary.csv", row.names = FALSE)

print(weighted_estimates)
cat("Raking weights and weighted estimates saved to output/.\n")
