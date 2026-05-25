# NPC Statistical Tests and Bonferroni Correction

if (requireNamespace("nfRiskStratification", quietly = TRUE)) {
  library(nfRiskStratification)
} else {
  source("R/nf-risk-stratification.R")
}

data <- read_nf_data("data/nf_clinical_data.csv")
results <- npc_analysis(data)

cat("\nPartial p-values:\n")
print(results$partial_p_values)

cat("\nGlobal NPC combination p-values:\n")
print(results$global_p_values)

cat("\nBonferroni corrected p-values:\n")
print(results$bonferroni_p_values)
