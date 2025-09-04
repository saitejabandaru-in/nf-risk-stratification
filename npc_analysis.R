# NPC Statistical Tests and Bonferroni Correction

data <- read.csv("data/nf_clinical_data.csv")

p_values <- c(
  HBA1C     = tryCatch(t.test(data$HBA1C, mu = 7)$p.value, error = function(e) NA),
  ALBUMINA  = tryCatch(t.test(data$ALBUMINA, mu = 2.8)$p.value, error = function(e) NA)
)

combined_stat <- -2 * sum(log(p_values), na.rm = TRUE)
df <- 2 * sum(!is.na(p_values))
p_fisher <- 1 - pchisq(combined_stat, df)

p_bonf <- p.adjust(p_values, method = "bonferroni")

cat("\nPartial p-values:\n"); print(p_values)
cat("\nFisher Combined p-value:", round(p_fisher, 5), "\n")
cat("\nBonferroni Corrected p-values:\n"); print(p_bonf)
